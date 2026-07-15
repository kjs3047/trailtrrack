import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/core/utils/formatters.dart';

void main() {
  test('duration formats with and without hours', () {
    expect(
      Formatters.duration(const Duration(minutes: 5, seconds: 3)),
      '05:03',
    );
    expect(
      Formatters.duration(const Duration(hours: 3, minutes: 12, seconds: 7)),
      '3:12:07',
    );
  });

  test('distanceKm one decimal', () {
    expect(Formatters.distanceKm(8432), '8.4');
    expect(Formatters.distanceKm(0), '0.0');
  });

  test('speedKmh converts m/s', () {
    expect(Formatters.speedKmh(10), '36.0');
  });

  test('pacePerKm', () {
    // 2.5 m/s → 400 s/km → 6\'40"
    expect(Formatters.pacePerKm(2.5), "6'40\"");
    expect(Formatters.pacePerKm(0), "--'--\"");
  });

  test('altitude rounds or dashes', () {
    expect(Formatters.altitude(450.6), '451');
    expect(Formatters.altitude(null), '--');
  });
}
