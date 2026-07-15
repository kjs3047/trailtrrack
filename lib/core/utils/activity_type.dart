import 'package:flutter/material.dart';

/// Supported workout types (spec §0).
///
/// Each type carries a per-type GPS sampling/validation profile (spec §6).
/// Profiles are deliberately conservative defaults, documented in README /
/// ARCHITECTURE and tuned later against real device data.
enum ActivityType {
  walk,
  run,
  hike,
  trailRun,
  cycle;

  /// Stable string persisted in the database and backups. Never localise this.
  String get id => switch (this) {
    ActivityType.walk => 'walk',
    ActivityType.run => 'run',
    ActivityType.hike => 'hike',
    ActivityType.trailRun => 'trail_run',
    ActivityType.cycle => 'cycle',
  };

  static ActivityType fromId(String id) => switch (id) {
    'walk' => ActivityType.walk,
    'run' => ActivityType.run,
    'hike' => ActivityType.hike,
    'trail_run' => ActivityType.trailRun,
    'cycle' => ActivityType.cycle,
    _ => ActivityType.walk,
  };

  /// Korean display label (matches the mockups).
  String get label => switch (this) {
    ActivityType.walk => '걷기',
    ActivityType.run => '달리기',
    ActivityType.hike => '등산',
    ActivityType.trailRun => '트레일 러닝',
    ActivityType.cycle => '자전거',
  };

  /// Short descriptive subtitle used on the type-picker cards.
  String get subtitle => switch (this) {
    ActivityType.walk => '가벼운 트레일 및 도심',
    ActivityType.run => '페이스 지구력',
    ActivityType.hike => '험준한 지형',
    ActivityType.trailRun => '산악 러닝',
    ActivityType.cycle => '라이딩',
  };

  IconData get icon => switch (this) {
    ActivityType.walk => Icons.directions_walk,
    ActivityType.run => Icons.directions_run,
    ActivityType.hike => Icons.hiking,
    ActivityType.trailRun => Icons.terrain,
    ActivityType.cycle => Icons.pedal_bike,
  };

  /// Metabolic equivalent (MET) for the base calorie estimate
  /// (kcal = MET × weightKg × hours). Mid-intensity values from the
  /// Compendium of Physical Activities; a speed-based refinement is applied on
  /// top in [ActivityStatsCalculator]. These are moderate-effort defaults:
  ///  - walk ~5 km/h, run ~9 km/h, hike w/ load, trail run, general cycling.
  double get met => switch (this) {
    ActivityType.walk => 3.5,
    ActivityType.run => 9.8,
    ActivityType.hike => 6.0,
    ActivityType.trailRun => 10.0,
    ActivityType.cycle => 7.5,
  };

  /// Per-type GPS profile. See [GpsProfile].
  GpsProfile get gpsProfile => switch (this) {
    // Walking: dense sampling, tight distance filter, low max speed.
    ActivityType.walk => const GpsProfile(
      distanceFilterMeters: 4,
      intervalSeconds: 2,
      maxPlausibleSpeedMps: 4.2, // ~15 km/h (jog burst tolerance)
      minAccuracyMeters: 40,
    ),
    ActivityType.run => const GpsProfile(
      distanceFilterMeters: 5,
      intervalSeconds: 2,
      maxPlausibleSpeedMps: 8.5, // ~30 km/h
      minAccuracyMeters: 40,
    ),
    ActivityType.hike => const GpsProfile(
      distanceFilterMeters: 6,
      intervalSeconds: 3,
      maxPlausibleSpeedMps: 4.2,
      minAccuracyMeters: 50,
    ),
    ActivityType.trailRun => const GpsProfile(
      distanceFilterMeters: 5,
      intervalSeconds: 2,
      maxPlausibleSpeedMps: 8.5,
      minAccuracyMeters: 50,
    ),
    // Cycling: coarser filter tolerated, much higher speed ceiling.
    ActivityType.cycle => const GpsProfile(
      distanceFilterMeters: 8,
      intervalSeconds: 2,
      maxPlausibleSpeedMps: 22, // ~80 km/h descent
      minAccuracyMeters: 50,
    ),
  };
}

/// GPS sampling & validation parameters, separated from the [ActivityType]
/// enum so they can be tuned/tested independently (spec §6).
@immutable
class GpsProfile {
  const GpsProfile({
    required this.distanceFilterMeters,
    required this.intervalSeconds,
    required this.maxPlausibleSpeedMps,
    required this.minAccuracyMeters,
  });

  /// Minimum movement before a new point is emitted by the location stream.
  final double distanceFilterMeters;

  /// Target sampling interval for the foreground service.
  final int intervalSeconds;

  /// Speeds above this (m/s) between consecutive accepted points are treated
  /// as GPS teleport artefacts and rejected.
  final double maxPlausibleSpeedMps;

  /// Points with horizontal accuracy worse than this (m) are rejected.
  final double minAccuracyMeters;
}
