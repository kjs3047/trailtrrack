import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/core/database/app_database.dart';
import 'package:trailtrack/core/utils/activity_type.dart';
import 'package:trailtrack/features/backup/backup_serializer.dart';
import 'package:trailtrack/features/backup/models/backup_models.dart';
import 'package:trailtrack/features/recording/data/activity_repository.dart';
import 'package:trailtrack/features/recording/models/recorded_point.dart';

void main() {
  const ser = BackupSerializer();

  group('manifest', () {
    test('round trips through JSON', () {
      final m = BackupManifest(
        formatVersion: 1,
        appVersion: '1.0.0',
        createdAt: DateTime.utc(2026, 1, 1, 12),
        activityCount: 2,
        trackPointCount: 100,
        photoCount: 3,
        includesPhotos: true,
      );
      final back = BackupManifest.fromJson(m.toJson());
      expect(back.formatVersion, 1);
      expect(back.activityCount, 2);
      expect(back.trackPointCount, 100);
      expect(back.includesPhotos, isTrue);
      expect(back.type, BackupType.full);
      expect(back.isSupported, isTrue);
    });

    test('future format version is unsupported', () {
      final m = BackupManifest.fromJson({
        'formatVersion': 999,
        'appVersion': 'x',
        'createdAt': DateTime.utc(2026).toIso8601String(),
        'activityCount': 0,
        'trackPointCount': 0,
        'photoCount': 0,
        'includesPhotos': false,
      });
      expect(m.isSupported, isFalse);
    });
  });

  group('activity/track point serialization', () {
    late AppDatabase db;
    late ActivityRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = ActivityRepository(db);
    });
    tearDown(() => db.close());

    test('activity survives json → companion → db → row', () async {
      await repo.createActivity(
        id: 'a',
        type: ActivityType.trailRun,
        startedAt: DateTime(2026, 1, 1),
        title: 'Ridge run',
      );
      final row = (await repo.getActivity('a'))!;
      final json = ser.activityToJson(row);

      // Re-insert into a fresh DB via the companion mapping.
      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      await db2.into(db2.activities).insert(ser.activityFromJson(json));
      final restored = await (db2.select(
        db2.activities,
      )..where((t) => t.id.equals('a'))).getSingle();
      expect(restored.title, 'Ridge run');
      expect(restored.activityType, 'trail_run');
      await db2.close();
    });

    test('track point survives json → companion round trip', () async {
      await repo.createActivity(
        id: 'a',
        type: ActivityType.walk,
        startedAt: DateTime(2026, 1, 1),
      );
      await repo.insertTrackPoints(
        'a',
        [
          RecordedPoint(
            sequence: 0,
            latitude: 37.5,
            longitude: 127.1,
            recordedAt: DateTime(2026, 1, 1, 0, 0, 30),
            gpsAltitude: 250,
            accuracy: 8,
            segmentIndex: 2,
            isAccepted: false,
          ),
        ],
        ['p0'],
      );
      final row = (await repo.getTrackPoints('a')).single;
      final json = ser.trackPointToJson(row);

      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      // Need the parent activity for the FK.
      await ActivityRepository(db2).createActivity(
        id: 'a',
        type: ActivityType.walk,
        startedAt: DateTime(2026, 1, 1),
      );
      await db2.into(db2.trackPoints).insert(ser.trackPointFromJson(json));
      final restored = (await ActivityRepository(
        db2,
      ).getTrackPoints('a')).single;
      expect(restored.gpsAltitude, 250);
      expect(restored.segmentIndex, 2);
      expect(restored.isAccepted, isFalse);
      await db2.close();
    });
  });
}
