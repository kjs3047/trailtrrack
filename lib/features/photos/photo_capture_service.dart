import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../recording/models/recorded_point.dart';
import 'data/photo_repository.dart';
import 'gallery_exporter.dart';
import 'photo_location_matcher.dart';
import 'photo_storage.dart';

/// Ties together photo persistence: store files, match a GPS location by time,
/// and write the DB row (spec §9). UI-agnostic so it can be tested with bytes.
class PhotoCaptureService {
  PhotoCaptureService({
    required PhotoRepository repository,
    PhotoStorage storage = const PhotoStorage(),
    PhotoLocationMatcher matcher = const PhotoLocationMatcher(),
    GalleryExporter? gallery,
    Uuid? uuid,
  }) : _repo = repository,
       _storage = storage,
       _matcher = matcher,
       _gallery = gallery,
       _uuid = uuid ?? const Uuid();

  final PhotoRepository _repo;
  final PhotoStorage _storage;
  final PhotoLocationMatcher _matcher;
  final GalleryExporter? _gallery;
  final Uuid _uuid;

  /// Save a captured photo for [activityId]. [takenAt] is the capture time,
  /// used to find the nearest GPS fix among [points].
  Future<String> savePhoto({
    required String activityId,
    required Uint8List imageBytes,
    required DateTime takenAt,
    required DateTime activityStart,
    required List<RecordedPoint> points,
    String? caption,
    bool asRepresentative = false,
  }) async {
    final photoId = _uuid.v4();
    final paths = await _storage.save(
      activityId: activityId,
      photoId: photoId,
      originalBytes: imageBytes,
    );

    final loc = _matcher.match(
      takenAt: takenAt,
      points: points,
      activityStart: activityStart,
    );

    await _repo.insertPhoto(
      id: photoId,
      activityId: activityId,
      localPath: paths.originalPath,
      thumbnailPath: paths.thumbnailPath,
      latitude: loc.latitude,
      longitude: loc.longitude,
      gpsAltitude: loc.gpsAltitude,
      demAltitude: loc.demAltitude,
      takenAt: takenAt,
      elapsedSeconds: loc.elapsedSeconds,
      distanceMeters: loc.distanceMeters,
      caption: caption,
    );

    if (asRepresentative) {
      await _repo.setRepresentativePhoto(activityId, photoId);
    }

    // Also export to the shared device gallery (사진첩). Non-fatal: the in-app
    // copy above is already persisted either way.
    await _gallery?.saveImage(imageBytes, name: 'trailtrack_$photoId');
    return photoId;
  }
}
