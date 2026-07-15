import 'dart:math' as math;

/// Pure geospatial math helpers. No Flutter/plugin dependencies so they are
/// trivially unit-testable (spec §17).
class GeoMath {
  GeoMath._();

  static const double earthRadiusMeters = 6371000.0;

  /// Great-circle distance between two WGS84 points, in metres (haversine).
  static double haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final rLat1 = _toRad(lat1);
    final rLat2 = _toRad(lat2);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rLat1) *
            math.cos(rLat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.min(1.0, math.sqrt(a)));
    return earthRadiusMeters * c;
  }

  /// Initial bearing from point 1 to point 2, degrees in [0, 360).
  static double bearingDegrees(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final rLat1 = _toRad(lat1);
    final rLat2 = _toRad(lat2);
    final dLon = _toRad(lon2 - lon1);
    final y = math.sin(dLon) * math.cos(rLat2);
    final x =
        math.cos(rLat1) * math.sin(rLat2) -
        math.sin(rLat1) * math.cos(rLat2) * math.cos(dLon);
    final deg = _toDeg(math.atan2(y, x));
    return (deg + 360) % 360;
  }

  static double _toRad(double deg) => deg * math.pi / 180.0;
  static double _toDeg(double rad) => rad * 180.0 / math.pi;
}
