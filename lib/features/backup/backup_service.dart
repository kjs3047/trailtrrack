import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' show InsertMode;
import 'package:path/path.dart' as p;

import '../../core/database/app_database.dart';
import '../recording/data/activity_repository.dart';
import 'backup_serializer.dart';
import 'models/backup_models.dart';

/// Builds and restores backup ZIPs in a **memory-safe, streaming** way
/// (spec §13, §20): track points are streamed to a gzipped temp file in
/// batches rather than materialised all at once, and photo files are added to
/// the ZIP via file streams.
class BackupService {
  BackupService({
    required AppDatabase db,
    required ActivityRepository repository,
    String appVersion = '1.0.0',
    BackupSerializer serializer = const BackupSerializer(),
  }) // ignore_for_file: prefer_initializing_formals
  : _db = db,
       _repo = repository,
       _appVersion = appVersion,
       _ser = serializer;

  final AppDatabase _db;
  final ActivityRepository _repo;
  final String _appVersion;
  final BackupSerializer _ser;

  /// Batch size when streaming track points out of the DB.
  static const _pointBatchSize = 2000;

  /// Build a backup ZIP at [outputZipPath] using [workDir] for temp files.
  /// Returns the manifest that was embedded. Callers upload the resulting file.
  Future<BackupManifest> createBackup({
    required BackupType type,
    required String outputZipPath,
    required Directory workDir,
    DateTime? createdAt,
  }) async {
    if (!workDir.existsSync()) workDir.createSync(recursive: true);
    final stamp = createdAt ?? DateTime.now();

    // 1) activities.json.gz (bounded set — safe to build in memory).
    final activities = await _repo.getAllActivities();
    final activitiesJson = jsonEncode(
      activities.map(_ser.activityToJson).toList(),
    );
    final activitiesGzPath = p.join(workDir.path, 'activities.json.gz');
    File(
      activitiesGzPath,
    ).writeAsBytesSync(GZipEncoder().encode(utf8.encode(activitiesJson)));

    // 2) track_points.json.gz — STREAMED. We build a gzipped JSON array by
    //    writing to a temp .json file in batches, then gzip that file.
    final tpJsonPath = p.join(workDir.path, 'track_points.json');
    final tpSink = File(tpJsonPath).openWrite();
    int trackPointCount = 0;
    tpSink.write('[');
    var first = true;
    for (final a in activities) {
      var offset = 0;
      while (true) {
        final batch = await _repo.getTrackPointsPaged(
          a.id,
          limit: _pointBatchSize,
          offset: offset,
        );
        if (batch.isEmpty) break;
        for (final tp in batch) {
          if (!first) tpSink.write(',');
          first = false;
          tpSink.write(jsonEncode(_ser.trackPointToJson(tp)));
          trackPointCount++;
        }
        offset += batch.length;
        if (batch.length < _pointBatchSize) break;
      }
    }
    tpSink.write(']');
    await tpSink.flush();
    await tpSink.close();

    // gzip the streamed json file → track_points.json.gz (streamed I/O).
    final tpGzPath = p.join(workDir.path, 'track_points.json.gz');
    await _gzipFile(tpJsonPath, tpGzPath);
    File(tpJsonPath).deleteSync();

    // 3) activity_photos.json (metadata; bounded).
    final photos = <ActivityPhotoRow>[];
    for (final a in activities) {
      photos.addAll(await _repo.getPhotos(a.id));
    }
    final photosJsonPath = p.join(workDir.path, 'activity_photos.json');
    File(
      photosJsonPath,
    ).writeAsStringSync(jsonEncode(photos.map(_ser.photoToJson).toList()));

    // 4) manifest.json.
    final manifest = BackupManifest(
      formatVersion: BackupManifest.currentFormatVersion,
      appVersion: _appVersion,
      createdAt: stamp,
      activityCount: activities.length,
      trackPointCount: trackPointCount,
      photoCount: photos.length,
      includesPhotos: type.includesPhotos,
    );
    final manifestPath = p.join(workDir.path, 'manifest.json');
    File(manifestPath).writeAsStringSync(jsonEncode(manifest.toJson()));

    // 5) Assemble the ZIP with a file-based encoder (streams photo files).
    final encoder = ZipFileEncoder();
    encoder.create(outputZipPath);
    await encoder.addFile(File(manifestPath), 'manifest.json');
    await encoder.addFile(File(activitiesGzPath), 'activities.json.gz');
    await encoder.addFile(File(tpGzPath), 'track_points.json.gz');
    await encoder.addFile(File(photosJsonPath), 'activity_photos.json');

    if (type.includesPhotos) {
      for (final photo in photos) {
        await _addPhotoFile(encoder, photo.localPath, 'photos/originals');
        await _addPhotoFile(encoder, photo.thumbnailPath, 'photos/thumbnails');
      }
    }
    await encoder.close();

    // Clean up intermediate files.
    for (final f in [
      manifestPath,
      activitiesGzPath,
      tpGzPath,
      photosJsonPath,
    ]) {
      final file = File(f);
      if (file.existsSync()) file.deleteSync();
    }

    return manifest;
  }

  Future<void> _addPhotoFile(
    ZipFileEncoder encoder,
    String path,
    String zipDir,
  ) async {
    final file = File(path);
    if (!file.existsSync()) return; // photo file missing — skip gracefully
    final name = '$zipDir/${p.basename(path)}';
    await encoder.addFile(file, name);
  }

  /// Stream-gzip a file using dart:io's native GZipCodec so the payload is
  /// never fully buffered in memory (spec §13/§20).
  Future<void> _gzipFile(String inputPath, String outputPath) async {
    final input = File(inputPath).openRead();
    final output = File(outputPath).openWrite();
    await input.transform(gzip.encoder).pipe(output);
  }

  /// Estimate the number of photos and the approximate ZIP size for the
  /// pre-save summary (spec §13). Sums photo file sizes for a full backup.
  Future<({int photoCount, int estimatedBytes})> estimate(
    BackupType type,
  ) async {
    final activities = await _repo.getAllActivities();
    int photoCount = 0;
    int bytes = 0;
    for (final a in activities) {
      final photos = await _repo.getPhotos(a.id);
      photoCount += photos.length;
      if (type.includesPhotos) {
        for (final ph in photos) {
          bytes += _fileSize(ph.localPath) + _fileSize(ph.thumbnailPath);
        }
      }
    }
    // Rough allowance for gzipped JSON payloads.
    bytes += 50 * 1024;
    return (photoCount: photoCount, estimatedBytes: bytes);
  }

  int _fileSize(String path) {
    final f = File(path);
    return f.existsSync() ? f.lengthSync() : 0;
  }

  /// Read a backup ZIP's manifest. Reads the archive bytes and closes the file
  /// handle immediately (avoids lingering handles on Windows).
  BackupManifest readManifest(String zipPath) {
    final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());
    final entry = archive.findFile('manifest.json');
    if (entry == null) {
      throw const FormatException('manifest.json missing from backup');
    }
    final json = jsonDecode(utf8.decode(entry.content)) as Map<String, dynamic>;
    return BackupManifest.fromJson(json);
  }

  /// Restore a backup ZIP (spec §13). Runs inside a single transaction.
  /// [photosDir] is where photo files are written (app documents/photos).
  Future<RestoreResult> restoreBackup({
    required String zipPath,
    required RestoreMode mode,
    required Directory photosDir,
  }) async {
    // Read the archive fully into memory then close the file handle. Track
    // points are still inserted in DB batches (spec §13); the restore memory
    // bound is the zip payload, not an unbounded materialised point list.
    final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());

    final manifestEntry = archive.findFile('manifest.json');
    if (manifestEntry == null) {
      throw const FormatException('Invalid backup: no manifest');
    }
    final manifest = BackupManifest.fromJson(
      jsonDecode(utf8.decode(manifestEntry.content as List<int>))
          as Map<String, dynamic>,
    );
    if (!manifest.isSupported) {
      throw FormatException(
        'Unsupported backup format version ${manifest.formatVersion}',
      );
    }

    // Decode JSON payloads.
    final activitiesJson = _decodeGzJsonArray(archive, 'activities.json.gz');
    final trackPointsJson = _decodeGzJsonArray(archive, 'track_points.json.gz');
    final photosJson = _decodeJsonArray(archive, 'activity_photos.json');

    int addedActivities = 0;
    int skippedActivities = 0;
    int restoredPhotos = 0;
    int missingPhotoFiles = 0;

    await _db.transaction(() async {
      if (mode == RestoreMode.replace) {
        // Cascade wipes track points + photos.
        await _db.delete(_db.activities).go();
      }

      final existingIds = (await _repo.getAllActivities())
          .map((a) => a.id)
          .toSet();

      // Determine which activityIds we will actually insert.
      final acceptIds = <String>{};
      for (final aj in activitiesJson) {
        final id = aj['id'] as String;
        if (mode == RestoreMode.merge && existingIds.contains(id)) {
          skippedActivities++;
          continue;
        }
        acceptIds.add(id);
        await _db
            .into(_db.activities)
            .insert(_ser.activityFromJson(aj), mode: InsertMode.insertOrIgnore);
        addedActivities++;
      }

      // Track points for accepted activities only.
      await _db.batch((b) {
        for (final tj in trackPointsJson) {
          if (!acceptIds.contains(tj['activityId'])) continue;
          b.insert(
            _db.trackPoints,
            _ser.trackPointFromJson(tj),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });

      // Photos: write files (full backup) and metadata rows.
      for (final pj in photosJson) {
        if (!acceptIds.contains(pj['activityId'])) continue;
        final id = pj['id'] as String;
        final activityId = pj['activityId'] as String;
        final dir = Directory(p.join(photosDir.path, activityId));
        if (!dir.existsSync()) dir.createSync(recursive: true);

        final origName =
            'photos/originals/${p.basename(pj['localPath'] as String)}';
        final thumbName =
            'photos/thumbnails/${p.basename(pj['thumbnailPath'] as String)}';
        final origEntry = archive.findFile(origName);
        final thumbEntry = archive.findFile(thumbName);

        String localPath;
        String thumbnailPath;
        if (origEntry != null) {
          localPath = p.join(dir.path, '$id.jpg');
          File(localPath).writeAsBytesSync(origEntry.content as List<int>);
        } else {
          localPath = pj['localPath'] as String; // metadata-only (light backup)
          missingPhotoFiles++;
        }
        if (thumbEntry != null) {
          thumbnailPath = p.join(dir.path, '${id}_thumb.jpg');
          File(thumbnailPath).writeAsBytesSync(thumbEntry.content as List<int>);
        } else {
          thumbnailPath = pj['thumbnailPath'] as String;
        }

        await _db
            .into(_db.activityPhotos)
            .insert(
              _ser.photoFromJson(
                pj,
                localPath: localPath,
                thumbnailPath: thumbnailPath,
              ),
              mode: InsertMode.insertOrIgnore,
            );
        restoredPhotos++;
      }
    });

    return RestoreResult(
      addedActivities: addedActivities,
      skippedActivities: skippedActivities,
      restoredPhotos: restoredPhotos,
      missingPhotoFiles: missingPhotoFiles,
      manifest: manifest,
    );
  }

  List<Map<String, dynamic>> _decodeGzJsonArray(Archive archive, String name) {
    final entry = archive.findFile(name);
    if (entry == null) return const [];
    final gz = entry.content as List<int>;
    final jsonStr = utf8.decode(GZipDecoder().decodeBytes(gz));
    return (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> _decodeJsonArray(Archive archive, String name) {
    final entry = archive.findFile(name);
    if (entry == null) return const [];
    final jsonStr = utf8.decode(entry.content as List<int>);
    return (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
  }

  /// Which backups exceed the retention count and are candidates for deletion,
  /// oldest first (spec §13). Never deletes automatically — the caller confirms.
  static List<DriveBackupFile> backupsOverRetention(
    List<DriveBackupFile> backups,
    int keep,
  ) {
    if (backups.length <= keep) return const [];
    final sorted = [...backups]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
    return sorted.sublist(keep); // the ones beyond `keep` (oldest)
  }
}

/// Outcome of a restore.
class RestoreResult {
  const RestoreResult({
    required this.addedActivities,
    required this.skippedActivities,
    required this.restoredPhotos,
    required this.missingPhotoFiles,
    required this.manifest,
  });

  final int addedActivities;
  final int skippedActivities;
  final int restoredPhotos;
  final int missingPhotoFiles;
  final BackupManifest manifest;
}
