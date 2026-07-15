/// Display formatters for durations, distances, speed and pace. Pure functions
/// so they can be unit-tested and reused across screens.
class Formatters {
  Formatters._();

  /// `H:MM:SS` (or `MM:SS` under an hour).
  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  /// Distance in km with one decimal (e.g. `8.4`).
  static String distanceKm(double meters) => (meters / 1000).toStringAsFixed(1);

  /// Calories as a whole number (e.g. `327`). `--` when unknown/zero.
  static String calories(double kcal) =>
      kcal <= 0 ? '--' : kcal.round().toString();

  /// Speed in km/h with one decimal.
  static String speedKmh(double mps) => (mps * 3.6).toStringAsFixed(1);

  /// Pace as `M'SS"` per km. Returns `--'--"` when speed is ~0.
  static String pacePerKm(double mps) {
    if (mps <= 0.1) return "--'--\"";
    final secPerKm = 1000 / mps;
    final m = (secPerKm / 60).floor();
    final s = (secPerKm % 60).round();
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  /// Altitude in metres, rounded (e.g. `450`).
  static String altitude(double? meters) =>
      meters == null ? '--' : meters.round().toString();
}
