import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/features/activity_detail/chart_data.dart';
import 'package:trailtrack/features/dashboard/dashboard_charts_data.dart';
import 'package:trailtrack/core/database/app_database.dart';
import 'package:trailtrack/features/recording/models/recorded_point.dart';

void main() {
  final start = DateTime(2026, 1, 5, 9, 0, 0); // a Monday

  RecordedPoint pt(
    int seq,
    double lat,
    double lon, {
    double? alt,
    double? speed,
    int seg = 0,
    int tSec = 0,
  }) => RecordedPoint(
    sequence: seq,
    latitude: lat,
    longitude: lon,
    recordedAt: start.add(Duration(seconds: tSec)),
    gpsAltitude: alt,
    speed: speed,
    segmentIndex: seg,
  );

  group('ActivityChartData', () {
    test('empty points → empty', () {
      final d = ActivityChartData.fromPoints(const []);
      expect(d.isEmpty, isTrue);
    });

    test('elevation series follows display altitude vs distance', () {
      final d = ActivityChartData.fromPoints([
        pt(0, 0, 0, alt: 100, tSec: 0),
        pt(1, 0, 1, alt: 150, tSec: 100),
      ]);
      expect(d.elevationByDistance.length, 2);
      expect(d.elevationByDistance.first.y, 100);
      expect(d.elevationByDistance.last.y, 150);
      expect(d.maxElevation, 150);
      expect(d.minElevation, 100);
      // ~111 km between the two points.
      expect(d.maxDistanceKm, closeTo(111.2, 2));
    });

    test('speed series uses reported speed when present', () {
      final d = ActivityChartData.fromPoints([
        pt(0, 0, 0, speed: 2, tSec: 0),
        pt(1, 0, 0.001, speed: 5, tSec: 10),
      ]);
      expect(d.speedByTime.length, 2);
      expect(d.maxSpeedKmh, closeTo(18, 0.1)); // 5 m/s * 3.6
    });
  });

  group('WeeklyDistance', () {
    ActivityRow row(
      String id,
      int startedAt,
      double dist, {
      String status = 'completed',
    }) => ActivityRow(
      id: id,
      title: '',
      activityType: 'run',
      status: status,
      startedAt: startedAt,
      endedAt: null,
      elapsedSeconds: 0,
      activeSeconds: 0,
      totalDistanceMeters: dist,
      averageSpeed: 0,
      maxSpeed: 0,
      minimumAltitude: null,
      maximumAltitude: null,
      elevationGain: 0,
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

    test('buckets distance into Mon..Sun of the current week', () {
      // "now" is Wed of the same week as `start` (Monday).
      final now = start.add(const Duration(days: 2));
      final mon = row('a', start.millisecondsSinceEpoch, 5000);
      final wed = row(
        'b',
        start.add(const Duration(days: 2)).millisecondsSinceEpoch,
        3000,
      );
      final w = WeeklyDistance.fromActivities([mon, wed], now);
      expect(w.bars[0], closeTo(5.0, 0.001)); // Monday
      expect(w.bars[2], closeTo(3.0, 0.001)); // Wednesday
      expect(w.maxKm, closeTo(5.0, 0.001));
    });
  });

  group('TypeBreakdown', () {
    ActivityRow typed(String id, String type) => ActivityRow(
      id: id,
      title: '',
      activityType: type,
      status: 'completed',
      startedAt: 0,
      endedAt: null,
      elapsedSeconds: 0,
      activeSeconds: 0,
      totalDistanceMeters: 0,
      averageSpeed: 0,
      maxSpeed: 0,
      minimumAltitude: null,
      maximumAltitude: null,
      elevationGain: 0,
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

    test('counts by type', () {
      final b = TypeBreakdown.fromActivities([
        typed('a', 'run'),
        typed('b', 'run'),
        typed('c', 'hike'),
      ]);
      expect(b.total, 3);
      expect(b.slices.length, 2);
    });
  });
}
