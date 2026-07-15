import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/core/utils/geo_math.dart';

void main() {
  group('haversineMeters', () {
    test('zero for identical points', () {
      expect(GeoMath.haversineMeters(37.5, 127.0, 37.5, 127.0), 0);
    });

    test('~111.2 km per degree of latitude', () {
      final d = GeoMath.haversineMeters(0, 0, 1, 0);
      expect(d, closeTo(111195, 200)); // ~111.2 km
    });

    test('known Seoul→Busan distance ~325 km', () {
      // Seoul (37.5665, 126.9780) → Busan (35.1796, 129.0756)
      final d = GeoMath.haversineMeters(37.5665, 126.9780, 35.1796, 129.0756);
      expect(d / 1000, closeTo(325, 10));
    });

    test('short distance is symmetric', () {
      final a = GeoMath.haversineMeters(37.6584, 126.9779, 37.6601, 126.9808);
      final b = GeoMath.haversineMeters(37.6601, 126.9808, 37.6584, 126.9779);
      expect(a, closeTo(b, 1e-6));
      expect(a, greaterThan(0));
    });
  });

  group('bearingDegrees', () {
    test('due north is 0', () {
      expect(GeoMath.bearingDegrees(0, 0, 1, 0), closeTo(0, 0.01));
    });

    test('due east is 90', () {
      expect(GeoMath.bearingDegrees(0, 0, 0, 1), closeTo(90, 0.01));
    });

    test('always in [0, 360)', () {
      final b = GeoMath.bearingDegrees(1, 1, 0, 0); // south-west
      expect(b, greaterThanOrEqualTo(0));
      expect(b, lessThan(360));
    });
  });
}
