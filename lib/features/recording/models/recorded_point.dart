import '../../map/cesium_bridge.dart';

/// An in-memory GPS sample during (or after) a recording.
///
/// Mirrors the `track_points` columns (see DATABASE.md). Kept as a plain
/// immutable value type so the stats/validation engine can be unit-tested
/// without a database or plugins (spec §17).
class RecordedPoint {
  const RecordedPoint({
    required this.sequence,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.gpsAltitude,
    this.demAltitude,
    this.speed,
    this.heading,
    this.accuracy,
    this.segmentIndex = 0,
    this.isAccepted = true,
  });

  final int sequence;
  final double latitude;
  final double longitude;

  /// Raw GPS altitude (m). Never overwritten by DEM values (spec §8).
  final double? gpsAltitude;

  /// DEM-derived altitude (m), filled by a post-hoc batch lookup.
  final double? demAltitude;

  final double? speed; // m/s
  final double? heading; // degrees
  final double? accuracy; // m
  final DateTime recordedAt;

  /// Increments across GPS dropouts; distinct segments are never joined by a
  /// straight line (spec §6).
  final int segmentIndex;

  /// Whether this point passed validation. Statistics use accepted points only.
  final bool isAccepted;

  /// Altitude to display/aggregate: DEM if available, else GPS (spec §8).
  double? get displayAltitude => demAltitude ?? gpsAltitude;

  RecordedPoint copyWith({
    int? sequence,
    double? demAltitude,
    int? segmentIndex,
    bool? isAccepted,
  }) {
    return RecordedPoint(
      sequence: sequence ?? this.sequence,
      latitude: latitude,
      longitude: longitude,
      recordedAt: recordedAt,
      gpsAltitude: gpsAltitude,
      demAltitude: demAltitude ?? this.demAltitude,
      speed: speed,
      heading: heading,
      accuracy: accuracy,
      segmentIndex: segmentIndex ?? this.segmentIndex,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }

  /// Convert to a map point for the Cesium bridge.
  MapPoint toMapPoint() => MapPoint(
    lat: latitude,
    lon: longitude,
    alt: displayAltitude,
    seg: segmentIndex,
    t: recordedAt.millisecondsSinceEpoch,
  );
}
