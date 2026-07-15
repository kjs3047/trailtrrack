import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/core/database/app_database.dart';
import 'package:trailtrack/core/utils/activity_type.dart';
import 'package:trailtrack/features/recording/activity_stats.dart';
import 'package:trailtrack/features/recording/data/activity_repository.dart';
import 'package:trailtrack/features/recording/models/recorded_point.dart';

void main() {
  late AppDatabase db;
  late ActivityRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ActivityRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  final start = DateTime(2026, 1, 1, 8, 0, 0);

  test('create → insert points → finalize → read back', () async {
    await repo.createActivity(
      id: 'a1',
      type: ActivityType.hike,
      startedAt: start,
      title: 'Test Hike',
    );

    final points = <RecordedPoint>[
      RecordedPoint(
        sequence: 0,
        latitude: 0,
        longitude: 0,
        recordedAt: start,
        gpsAltitude: 100,
      ),
      RecordedPoint(
        sequence: 1,
        latitude: 0,
        longitude: 1,
        recordedAt: start.add(const Duration(seconds: 100)),
        gpsAltitude: 150,
      ),
    ];
    await repo.insertTrackPoints('a1', points, ['p0', 'p1']);

    final read = await repo.getTrackPoints('a1');
    expect(read.length, 2);
    expect(read.first.sequence, 0);
    expect(read.last.gpsAltitude, 150);

    const calc = ActivityStatsCalculator();
    final stats = calc.compute(
      points: points,
      startedAt: start,
      endedAt: start.add(const Duration(seconds: 100)),
      pausedDuration: Duration.zero,
    );
    await repo.finalizeActivity(
      activityId: 'a1',
      endedAt: start.add(const Duration(seconds: 100)),
      stats: stats,
    );

    final row = await repo.getActivity('a1');
    expect(row!.status, 'completed');
    expect(row.totalDistanceMeters, greaterThan(0));
    expect(row.elevationGain, closeTo(50, 0.001));
    expect(row.maximumAltitude, 150);
  });

  test('cascade delete removes track points', () async {
    await repo.createActivity(
      id: 'a2',
      type: ActivityType.run,
      startedAt: start,
    );
    await repo.insertTrackPoints(
      'a2',
      [
        RecordedPoint(
          sequence: 0,
          latitude: 1,
          longitude: 1,
          recordedAt: start,
        ),
      ],
      ['pp0'],
    );
    expect((await repo.getTrackPoints('a2')).length, 1);

    await repo.deleteActivity('a2');
    expect(await repo.getActivity('a2'), isNull);
    // Foreign-key cascade: points gone too.
    expect((await repo.getTrackPoints('a2')).length, 0);
  });

  test('recoverable activities are those left recording/paused', () async {
    await repo.createActivity(
      id: 'live',
      type: ActivityType.walk,
      startedAt: start,
    );
    await repo.createActivity(
      id: 'done',
      type: ActivityType.walk,
      startedAt: start,
    );
    await repo.finalizeActivity(
      activityId: 'done',
      endedAt: start,
      stats: ActivityStats.empty,
    );

    final recoverable = await repo.getRecoverableActivities();
    expect(recoverable.map((a) => a.id), contains('live'));
    expect(recoverable.map((a) => a.id), isNot(contains('done')));
  });

  test('snapshot update persists last position and distance', () async {
    await repo.createActivity(
      id: 'a3',
      type: ActivityType.cycle,
      startedAt: start,
    );
    await repo.updateSnapshot(
      activityId: 'a3',
      lastSequence: 42,
      distanceMeters: 1234.5,
      lastLat: 37.5,
      lastLon: 127.0,
    );
    final row = await repo.getActivity('a3');
    expect(row!.lastSequence, 42);
    expect(row.totalDistanceMeters, 1234.5);
    expect(row.lastLatitude, 37.5);
  });
}
