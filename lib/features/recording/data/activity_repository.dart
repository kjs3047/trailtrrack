import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/activity_type.dart';
import '../activity_stats.dart';
import '../models/recorded_point.dart';

/// Persists activities, track points and their summary statistics.
///
/// Thin wrapper over Drift: the recording controller calls these; the DB is the
/// single source of truth (spec §6, §14). Batch inserts keep large point sets
/// off the main thread and out of a single giant statement.
class ActivityRepository {
  ActivityRepository(this._db);

  final AppDatabase _db;

  /// Insert a new activity row in `recording` state and return its row.
  Future<ActivityRow> createActivity({
    required String id,
    required ActivityType type,
    required DateTime startedAt,
    String title = '',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final companion = ActivitiesCompanion.insert(
      id: id,
      activityType: type.id,
      status: 'recording',
      startedAt: startedAt.millisecondsSinceEpoch,
      createdAt: now,
      updatedAt: now,
      title: Value(title),
    );
    await _db.into(_db.activities).insert(companion);
    return (await getActivity(id))!;
  }

  Future<ActivityRow?> getActivity(String id) {
    return (_db.select(
      _db.activities,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Batch-insert accepted+rejected track points (spec §6 keeps originals).
  Future<void> insertTrackPoints(
    String activityId,
    List<RecordedPoint> points,
    List<String> ids,
  ) async {
    assert(points.length == ids.length);
    await _db.batch((b) {
      for (var i = 0; i < points.length; i++) {
        final p = points[i];
        b.insert(
          _db.trackPoints,
          TrackPointsCompanion.insert(
            id: ids[i],
            activityId: activityId,
            sequence: p.sequence,
            latitude: p.latitude,
            longitude: p.longitude,
            recordedAt: p.recordedAt.millisecondsSinceEpoch,
            gpsAltitude: Value(p.gpsAltitude),
            demAltitude: Value(p.demAltitude),
            speed: Value(p.speed),
            heading: Value(p.heading),
            accuracy: Value(p.accuracy),
            segmentIndex: Value(p.segmentIndex),
            isAccepted: Value(p.isAccepted),
          ),
        );
      }
    });
  }

  /// Update the periodic recovery snapshot (spec §14).
  Future<void> updateSnapshot({
    required String activityId,
    required int lastSequence,
    required double distanceMeters,
    double? lastLat,
    double? lastLon,
    String? status,
  }) async {
    await (_db.update(
      _db.activities,
    )..where((t) => t.id.equals(activityId))).write(
      ActivitiesCompanion(
        lastSequence: Value(lastSequence),
        totalDistanceMeters: Value(distanceMeters),
        lastLatitude: Value(lastLat),
        lastLongitude: Value(lastLon),
        status: status == null ? const Value.absent() : Value(status),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> setStatus(String activityId, String status) async {
    await (_db.update(
      _db.activities,
    )..where((t) => t.id.equals(activityId))).write(
      ActivitiesCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Finalize an activity: persist the computed stats and mark it completed.
  Future<void> finalizeActivity({
    required String activityId,
    required DateTime endedAt,
    required ActivityStats stats,
    String? title,
  }) async {
    await (_db.update(
      _db.activities,
    )..where((t) => t.id.equals(activityId))).write(
      ActivitiesCompanion(
        status: const Value('completed'),
        endedAt: Value(endedAt.millisecondsSinceEpoch),
        elapsedSeconds: Value(stats.elapsedSeconds.round()),
        activeSeconds: Value(stats.movingSeconds.round()),
        totalDistanceMeters: Value(stats.totalDistanceMeters),
        averageSpeed: Value(stats.averageSpeed),
        maxSpeed: Value(stats.maxSpeed),
        minimumAltitude: Value(stats.minAltitude),
        maximumAltitude: Value(stats.maxAltitude),
        elevationGain: Value(stats.elevationGain),
        elevationLoss: Value(stats.elevationLoss),
        calories: Value(stats.calories),
        title: title == null ? const Value.absent() : Value(title),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<List<TrackPointRow>> getTrackPoints(String activityId) {
    return (_db.select(_db.trackPoints)
          ..where((t) => t.activityId.equals(activityId))
          ..orderBy([(t) => OrderingTerm(expression: t.sequence)]))
        .get();
  }

  /// Paged track-point query used by the streaming backup writer so the whole
  /// point set is never held in memory at once (spec §13/§20).
  Future<List<TrackPointRow>> getTrackPointsPaged(
    String activityId, {
    required int limit,
    required int offset,
  }) {
    return (_db.select(_db.trackPoints)
          ..where((t) => t.activityId.equals(activityId))
          ..orderBy([(t) => OrderingTerm(expression: t.sequence)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<ActivityRow>> getAllActivities() {
    return (_db.select(_db.activities)..orderBy([
          (t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Stream<List<ActivityRow>> watchActivities() {
    return (_db.select(_db.activities)..orderBy([
          (t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  /// Activities left in a non-terminal state indicate an interrupted recording
  /// that should be offered for recovery on startup (spec §14).
  Future<List<ActivityRow>> getRecoverableActivities() {
    return (_db.select(_db.activities)..where(
          (t) => t.status.isIn(['recording', 'paused', 'recoveryRequired']),
        ))
        .get();
  }

  Future<void> deleteActivity(String id) async {
    // Cascade removes track points and photos.
    await (_db.delete(_db.activities)..where((t) => t.id.equals(id))).go();
  }

  Future<List<ActivityPhotoRow>> getPhotos(String activityId) {
    return (_db.select(_db.activityPhotos)
          ..where((t) => t.activityId.equals(activityId))
          ..orderBy([(t) => OrderingTerm(expression: t.takenAt)]))
        .get();
  }

  RecordedPoint rowToPoint(TrackPointRow r) => RecordedPoint(
    sequence: r.sequence,
    latitude: r.latitude,
    longitude: r.longitude,
    recordedAt: DateTime.fromMillisecondsSinceEpoch(r.recordedAt),
    gpsAltitude: r.gpsAltitude,
    demAltitude: r.demAltitude,
    speed: r.speed,
    heading: r.heading,
    accuracy: r.accuracy,
    segmentIndex: r.segmentIndex,
    isAccepted: r.isAccepted,
  );
}

/// Everything the detail screen needs for one activity (spec §10.4).
class ActivityDetailData {
  const ActivityDetailData({
    required this.activity,
    required this.points,
    required this.photos,
  });

  final ActivityRow activity;
  final List<RecordedPoint> points;
  final List<ActivityPhotoRow> photos;

  ActivityType get type => ActivityType.fromId(activity.activityType);
}
