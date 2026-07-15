import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';

/// Pure row ↔ JSON conversion for backup/restore (spec §13). No I/O here so the
/// mapping is unit-testable; streaming/gzip/zip live in BackupService.
class BackupSerializer {
  const BackupSerializer();

  Map<String, dynamic> activityToJson(ActivityRow a) => {
    'id': a.id,
    'title': a.title,
    'activityType': a.activityType,
    'status': a.status,
    'startedAt': a.startedAt,
    'endedAt': a.endedAt,
    'elapsedSeconds': a.elapsedSeconds,
    'activeSeconds': a.activeSeconds,
    'totalDistanceMeters': a.totalDistanceMeters,
    'averageSpeed': a.averageSpeed,
    'maxSpeed': a.maxSpeed,
    'minimumAltitude': a.minimumAltitude,
    'maximumAltitude': a.maximumAltitude,
    'elevationGain': a.elevationGain,
    'elevationLoss': a.elevationLoss,
    'calories': a.calories,
    'memo': a.memo,
    'representativePhotoId': a.representativePhotoId,
    'createdAt': a.createdAt,
    'updatedAt': a.updatedAt,
  };

  ActivitiesCompanion activityFromJson(Map<String, dynamic> j) {
    Value<T> v<T>(String key) => j.containsKey(key) && j[key] != null
        ? Value(j[key] as T)
        : const Value.absent();
    return ActivitiesCompanion.insert(
      id: j['id'] as String,
      activityType: j['activityType'] as String,
      status: j['status'] as String,
      startedAt: (j['startedAt'] as num).toInt(),
      createdAt: (j['createdAt'] as num?)?.toInt() ?? 0,
      updatedAt: (j['updatedAt'] as num?)?.toInt() ?? 0,
      title: v<String>('title'),
      endedAt: v<int>('endedAt'),
      elapsedSeconds: v<int>('elapsedSeconds'),
      activeSeconds: v<int>('activeSeconds'),
      totalDistanceMeters: _numVal(j, 'totalDistanceMeters'),
      averageSpeed: _numVal(j, 'averageSpeed'),
      maxSpeed: _numVal(j, 'maxSpeed'),
      minimumAltitude: _numValNullable(j, 'minimumAltitude'),
      maximumAltitude: _numValNullable(j, 'maximumAltitude'),
      elevationGain: _numVal(j, 'elevationGain'),
      elevationLoss: _numVal(j, 'elevationLoss'),
      calories: _numVal(j, 'calories'),
      memo: v<String>('memo'),
      representativePhotoId: v<String>('representativePhotoId'),
    );
  }

  Map<String, dynamic> trackPointToJson(TrackPointRow t) => {
    'id': t.id,
    'activityId': t.activityId,
    'sequence': t.sequence,
    'latitude': t.latitude,
    'longitude': t.longitude,
    'gpsAltitude': t.gpsAltitude,
    'demAltitude': t.demAltitude,
    'speed': t.speed,
    'heading': t.heading,
    'accuracy': t.accuracy,
    'recordedAt': t.recordedAt,
    'segmentIndex': t.segmentIndex,
    'isAccepted': t.isAccepted,
  };

  TrackPointsCompanion trackPointFromJson(Map<String, dynamic> j) =>
      TrackPointsCompanion.insert(
        id: j['id'] as String,
        activityId: j['activityId'] as String,
        sequence: (j['sequence'] as num).toInt(),
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        recordedAt: (j['recordedAt'] as num).toInt(),
        gpsAltitude: _numValNullable(j, 'gpsAltitude'),
        demAltitude: _numValNullable(j, 'demAltitude'),
        speed: _numValNullable(j, 'speed'),
        heading: _numValNullable(j, 'heading'),
        accuracy: _numValNullable(j, 'accuracy'),
        segmentIndex: j['segmentIndex'] != null
            ? Value((j['segmentIndex'] as num).toInt())
            : const Value.absent(),
        isAccepted: j['isAccepted'] != null
            ? Value(j['isAccepted'] as bool)
            : const Value.absent(),
      );

  Map<String, dynamic> photoToJson(ActivityPhotoRow p) => {
    'id': p.id,
    'activityId': p.activityId,
    'localPath': p.localPath,
    'thumbnailPath': p.thumbnailPath,
    'latitude': p.latitude,
    'longitude': p.longitude,
    'gpsAltitude': p.gpsAltitude,
    'demAltitude': p.demAltitude,
    'takenAt': p.takenAt,
    'elapsedSeconds': p.elapsedSeconds,
    'distanceMeters': p.distanceMeters,
    'caption': p.caption,
  };

  ActivityPhotosCompanion photoFromJson(
    Map<String, dynamic> j, {
    required String localPath,
    required String thumbnailPath,
  }) => ActivityPhotosCompanion.insert(
    id: j['id'] as String,
    activityId: j['activityId'] as String,
    localPath: localPath,
    thumbnailPath: thumbnailPath,
    takenAt: (j['takenAt'] as num).toInt(),
    latitude: _numValNullable(j, 'latitude'),
    longitude: _numValNullable(j, 'longitude'),
    gpsAltitude: _numValNullable(j, 'gpsAltitude'),
    demAltitude: _numValNullable(j, 'demAltitude'),
    elapsedSeconds: j['elapsedSeconds'] != null
        ? Value((j['elapsedSeconds'] as num).toInt())
        : const Value.absent(),
    distanceMeters: _numVal(j, 'distanceMeters'),
    caption: j['caption'] != null
        ? Value(j['caption'] as String)
        : const Value.absent(),
  );

  static Value<double> _numVal(Map<String, dynamic> j, String key) =>
      j[key] != null ? Value((j[key] as num).toDouble()) : const Value.absent();

  static Value<double?> _numValNullable(Map<String, dynamic> j, String key) =>
      j[key] != null ? Value((j[key] as num).toDouble()) : const Value.absent();
}
