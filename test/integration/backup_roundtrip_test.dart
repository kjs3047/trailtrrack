import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/core/database/app_database.dart';
import 'package:trailtrack/core/utils/activity_type.dart';
import 'package:trailtrack/features/backup/backup_service.dart';
import 'package:trailtrack/features/backup/fake_drive_client.dart';
import 'package:trailtrack/features/backup/models/backup_models.dart';
import 'package:trailtrack/features/recording/data/activity_repository.dart';
import 'package:trailtrack/features/recording/models/recorded_point.dart';

void main() {
  late AppDatabase db;
  late ActivityRepository repo;
  late BackupService backup;
  late Directory tmp;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ActivityRepository(db);
    backup = BackupService(db: db, repository: repo);
    tmp = Directory.systemTemp.createTempSync('trailtrack_backup_test');
  });

  tearDown(() async {
    await db.close();
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  Future<void> seed(String id, {int points = 3}) async {
    await repo.createActivity(
      id: id,
      type: ActivityType.hike,
      startedAt: DateTime(2026, 1, 1, 8),
    );
    final pts = <RecordedPoint>[];
    final ids = <String>[];
    for (var i = 0; i < points; i++) {
      pts.add(
        RecordedPoint(
          sequence: i,
          latitude: 37.5 + i * 0.001,
          longitude: 127.0,
          recordedAt: DateTime(2026, 1, 1, 8).add(Duration(seconds: i * 10)),
          gpsAltitude: 100 + i * 5,
        ),
      );
      ids.add('$id-p$i');
    }
    await repo.insertTrackPoints(id, pts, ids);
  }

  test(
    'full round trip: create → upload → wipe → download → restore',
    () async {
      await seed('a1', points: 5);
      await seed('a2', points: 3);

      final zipPath = '${tmp.path}/backup.zip';
      final manifest = await backup.createBackup(
        type: BackupType.full,
        outputZipPath: zipPath,
        workDir: Directory('${tmp.path}/work'),
      );
      expect(manifest.activityCount, 2);
      expect(manifest.trackPointCount, 8);
      expect(File(zipPath).existsSync(), isTrue);

      // Upload to fake Drive (streamed).
      final drive = FakeDriveClient();
      final zipFile = File(zipPath);
      final fileId = await drive.uploadBackup(
        fileName: 'workout-backup.zip',
        data: zipFile.openRead(),
        totalBytes: zipFile.lengthSync(),
      );
      expect(drive.storedCount, 1);

      // Wipe local data.
      await repo.deleteActivity('a1');
      await repo.deleteActivity('a2');
      expect((await repo.getAllActivities()).length, 0);

      // Download + restore (merge).
      final downloaded = await drive.downloadBackup(fileId);
      final restorePath = '${tmp.path}/restore.zip';
      File(restorePath).writeAsBytesSync(downloaded);
      final result = await backup.restoreBackup(
        zipPath: restorePath,
        mode: RestoreMode.merge,
        photosDir: Directory('${tmp.path}/photos'),
      );

      expect(result.addedActivities, 2);
      expect(result.skippedActivities, 0);
      final restored = await repo.getAllActivities();
      expect(restored.length, 2);
      expect((await repo.getTrackPoints('a1')).length, 5);
      expect((await repo.getTrackPoints('a2')).length, 3);
    },
  );

  test('merge restore skips existing activityIds', () async {
    await seed('keep', points: 2);
    final zipPath = '${tmp.path}/b.zip';
    await backup.createBackup(
      type: BackupType.light,
      outputZipPath: zipPath,
      workDir: Directory('${tmp.path}/work'),
    );

    // 'keep' still present locally → merge should skip it.
    final result = await backup.restoreBackup(
      zipPath: zipPath,
      mode: RestoreMode.merge,
      photosDir: Directory('${tmp.path}/photos'),
    );
    expect(result.addedActivities, 0);
    expect(result.skippedActivities, 1);
    // Local data untouched.
    expect((await repo.getTrackPoints('keep')).length, 2);
  });

  test('light backup excludes photo files; manifest flags it', () async {
    await seed('a', points: 2);
    final zipPath = '${tmp.path}/light.zip';
    final manifest = await backup.createBackup(
      type: BackupType.light,
      outputZipPath: zipPath,
      workDir: Directory('${tmp.path}/work'),
    );
    expect(manifest.includesPhotos, isFalse);
    expect(manifest.type, BackupType.light);

    // No photos/ entries in the ZIP. Read bytes so no file handle lingers.
    final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());
    final hasPhotoDir = archive.files.any((f) => f.name.startsWith('photos/'));
    expect(hasPhotoDir, isFalse);
  });

  test('large track-point set survives streaming backup + restore', () async {
    await seed('big', points: 5000); // > batch size (2000)
    final zipPath = '${tmp.path}/big.zip';
    final manifest = await backup.createBackup(
      type: BackupType.light,
      outputZipPath: zipPath,
      workDir: Directory('${tmp.path}/work'),
    );
    expect(manifest.trackPointCount, 5000);

    await repo.deleteActivity('big');
    await backup.restoreBackup(
      zipPath: zipPath,
      mode: RestoreMode.merge,
      photosDir: Directory('${tmp.path}/photos'),
    );
    expect((await repo.getTrackPoints('big')).length, 5000);
  });

  test('replace mode wipes then loads backup', () async {
    await seed('old', points: 2);
    final zipPath = '${tmp.path}/snapshot.zip';
    await backup.createBackup(
      type: BackupType.light,
      outputZipPath: zipPath,
      workDir: Directory('${tmp.path}/work'),
    );

    // Add a second activity that is NOT in the backup.
    await seed('extra', points: 1);
    expect((await repo.getAllActivities()).length, 2);

    // Replace → only the backup's 'old' remains.
    await backup.restoreBackup(
      zipPath: zipPath,
      mode: RestoreMode.replace,
      photosDir: Directory('${tmp.path}/photos'),
    );
    final all = await repo.getAllActivities();
    expect(all.map((a) => a.id).toSet(), {'old'});
  });

  group('retention', () {
    DriveBackupFile f(String id, int day) => DriveBackupFile(
      fileId: id,
      name: id,
      sizeBytes: 100,
      createdAt: DateTime(2026, 1, day),
    );

    test('nothing over retention when at or under keep count', () {
      final over = BackupService.backupsOverRetention([
        f('a', 1),
        f('b', 2),
      ], 5);
      expect(over, isEmpty);
    });

    test('returns oldest beyond keep count', () {
      final backups = [f('a', 1), f('b', 2), f('c', 3), f('d', 4)];
      final over = BackupService.backupsOverRetention(backups, 2);
      // keep 2 newest (d, c) → over = [b, a] oldest.
      expect(over.map((e) => e.fileId), ['b', 'a']);
    });
  });
}
