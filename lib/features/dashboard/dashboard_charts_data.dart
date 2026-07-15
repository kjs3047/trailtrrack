import '../../core/database/app_database.dart';
import '../../core/utils/activity_type.dart';

/// Data for the dashboard's weekly-distance bar chart (spec §10.1).
class WeeklyDistance {
  const WeeklyDistance(this.bars);

  /// Seven bars, Mon→Sun, distance in km for the current week.
  final List<double> bars;

  double get maxKm => bars.isEmpty ? 0 : bars.reduce((a, b) => a > b ? a : b);

  /// [now] is injected so this stays pure/testable (no Date.now in logic).
  static WeeklyDistance fromActivities(
    List<ActivityRow> activities,
    DateTime now,
  ) {
    // Monday as the start of the week.
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final bars = List<double>.filled(7, 0);
    for (final a in activities) {
      if (a.status != 'completed') continue;
      final started = DateTime.fromMillisecondsSinceEpoch(a.startedAt);
      final dayIndex = started.difference(startOfWeek).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        bars[dayIndex] += a.totalDistanceMeters / 1000;
      }
    }
    return WeeklyDistance(bars);
  }
}

/// Data for the activity-type breakdown pie chart (spec §10.1).
class TypeBreakdown {
  const TypeBreakdown(this.slices);

  /// Map of activity type → count. Only non-zero types included.
  final Map<ActivityType, int> slices;

  int get total => slices.values.fold(0, (a, b) => a + b);

  static TypeBreakdown fromActivities(List<ActivityRow> activities) {
    final counts = <ActivityType, int>{};
    for (final a in activities) {
      if (a.status != 'completed') continue;
      final type = ActivityType.fromId(a.activityType);
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return TypeBreakdown(counts);
  }
}
