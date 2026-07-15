import '../../core/utils/geo_math.dart';
import '../recording/models/recorded_point.dart';

/// Result of matching a photo's capture time to the nearest valid GPS fix.
class PhotoLocationMatch {
  const PhotoLocationMatch({
    this.latitude,
    this.longitude,
    this.gpsAltitude,
    this.demAltitude,
    required this.elapsedSeconds,
    required this.distanceMeters,
  });

  final double? latitude;
  final double? longitude;
  final double? gpsAltitude;
  final double? demAltitude;
  final int elapsedSeconds;
  final double distanceMeters;

  bool get hasLocation => latitude != null && longitude != null;
}

/// Matches a photo's [takenAt] to the closest-in-time **accepted** track point
/// (spec §9), and reports the elapsed time + cumulative distance at that point.
/// Pure so it is unit-testable.
class PhotoLocationMatcher {
  const PhotoLocationMatcher();

  PhotoLocationMatch match({
    required DateTime takenAt,
    required List<RecordedPoint> points,
    required DateTime activityStart,
  }) {
    final accepted = points.where((p) => p.isAccepted).toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    if (accepted.isEmpty) {
      return PhotoLocationMatch(
        elapsedSeconds: takenAt
            .difference(activityStart)
            .inSeconds
            .clamp(0, 1 << 31),
        distanceMeters: 0,
      );
    }

    // Nearest-in-time accepted point.
    RecordedPoint best = accepted.first;
    int bestDeltaMs = 1 << 62;
    int bestIndex = 0;
    for (var i = 0; i < accepted.length; i++) {
      final delta = accepted[i].recordedAt
          .difference(takenAt)
          .inMilliseconds
          .abs();
      if (delta < bestDeltaMs) {
        bestDeltaMs = delta;
        best = accepted[i];
        bestIndex = i;
      }
    }

    // Cumulative distance up to the matched point (same-segment legs only).
    double cumDist = 0;
    for (var i = 1; i <= bestIndex; i++) {
      final prev = accepted[i - 1];
      final cur = accepted[i];
      if (prev.segmentIndex == cur.segmentIndex) {
        cumDist += GeoMath.haversineMeters(
          prev.latitude,
          prev.longitude,
          cur.latitude,
          cur.longitude,
        );
      }
    }

    final elapsed = best.recordedAt.difference(activityStart).inSeconds;
    return PhotoLocationMatch(
      latitude: best.latitude,
      longitude: best.longitude,
      gpsAltitude: best.gpsAltitude,
      demAltitude: best.demAltitude,
      elapsedSeconds: elapsed.clamp(0, 1 << 31),
      distanceMeters: cumDist,
    );
  }
}
