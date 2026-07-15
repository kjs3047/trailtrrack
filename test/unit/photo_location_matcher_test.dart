import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/features/photos/photo_location_matcher.dart';
import 'package:trailtrack/features/recording/models/recorded_point.dart';

void main() {
  const matcher = PhotoLocationMatcher();
  final start = DateTime(2026, 1, 1, 10, 0, 0);

  RecordedPoint pt(
    int seq,
    double lat,
    double lon,
    int tSec, {
    bool accepted = true,
  }) => RecordedPoint(
    sequence: seq,
    latitude: lat,
    longitude: lon,
    recordedAt: start.add(Duration(seconds: tSec)),
    isAccepted: accepted,
  );

  test('no points → no location, distance 0', () {
    final m = matcher.match(
      takenAt: start.add(const Duration(seconds: 5)),
      points: const [],
      activityStart: start,
    );
    expect(m.hasLocation, isFalse);
    expect(m.distanceMeters, 0);
  });

  test('matches the nearest-in-time accepted point', () {
    final points = [
      pt(0, 0, 0, 0),
      pt(1, 0, 1, 100), // ~111 km from start
      pt(2, 0, 2, 200),
    ];
    // Taken at t=90s → closest to the t=100 point (index 1).
    final m = matcher.match(
      takenAt: start.add(const Duration(seconds: 90)),
      points: points,
      activityStart: start,
    );
    expect(m.hasLocation, isTrue);
    expect(m.longitude, 1);
    expect(m.elapsedSeconds, 100);
    // Cumulative distance up to index 1 ≈ 111 km.
    expect(m.distanceMeters / 1000, closeTo(111.2, 2));
  });

  test('ignores rejected points when matching', () {
    final points = [
      pt(0, 0, 0, 0),
      pt(1, 0, 5, 95, accepted: false), // outlier close in time, ignored
      pt(2, 0, 1, 200),
    ];
    final m = matcher.match(
      takenAt: start.add(const Duration(seconds: 95)),
      points: points,
      activityStart: start,
    );
    // Nearest accepted is index 0 (t=0) vs index 2 (t=200); 95 is closer to 0.
    expect(m.longitude, 0);
  });
}
