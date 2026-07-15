import 'dart:math' as math;

import '../../core/utils/activity_type.dart';
import '../../core/utils/geo_math.dart';
import 'models/recorded_point.dart';

/// Aggregate statistics for a recording, computed from its accepted points and
/// the pause bookkeeping (spec §17). Pure and unit-testable.
class ActivityStats {
  const ActivityStats({
    required this.totalDistanceMeters,
    required this.movingSeconds,
    required this.elapsedSeconds,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.minAltitude,
    required this.maxAltitude,
    required this.elevationGain,
    required this.elevationLoss,
    this.calories = 0,
  });

  /// Cumulative distance over accepted points, not bridging segment breaks (m).
  final double totalDistanceMeters;

  /// Active (non-paused) duration in seconds.
  final double movingSeconds;

  /// Wall-clock duration start→end in seconds.
  final double elapsedSeconds;

  /// Average speed over moving time (m/s).
  final double averageSpeed;

  /// Peak instantaneous speed (m/s).
  final double maxSpeed;

  final double? minAltitude;
  final double? maxAltitude;

  /// Cumulative ascent / descent (m), noise-filtered.
  final double elevationGain;
  final double elevationLoss;

  /// Estimated energy expenditure (kcal). 0 when body weight is unknown or the
  /// activity has no moving time. See [ActivityStatsCalculator.compute].
  final double calories;

  static const empty = ActivityStats(
    totalDistanceMeters: 0,
    movingSeconds: 0,
    elapsedSeconds: 0,
    averageSpeed: 0,
    maxSpeed: 0,
    minAltitude: null,
    maxAltitude: null,
    elevationGain: 0,
    elevationLoss: 0,
  );
}

/// Computes [ActivityStats] from a list of points.
///
/// Design choices (documented for tests):
///  - Distance is summed only between consecutive points **in the same
///    segment** — segment breaks (GPS gaps) are not counted as travel (spec §6).
///  - Only accepted points contribute (spec §6).
///  - Elevation gain/loss uses a threshold noise filter: only deltas exceeding
///    [elevationNoiseMeters] between "kept" samples accumulate, which suppresses
///    GPS altitude jitter (spec §8).
class ActivityStatsCalculator {
  const ActivityStatsCalculator({this.elevationNoiseMeters = 3.0});

  /// Minimum altitude change (m) to count toward gain/loss. Filters jitter.
  final double elevationNoiseMeters;

  ActivityStats compute({
    required List<RecordedPoint> points,
    required DateTime? startedAt,
    required DateTime? endedAt,
    required Duration pausedDuration,
    ActivityType? activityType,
    double? bodyWeightKg,
  }) {
    final accepted = points.where((p) => p.isAccepted).toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    if (accepted.isEmpty) {
      return ActivityStats.empty;
    }

    double distance = 0;
    double maxSpeed = 0;
    double? minAlt;
    double? maxAlt;

    for (var i = 0; i < accepted.length; i++) {
      final p = accepted[i];

      // Speed: prefer reported instantaneous speed; fall back to segment-local
      // distance/time between consecutive same-segment points.
      final s = p.speed;
      if (s != null && s.isFinite && s >= 0) {
        maxSpeed = math.max(maxSpeed, s);
      }

      // Distance (same-segment only).
      if (i > 0) {
        final prev = accepted[i - 1];
        if (prev.segmentIndex == p.segmentIndex) {
          final d = GeoMath.haversineMeters(
            prev.latitude,
            prev.longitude,
            p.latitude,
            p.longitude,
          );
          distance += d;
          if (s == null) {
            final dt =
                p.recordedAt.difference(prev.recordedAt).inMilliseconds /
                1000.0;
            if (dt > 0) maxSpeed = math.max(maxSpeed, d / dt);
          }
        }
      }

      final alt = p.displayAltitude;
      if (alt != null) {
        minAlt = (minAlt == null) ? alt : math.min(minAlt, alt);
        maxAlt = (maxAlt == null) ? alt : math.max(maxAlt, alt);
      }
    }

    final elevation = _elevation(accepted);

    final elapsed = (startedAt != null && endedAt != null)
        ? endedAt.difference(startedAt).inMilliseconds / 1000.0
        : accepted.last.recordedAt
                  .difference(accepted.first.recordedAt)
                  .inMilliseconds /
              1000.0;

    final moving = math.max(
      0.0,
      elapsed - pausedDuration.inMilliseconds / 1000.0,
    );

    final avgSpeed = moving > 0 ? distance / moving : 0.0;

    final calories = _calories(
      activityType: activityType,
      bodyWeightKg: bodyWeightKg,
      movingSeconds: moving,
      avgSpeedMps: avgSpeed,
    );

    return ActivityStats(
      totalDistanceMeters: distance,
      movingSeconds: moving,
      elapsedSeconds: elapsed,
      averageSpeed: avgSpeed,
      maxSpeed: maxSpeed,
      minAltitude: minAlt,
      maxAltitude: maxAlt,
      elevationGain: elevation.$1,
      elevationLoss: elevation.$2,
      calories: calories,
    );
  }

  /// Energy estimate: `kcal = MET × weightKg × hours`, with a mild speed-based
  /// adjustment so a fast run burns more than a slow jog of the same duration.
  /// Returns 0 when the type or weight is unknown (nothing to base it on).
  double _calories({
    required ActivityType? activityType,
    required double? bodyWeightKg,
    required double movingSeconds,
    required double avgSpeedMps,
  }) {
    if (activityType == null || bodyWeightKg == null || bodyWeightKg <= 0) {
      return 0;
    }
    if (movingSeconds <= 0) return 0;

    // Reference speeds (m/s) the base MET roughly corresponds to. Scale MET by
    // (actual / reference), clamped to a sane band so GPS noise or a brisk
    // stretch doesn't produce wild numbers.
    const refSpeed = <ActivityType, double>{
      ActivityType.walk: 1.4, // ~5 km/h
      ActivityType.run: 2.5, // ~9 km/h
      ActivityType.hike: 1.1, // ~4 km/h
      ActivityType.trailRun: 2.5,
      ActivityType.cycle: 5.0, // ~18 km/h
    };
    final ref = refSpeed[activityType] ?? 1.4;
    final factor = ref > 0 ? (avgSpeedMps / ref).clamp(0.6, 1.8) : 1.0;
    final met = activityType.met * factor;

    final hours = movingSeconds / 3600.0;
    return met * bodyWeightKg * hours;
  }

  /// Returns (gain, loss) using a threshold noise filter over display altitude.
  /// A reference altitude is held; only when the current sample deviates from
  /// it by more than [elevationNoiseMeters] is the delta booked and the
  /// reference advanced. This removes small oscillations from GPS jitter.
  (double, double) _elevation(List<RecordedPoint> accepted) {
    double gain = 0;
    double loss = 0;
    double? ref;
    for (final p in accepted) {
      final alt = p.displayAltitude;
      if (alt == null) continue;
      if (ref == null) {
        ref = alt;
        continue;
      }
      final delta = alt - ref;
      if (delta.abs() >= elevationNoiseMeters) {
        if (delta > 0) {
          gain += delta;
        } else {
          loss += -delta;
        }
        ref = alt;
      }
    }
    return (gain, loss);
  }
}
