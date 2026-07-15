import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/core/utils/activity_type.dart';
import 'package:trailtrack/features/recording/activity_stats.dart';
import 'package:trailtrack/features/recording/models/recorded_point.dart';

void main() {
  final start = DateTime(2026, 1, 1, 10, 0, 0);
  const calc = ActivityStatsCalculator();

  RecordedPoint pt(
    int seq,
    double lat,
    double lon, {
    double? alt,
    double? speed,
    int seg = 0,
    int tSec = 0,
    bool accepted = true,
  }) => RecordedPoint(
    sequence: seq,
    latitude: lat,
    longitude: lon,
    recordedAt: start.add(Duration(seconds: tSec)),
    gpsAltitude: alt,
    speed: speed,
    segmentIndex: seg,
    isAccepted: accepted,
  );

  test('empty points → empty stats', () {
    final s = calc.compute(
      points: const [],
      startedAt: start,
      endedAt: start,
      pausedDuration: Duration.zero,
    );
    expect(s.totalDistanceMeters, 0);
    expect(s.averageSpeed, 0);
  });

  test('cumulative distance sums consecutive same-segment legs', () {
    // Three points ~1 degree lon apart at the equator (~111 km each leg).
    final pts = [
      pt(0, 0, 0, tSec: 0),
      pt(1, 0, 1, tSec: 100),
      pt(2, 0, 2, tSec: 200),
    ];
    final s = calc.compute(
      points: pts,
      startedAt: start,
      endedAt: start.add(const Duration(seconds: 200)),
      pausedDuration: Duration.zero,
    );
    expect(s.totalDistanceMeters / 1000, closeTo(222.4, 2)); // 2 * 111.2 km
  });

  test('does not bridge distance across a segment break', () {
    final pts = [
      pt(0, 0, 0, tSec: 0, seg: 0),
      pt(1, 0, 1, tSec: 100, seg: 0),
      // GPS gap → new segment; the jump to seg 1 must NOT be counted.
      pt(2, 0, 5, tSec: 300, seg: 1),
      pt(3, 0, 6, tSec: 400, seg: 1),
    ];
    final s = calc.compute(
      points: pts,
      startedAt: start,
      endedAt: start.add(const Duration(seconds: 400)),
      pausedDuration: Duration.zero,
    );
    // Only leg0 (0→1) + leg within seg1 (5→6) = ~222.4 km, NOT the 1→5 gap.
    expect(s.totalDistanceMeters / 1000, closeTo(222.4, 2));
  });

  test('excludes rejected points', () {
    final pts = [
      pt(0, 0, 0, tSec: 0),
      pt(1, 0, 5, tSec: 50, accepted: false), // outlier, ignored
      pt(2, 0, 1, tSec: 100),
    ];
    final s = calc.compute(
      points: pts,
      startedAt: start,
      endedAt: start.add(const Duration(seconds: 100)),
      pausedDuration: Duration.zero,
    );
    expect(s.totalDistanceMeters / 1000, closeTo(111.2, 2)); // 0→1 only
  });

  test('average speed uses moving (non-paused) time', () {
    final pts = [
      pt(0, 0, 0, tSec: 0),
      pt(1, 0, 1, tSec: 200), // ~111.2 km
    ];
    final s = calc.compute(
      points: pts,
      startedAt: start,
      endedAt: start.add(const Duration(seconds: 200)),
      pausedDuration: const Duration(seconds: 100), // half paused
    );
    expect(s.elapsedSeconds, 200);
    expect(s.movingSeconds, 100);
    // avg = distance / moving = 111195 / 100 ≈ 1112 m/s
    expect(s.averageSpeed, closeTo(1111.95, 2));
  });

  test('max speed picks the peak reported speed', () {
    final pts = [
      pt(0, 0, 0, tSec: 0, speed: 2),
      pt(1, 0, 0.001, tSec: 10, speed: 9.5),
      pt(2, 0, 0.002, tSec: 20, speed: 4),
    ];
    final s = calc.compute(
      points: pts,
      startedAt: start,
      endedAt: start.add(const Duration(seconds: 20)),
      pausedDuration: Duration.zero,
    );
    expect(s.maxSpeed, 9.5);
  });

  group('elevation gain/loss with noise filter', () {
    test('accumulates real climbs, ignores small jitter', () {
      // Real climb 100→150 (+50), tiny jitter, then descent 150→120 (-30).
      final pts = [
        pt(0, 0, 0, tSec: 0, alt: 100),
        pt(1, 0, 0.001, tSec: 10, alt: 101), // +1 jitter (<3) ignored
        pt(2, 0, 0.002, tSec: 20, alt: 150), // climb booked
        pt(3, 0, 0.003, tSec: 30, alt: 149), // -1 jitter ignored
        pt(4, 0, 0.004, tSec: 40, alt: 120), // descent booked
      ];
      final s = calc.compute(
        points: pts,
        startedAt: start,
        endedAt: start.add(const Duration(seconds: 40)),
        pausedDuration: Duration.zero,
      );
      expect(s.elevationGain, closeTo(50, 0.001));
      expect(s.elevationLoss, closeTo(30, 0.001));
      expect(s.minAltitude, 100);
      expect(s.maxAltitude, 150);
    });

    test('flat track has zero gain/loss', () {
      final pts = [
        pt(0, 0, 0, tSec: 0, alt: 200),
        pt(1, 0, 0.001, tSec: 10, alt: 201),
        pt(2, 0, 0.002, tSec: 20, alt: 199),
      ];
      final s = calc.compute(
        points: pts,
        startedAt: start,
        endedAt: start.add(const Duration(seconds: 20)),
        pausedDuration: Duration.zero,
      );
      expect(s.elevationGain, 0);
      expect(s.elevationLoss, 0);
    });
  });

  group('calories', () {
    // A 1000 s walk at ~1.4 m/s (the walk reference speed), 65 kg.
    // factor≈1.0 → MET≈3.5 → kcal = 3.5 * 65 * (1000/3600) ≈ 63.2.
    List<RecordedPoint> walkPoints() => [
      pt(0, 37.5665, 126.9780, tSec: 0, speed: 1.4),
      // ~1.4 m/s eastward: 0.0126 deg lon ≈ 1113 m over 1000 s ≈ 1.11 m/s.
      pt(1, 37.5665, 126.9906, tSec: 1000, speed: 1.4),
    ];

    test('zero when body weight is unknown', () {
      final s = calc.compute(
        points: walkPoints(),
        startedAt: start,
        endedAt: start.add(const Duration(seconds: 1000)),
        pausedDuration: Duration.zero,
        activityType: ActivityType.walk,
        // bodyWeightKg omitted
      );
      expect(s.calories, 0);
    });

    test('zero when activity type is unknown', () {
      final s = calc.compute(
        points: walkPoints(),
        startedAt: start,
        endedAt: start.add(const Duration(seconds: 1000)),
        pausedDuration: Duration.zero,
        bodyWeightKg: 65,
      );
      expect(s.calories, 0);
    });

    test('walk estimate is in the expected ballpark', () {
      final s = calc.compute(
        points: walkPoints(),
        startedAt: start,
        endedAt: start.add(const Duration(seconds: 1000)),
        pausedDuration: Duration.zero,
        activityType: ActivityType.walk,
        bodyWeightKg: 65,
      );
      // MET 3.5 × 65 kg × (1000/3600) h ≈ 63 kcal, ± speed-factor band.
      expect(s.calories, greaterThan(35));
      expect(s.calories, lessThan(120));
    });

    test('running burns more than walking for the same duration/weight', () {
      final run = calc.compute(
        points: walkPoints(),
        startedAt: start,
        endedAt: start.add(const Duration(seconds: 1000)),
        pausedDuration: Duration.zero,
        activityType: ActivityType.run,
        bodyWeightKg: 65,
      );
      final walk = calc.compute(
        points: walkPoints(),
        startedAt: start,
        endedAt: start.add(const Duration(seconds: 1000)),
        pausedDuration: Duration.zero,
        activityType: ActivityType.walk,
        bodyWeightKg: 65,
      );
      expect(run.calories, greaterThan(walk.calories));
    });

    test('scales roughly linearly with body weight', () {
      ActivityStats forWeight(double kg) => calc.compute(
        points: walkPoints(),
        startedAt: start,
        endedAt: start.add(const Duration(seconds: 1000)),
        pausedDuration: Duration.zero,
        activityType: ActivityType.walk,
        bodyWeightKg: kg,
      );
      final light = forWeight(50).calories;
      final heavy = forWeight(100).calories;
      // Same speed → same MET factor → linear in weight (100/50 = 2×).
      expect(heavy / light, closeTo(2.0, 0.01));
    });
  });
}
