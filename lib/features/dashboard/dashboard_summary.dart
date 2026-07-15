import '../../core/database/app_database.dart';

/// Aggregate figures for the dashboard header (spec §10.1). Pure computation
/// over the completed activities so it is unit-testable.
class DashboardSummary {
  const DashboardSummary({
    required this.totalDistanceMeters,
    required this.totalActiveSeconds,
    required this.activityCount,
    required this.maxAltitude,
    required this.totalElevationGain,
    required this.averageSpeed,
  });

  final double totalDistanceMeters;
  final int totalActiveSeconds;
  final int activityCount;
  final double? maxAltitude;
  final double totalElevationGain;
  final double averageSpeed; // m/s over all activities' moving time

  static const empty = DashboardSummary(
    totalDistanceMeters: 0,
    totalActiveSeconds: 0,
    activityCount: 0,
    maxAltitude: null,
    totalElevationGain: 0,
    averageSpeed: 0,
  );

  static DashboardSummary fromActivities(List<ActivityRow> activities) {
    final completed = activities.where((a) => a.status == 'completed').toList();
    if (completed.isEmpty) return empty;

    double distance = 0;
    int activeSeconds = 0;
    double gain = 0;
    double? maxAlt;
    for (final a in completed) {
      distance += a.totalDistanceMeters;
      activeSeconds += a.activeSeconds;
      gain += a.elevationGain;
      final alt = a.maximumAltitude;
      if (alt != null) {
        maxAlt = (maxAlt == null) ? alt : (alt > maxAlt ? alt : maxAlt);
      }
    }
    final avg = activeSeconds > 0 ? distance / activeSeconds : 0.0;

    return DashboardSummary(
      totalDistanceMeters: distance,
      totalActiveSeconds: activeSeconds,
      activityCount: completed.length,
      maxAltitude: maxAlt,
      totalElevationGain: gain,
      averageSpeed: avg,
    );
  }
}
