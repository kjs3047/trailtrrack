import 'package:drift/drift.dart';

/// Drift table definitions (see DATABASE.md). UUID string primary keys; foreign
/// keys with cascade delete; no sync-engine tables (spec §12).

@DataClassName('ActivityRow')
class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get activityType => text()();
  TextColumn get status => text()();
  IntColumn get startedAt => integer()(); // epoch ms
  IntColumn get endedAt => integer().nullable()();
  IntColumn get elapsedSeconds => integer().withDefault(const Constant(0))();
  IntColumn get activeSeconds => integer().withDefault(const Constant(0))();
  RealColumn get totalDistanceMeters => real().withDefault(const Constant(0))();
  RealColumn get averageSpeed => real().withDefault(const Constant(0))();
  RealColumn get maxSpeed => real().withDefault(const Constant(0))();
  RealColumn get minimumAltitude => real().nullable()();
  RealColumn get maximumAltitude => real().nullable()();
  RealColumn get elevationGain => real().withDefault(const Constant(0))();
  RealColumn get elevationLoss => real().withDefault(const Constant(0))();
  RealColumn get calories => real().withDefault(const Constant(0))();
  TextColumn get memo => text().nullable()();
  TextColumn get representativePhotoId => text().nullable()();

  // Crash-recovery snapshot fields (spec §14).
  IntColumn get lastSequence => integer().withDefault(const Constant(-1))();
  RealColumn get lastLatitude => real().nullable()();
  RealColumn get lastLongitude => real().nullable()();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TrackPointRow')
class TrackPoints extends Table {
  TextColumn get id => text()();
  TextColumn get activityId =>
      text().references(Activities, #id, onDelete: KeyAction.cascade)();
  IntColumn get sequence => integer()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get gpsAltitude => real().nullable()();
  RealColumn get demAltitude => real().nullable()();
  RealColumn get speed => real().nullable()();
  RealColumn get heading => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  IntColumn get recordedAt => integer()(); // epoch ms
  IntColumn get segmentIndex => integer().withDefault(const Constant(0))();
  BoolColumn get isAccepted => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ActivityPhotoRow')
class ActivityPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get activityId =>
      text().references(Activities, #id, onDelete: KeyAction.cascade)();
  TextColumn get localPath => text()();
  TextColumn get thumbnailPath => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get gpsAltitude => real().nullable()();
  RealColumn get demAltitude => real().nullable()();
  IntColumn get takenAt => integer()(); // epoch ms
  IntColumn get elapsedSeconds => integer().withDefault(const Constant(0))();
  RealColumn get distanceMeters => real().withDefault(const Constant(0))();
  TextColumn get caption => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('BackupHistoryRow')
class BackupHistory extends Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()(); // epoch ms
  TextColumn get driveFileId => text().nullable()();
  TextColumn get type => text()(); // 'full' | 'light'
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  IntColumn get activityCount => integer().withDefault(const Constant(0))();
  IntColumn get photoCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text()(); // 'success' | 'failed'

  @override
  Set<Column> get primaryKey => {id};
}
