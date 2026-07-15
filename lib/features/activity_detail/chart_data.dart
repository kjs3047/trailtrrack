import '../../core/utils/geo_math.dart';
import '../recording/models/recorded_point.dart';

/// A single (x, y) sample for a chart line.
class ChartSample {
  const ChartSample(this.x, this.y);
  final double x;
  final double y;
}

/// Derives chart series from a track's accepted points. Pure and testable.
class ActivityChartData {
  const ActivityChartData({
    required this.elevationByDistance,
    required this.speedByTime,
    required this.maxDistanceKm,
    required this.maxElevation,
    required this.minElevation,
    required this.maxSpeedKmh,
    required this.durationSeconds,
  });

  /// Elevation (m) vs cumulative distance (km).
  final List<ChartSample> elevationByDistance;

  /// Speed (km/h) vs elapsed time (seconds from start).
  final List<ChartSample> speedByTime;

  final double maxDistanceKm;
  final double maxElevation;
  final double minElevation;
  final double maxSpeedKmh;
  final double durationSeconds;

  bool get hasElevation => elevationByDistance.any((s) => s.y != 0);
  bool get isEmpty => elevationByDistance.isEmpty && speedByTime.isEmpty;

  static ActivityChartData fromPoints(List<RecordedPoint> points) {
    final accepted = points.where((p) => p.isAccepted).toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    if (accepted.isEmpty) {
      return const ActivityChartData(
        elevationByDistance: [],
        speedByTime: [],
        maxDistanceKm: 0,
        maxElevation: 0,
        minElevation: 0,
        maxSpeedKmh: 0,
        durationSeconds: 0,
      );
    }

    final elevation = <ChartSample>[];
    final speed = <ChartSample>[];
    double cumDist = 0;
    double maxElev = double.negativeInfinity;
    double minElev = double.infinity;
    double maxSpeed = 0;
    final start = accepted.first.recordedAt;

    for (var i = 0; i < accepted.length; i++) {
      final p = accepted[i];
      if (i > 0) {
        final prev = accepted[i - 1];
        if (prev.segmentIndex == p.segmentIndex) {
          cumDist += GeoMath.haversineMeters(
            prev.latitude,
            prev.longitude,
            p.latitude,
            p.longitude,
          );
        }
      }
      final alt = p.displayAltitude;
      if (alt != null) {
        elevation.add(ChartSample(cumDist / 1000, alt));
        if (alt > maxElev) maxElev = alt;
        if (alt < minElev) minElev = alt;
      }

      final elapsed = p.recordedAt.difference(start).inMilliseconds / 1000.0;
      // km/h; prefer reported speed, else derive from the local leg.
      double kmh = 0;
      final s = p.speed;
      if (s != null && s.isFinite && s >= 0) {
        kmh = s * 3.6;
      } else if (i > 0) {
        final prev = accepted[i - 1];
        final dt =
            p.recordedAt.difference(prev.recordedAt).inMilliseconds / 1000.0;
        if (dt > 0 && prev.segmentIndex == p.segmentIndex) {
          final d = GeoMath.haversineMeters(
            prev.latitude,
            prev.longitude,
            p.latitude,
            p.longitude,
          );
          kmh = (d / dt) * 3.6;
        }
      }
      if (kmh > maxSpeed) maxSpeed = kmh;
      speed.add(ChartSample(elapsed, kmh));
    }

    final duration =
        accepted.last.recordedAt.difference(start).inMilliseconds / 1000.0;

    return ActivityChartData(
      elevationByDistance: elevation,
      speedByTime: speed,
      maxDistanceKm: cumDist / 1000,
      maxElevation: maxElev.isFinite ? maxElev : 0,
      minElevation: minElev.isFinite ? minElev : 0,
      maxSpeedKmh: maxSpeed,
      durationSeconds: duration,
    );
  }
}
