import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/core/database/app_database.dart';
import 'package:trailtrack/core/location/location_source.dart';
import 'package:trailtrack/core/utils/activity_type.dart';
import 'package:trailtrack/features/recording/data/activity_repository.dart';
import 'package:trailtrack/features/recording/gps_validator.dart';
import 'package:trailtrack/features/recording/recording_controller.dart';
import 'package:trailtrack/features/recording/recording_state.dart';

/// A fake GPS source that lets the test push [RawFix]es on demand (spec §17
/// Mock GPS).
class FakeLocationSource implements LocationSource {
  final _fixes = StreamController<RawFix>.broadcast();
  final _errors = StreamController<String>.broadcast();
  bool _running = false;

  void emit(RawFix fix) => _fixes.add(fix);

  @override
  Stream<RawFix> get fixes => _fixes.stream;
  @override
  Stream<String> get errors => _errors.stream;
  @override
  bool get isRunning => _running;

  @override
  Future<bool> start({
    required int distanceFilterMeters,
    String notificationTitle = '',
    String notificationText = '',
  }) async {
    _running = true;
    return true;
  }

  @override
  Future<void> updateNotification({
    required String title,
    required String text,
  }) async {}
  @override
  Future<void> setDistanceFilter(int meters) async {}
  @override
  Future<void> stop() async => _running = false;
  @override
  Future<void> dispose() async {
    await _fixes.close();
    await _errors.close();
  }
}

void main() {
  late AppDatabase db;
  late ActivityRepository repo;
  late FakeLocationSource location;
  late RecordingController controller;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ActivityRepository(db);
    location = FakeLocationSource();
    controller = RecordingController(
      locationService: location,
      repository: repo,
    );
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  RawFix fix(
    double lat,
    double lon,
    DateTime t, {
    double? alt,
    double? acc = 5,
    double? speed,
  }) => RawFix(
    latitude: lat,
    longitude: lon,
    timestamp: t,
    altitude: alt,
    accuracy: acc,
    speed: speed,
  );

  test('full flow: start → mock GPS → pause → resume → stop → stats', () async {
    final t0 = DateTime(2026, 1, 1, 9, 0, 0);
    await controller.start(ActivityType.run);
    expect(controller.state.status, RecordingStatus.recording);
    expect(controller.state.activityId, isNotNull);

    // Feed a moving track: ~11 m every 10 s → plausible for a run.
    location.emit(fix(37.5000, 127.0, t0, alt: 100));
    await Future<void>.delayed(Duration.zero);
    location.emit(
      fix(37.5001, 127.0, t0.add(const Duration(seconds: 10)), alt: 105),
    );
    await Future<void>.delayed(Duration.zero);
    location.emit(
      fix(37.5002, 127.0, t0.add(const Duration(seconds: 20)), alt: 110),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.acceptedCount, 3);
    expect(controller.state.stats.totalDistanceMeters, greaterThan(0));

    await controller.pause();
    expect(controller.state.status, RecordingStatus.paused);

    await controller.resume();
    expect(controller.state.status, RecordingStatus.recording);

    final id = await controller.stop();
    expect(controller.state.status, RecordingStatus.completed);

    // Persisted?
    final row = await repo.getActivity(id!);
    expect(row!.status, 'completed');
    final points = await repo.getTrackPoints(id);
    expect(points.length, 3);
    expect(row.totalDistanceMeters, greaterThan(0));
    expect(row.elevationGain, greaterThan(0)); // 100→110 climb
  });

  test('rejects outliers but stores originals', () async {
    final t0 = DateTime(2026, 1, 1, 9, 0, 0);
    await controller.start(ActivityType.walk); // maxSpeed 4.2 m/s
    location.emit(fix(37.5, 127.0, t0));
    await Future<void>.delayed(Duration.zero);
    // Teleport ~1.1 km in 2 s → rejected.
    location.emit(fix(37.51, 127.0, t0.add(const Duration(seconds: 2))));
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.acceptedCount, 1);
    expect(controller.state.rejectedCount, 1);

    final id = await controller.stop();
    // Both the accepted and rejected originals are stored (spec §6/§20).
    final points = await repo.getTrackPoints(id!);
    expect(points.length, 2);
    expect(points.where((p) => p.isAccepted).length, 1);
    expect(points.where((p) => !p.isAccepted).length, 1);
  });

  test('discard removes the activity', () async {
    await controller.start(ActivityType.hike);
    final id = controller.state.activityId;
    await controller.discard();
    expect(controller.state.status, RecordingStatus.idle);
    expect(await repo.getActivity(id!), isNull);
  });
}
