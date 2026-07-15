import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// Persists activity photos (spec §9). Metadata only — the image files live on
/// disk under the app documents dir; rows store their paths + geo/context.
class PhotoRepository {
  PhotoRepository(this._db);

  final AppDatabase _db;

  Future<void> insertPhoto({
    required String id,
    required String activityId,
    required String localPath,
    required String thumbnailPath,
    double? latitude,
    double? longitude,
    double? gpsAltitude,
    double? demAltitude,
    required DateTime takenAt,
    required int elapsedSeconds,
    required double distanceMeters,
    String? caption,
  }) async {
    await _db
        .into(_db.activityPhotos)
        .insert(
          ActivityPhotosCompanion.insert(
            id: id,
            activityId: activityId,
            localPath: localPath,
            thumbnailPath: thumbnailPath,
            takenAt: takenAt.millisecondsSinceEpoch,
            latitude: Value(latitude),
            longitude: Value(longitude),
            gpsAltitude: Value(gpsAltitude),
            demAltitude: Value(demAltitude),
            elapsedSeconds: Value(elapsedSeconds),
            distanceMeters: Value(distanceMeters),
            caption: Value(caption),
          ),
        );
  }

  Future<List<ActivityPhotoRow>> getPhotos(String activityId) {
    return (_db.select(_db.activityPhotos)
          ..where((t) => t.activityId.equals(activityId))
          ..orderBy([(t) => OrderingTerm(expression: t.takenAt)]))
        .get();
  }

  /// Update a photo's caption/memo (spec §9). Empty text clears it (null).
  Future<void> updateCaption(String photoId, String? caption) async {
    final value = (caption == null || caption.trim().isEmpty)
        ? null
        : caption.trim();
    await (_db.update(
      _db.activityPhotos,
    )..where((t) => t.id.equals(photoId))).write(
      ActivityPhotosCompanion(caption: Value(value)),
    );
  }

  Stream<List<ActivityPhotoRow>> watchPhotos(String activityId) {
    return (_db.select(_db.activityPhotos)
          ..where((t) => t.activityId.equals(activityId))
          ..orderBy([(t) => OrderingTerm(expression: t.takenAt)]))
        .watch();
  }

  Future<int> countPhotos(String activityId) async {
    final rows = await getPhotos(activityId);
    return rows.length;
  }

  Future<void> deletePhoto(String id) async {
    await (_db.delete(_db.activityPhotos)..where((t) => t.id.equals(id))).go();
  }

  /// Set the representative photo for an activity (first photo by default).
  Future<void> setRepresentativePhoto(String activityId, String photoId) async {
    await (_db.update(_db.activities)..where((t) => t.id.equals(activityId)))
        .write(ActivitiesCompanion(representativePhotoId: Value(photoId)));
  }
}
