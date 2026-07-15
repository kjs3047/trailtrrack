import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/core/utils/activity_type.dart';
import 'package:trailtrack/features/recording/gps_validator.dart';
import 'package:trailtrack/features/recording/models/recorded_point.dart';

void main() {
  final base = DateTime(2026, 1, 1, 10, 0, 0);

  GpsValidator makeValidator({ActivityType type = ActivityType.run}) =>
      GpsValidator(profile: type.gpsProfile);

  RecordedPoint commitFix(GpsValidator v, RawFix fix, GpsValidationResult r) {
    final p = RecordedPoint(
      sequence: (v.lastAccepted?.sequence ?? -1) + 1,
      latitude: fix.latitude,
      longitude: fix.longitude,
      recordedAt: fix.timestamp,
      gpsAltitude: fix.altitude,
      speed: fix.speed,
      accuracy: fix.accuracy,
      segmentIndex: r.segmentIndex,
      isAccepted: true,
    );
    v.commit(p);
    return p;
  }

  test('first fix is always accepted, segment 0', () {
    final v = makeValidator();
    final r = v.validate(
      RawFix(latitude: 37.5, longitude: 127.0, timestamp: base, accuracy: 10),
    );
    expect(r.accepted, isTrue);
    expect(r.segmentIndex, 0);
  });

  test('rejects a low-accuracy fix', () {
    final v = makeValidator();
    final r = v.validate(
      RawFix(
        latitude: 37.5,
        longitude: 127.0,
        timestamp: base,
        accuracy: 999, // worse than run profile minAccuracy (40)
      ),
    );
    expect(r.accepted, isFalse);
    expect(r.rejectReason, GpsRejectReason.lowAccuracy);
  });

  test('rejects a duplicate (stationary) coordinate', () {
    final v = makeValidator();
    final r0 = v.validate(
      RawFix(latitude: 37.5, longitude: 127.0, timestamp: base, accuracy: 5),
    );
    commitFix(
      v,
      RawFix(latitude: 37.5, longitude: 127.0, timestamp: base, accuracy: 5),
      r0,
    );

    final r1 = v.validate(
      RawFix(
        latitude: 37.5,
        longitude: 127.0, // same spot
        timestamp: base.add(const Duration(seconds: 2)),
        accuracy: 5,
      ),
    );
    expect(r1.accepted, isFalse);
    expect(r1.rejectReason, GpsRejectReason.duplicate);
  });

  test('rejects an implausible teleport for the activity type', () {
    final v = makeValidator(type: ActivityType.walk); // maxSpeed 4.2 m/s
    final r0 = v.validate(
      RawFix(latitude: 37.5, longitude: 127.0, timestamp: base, accuracy: 5),
    );
    commitFix(
      v,
      RawFix(latitude: 37.5, longitude: 127.0, timestamp: base, accuracy: 5),
      r0,
    );

    // ~1.1 km away in 2 seconds → ~555 m/s, absurd for walking.
    final r1 = v.validate(
      RawFix(
        latitude: 37.51,
        longitude: 127.0,
        timestamp: base.add(const Duration(seconds: 2)),
        accuracy: 5,
      ),
    );
    expect(r1.accepted, isFalse);
    expect(r1.rejectReason, GpsRejectReason.implausibleSpeed);
  });

  test('accepts normal walking movement', () {
    final v = makeValidator(type: ActivityType.walk);
    final r0 = v.validate(
      RawFix(latitude: 37.5, longitude: 127.0, timestamp: base, accuracy: 5),
    );
    commitFix(
      v,
      RawFix(latitude: 37.5, longitude: 127.0, timestamp: base, accuracy: 5),
      r0,
    );

    // ~11 m in 10 s → ~1.1 m/s, a normal walk.
    final r1 = v.validate(
      RawFix(
        latitude: 37.5001,
        longitude: 127.0,
        timestamp: base.add(const Duration(seconds: 10)),
        accuracy: 5,
      ),
    );
    expect(r1.accepted, isTrue);
    expect(r1.segmentIndex, 0);
  });

  test('starts a new segment after a long GPS gap', () {
    final v = makeValidator();
    final r0 = v.validate(
      RawFix(latitude: 37.5, longitude: 127.0, timestamp: base, accuracy: 5),
    );
    commitFix(
      v,
      RawFix(latitude: 37.5, longitude: 127.0, timestamp: base, accuracy: 5),
      r0,
    );

    // 60 s later (> 20 s gap threshold) → new segment, accepted as anchor.
    final r1 = v.validate(
      RawFix(
        latitude: 37.5010,
        longitude: 127.0,
        timestamp: base.add(const Duration(seconds: 60)),
        accuracy: 5,
      ),
    );
    expect(r1.accepted, isTrue);
    expect(r1.segmentIndex, 1);
  });

  test('reset clears state', () {
    final v = makeValidator();
    final r0 = v.validate(
      RawFix(latitude: 37.5, longitude: 127.0, timestamp: base, accuracy: 5),
    );
    commitFix(
      v,
      RawFix(latitude: 37.5, longitude: 127.0, timestamp: base, accuracy: 5),
      r0,
    );
    v.reset();
    expect(v.lastAccepted, isNull);
    expect(v.currentSegment, 0);
  });
}
