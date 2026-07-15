import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/core/database/app_database.dart';
import 'package:trailtrack/features/dashboard/dashboard_summary.dart';

void main() {
  ActivityRow row({
    required String id,
    String status = 'completed',
    double distance = 0,
    int active = 0,
    double? maxAlt,
    double gain = 0,
  }) => ActivityRow(
    id: id,
    title: '',
    activityType: 'run',
    status: status,
    startedAt: 0,
    endedAt: null,
    elapsedSeconds: 0,
    activeSeconds: active,
    totalDistanceMeters: distance,
    averageSpeed: 0,
    maxSpeed: 0,
    minimumAltitude: null,
    maximumAltitude: maxAlt,
    elevationGain: gain,
    elevationLoss: 0,
    calories: 0,
    memo: null,
    representativePhotoId: null,
    lastSequence: -1,
    lastLatitude: null,
    lastLongitude: null,
    createdAt: 0,
    updatedAt: 0,
  );

  test('empty list → empty summary', () {
    expect(DashboardSummary.fromActivities([]).activityCount, 0);
  });

  test('aggregates only completed activities', () {
    final s = DashboardSummary.fromActivities([
      row(id: 'a', distance: 5000, active: 1000, maxAlt: 300, gain: 100),
      row(id: 'b', distance: 3000, active: 500, maxAlt: 500, gain: 50),
      row(id: 'c', status: 'recording', distance: 9999, active: 9999),
    ]);
    expect(s.activityCount, 2);
    expect(s.totalDistanceMeters, 8000);
    expect(s.totalActiveSeconds, 1500);
    expect(s.maxAltitude, 500);
    expect(s.totalElevationGain, 150);
    // avg = 8000 / 1500
    expect(s.averageSpeed, closeTo(5.333, 0.01));
  });
}
