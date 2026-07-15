import '../../core/utils/activity_type.dart';
import '../../core/utils/geo_math.dart';
import 'models/recorded_point.dart';

/// The outcome of validating one incoming GPS fix against the running track.
class GpsValidationResult {
  const GpsValidationResult({
    required this.accepted,
    required this.segmentIndex,
    this.rejectReason,
  });

  final bool accepted;
  final int segmentIndex;
  final GpsRejectReason? rejectReason;
}

enum GpsRejectReason { lowAccuracy, duplicate, teleport, implausibleSpeed }

/// A raw incoming fix, decoupled from the geolocator plugin type so the
/// validator is unit-testable (spec §17).
class RawFix {
  const RawFix({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
  });

  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final DateTime timestamp;
}

/// Validates incoming GPS fixes against a per-activity-type [GpsProfile]
/// (spec §6). Stateful across a single recording: it tracks the last accepted
/// point and the current segment index. A gap in time starts a new segment;
/// segments are never bridged with a straight line.
class GpsValidator {
  GpsValidator({required this.profile, Duration? gapThreshold})
    : gapThreshold = gapThreshold ?? const Duration(seconds: 20);

  final GpsProfile profile;

  /// A time gap larger than this since the last accepted fix starts a new
  /// segment (GPS considered dropped).
  final Duration gapThreshold;

  RecordedPoint? _lastAccepted;
  int _segmentIndex = 0;

  RecordedPoint? get lastAccepted => _lastAccepted;
  int get currentSegment => _segmentIndex;

  /// Minimum duplicate-distance threshold: below this and within a short time,
  /// the point is treated as a stationary duplicate.
  static const double _duplicateMeters = 1.0;

  GpsValidationResult validate(RawFix fix) {
    // 1) Accuracy filter.
    if (fix.accuracy != null && fix.accuracy! > profile.minAccuracyMeters) {
      return GpsValidationResult(
        accepted: false,
        segmentIndex: _segmentIndex,
        rejectReason: GpsRejectReason.lowAccuracy,
      );
    }

    final last = _lastAccepted;
    if (last == null) {
      // First accepted point of the recording.
      return const GpsValidationResult(accepted: true, segmentIndex: 0);
    }

    final dtSeconds =
        fix.timestamp.difference(last.recordedAt).inMilliseconds / 1000.0;

    // A backwards or zero-time fix is unusable.
    if (dtSeconds <= 0) {
      return GpsValidationResult(
        accepted: false,
        segmentIndex: _segmentIndex,
        rejectReason: GpsRejectReason.duplicate,
      );
    }

    final distance = GeoMath.haversineMeters(
      last.latitude,
      last.longitude,
      fix.latitude,
      fix.longitude,
    );

    // 2) Segment break: long time gap → new segment. Evaluated before the
    //    duplicate/speed checks because after a gap we accept the new anchor.
    if (fix.timestamp.difference(last.recordedAt) > gapThreshold) {
      _segmentIndex += 1;
      return GpsValidationResult(accepted: true, segmentIndex: _segmentIndex);
    }

    // 3) Duplicate coordinate (stationary noise).
    if (distance < _duplicateMeters) {
      return GpsValidationResult(
        accepted: false,
        segmentIndex: _segmentIndex,
        rejectReason: GpsRejectReason.duplicate,
      );
    }

    // 4) Teleport / implausible speed for the activity type.
    final impliedSpeed = distance / dtSeconds; // m/s
    if (impliedSpeed > profile.maxPlausibleSpeedMps) {
      return GpsValidationResult(
        accepted: false,
        segmentIndex: _segmentIndex,
        rejectReason: GpsRejectReason.implausibleSpeed,
      );
    }

    return GpsValidationResult(accepted: true, segmentIndex: _segmentIndex);
  }

  /// Records an accepted point so subsequent validations compare against it.
  /// Call only for points you actually accepted and stored.
  void commit(RecordedPoint point) {
    _lastAccepted = point;
    _segmentIndex = point.segmentIndex;
  }

  /// Reset for a new recording (or on resume after a long pause, if desired).
  void reset() {
    _lastAccepted = null;
    _segmentIndex = 0;
  }
}
