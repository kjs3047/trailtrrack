import '../../features/recording/gps_validator.dart';

/// The location capability the recording controller depends on.
///
/// Extracting this interface lets tests inject a fake GPS source (spec §16/§17
/// "Mock GPS") without the foreground-service plugin. The production
/// implementation is [LocationService].
abstract class LocationSource {
  Stream<RawFix> get fixes;
  Stream<String> get errors;
  bool get isRunning;

  Future<bool> start({
    required int distanceFilterMeters,
    String notificationTitle,
    String notificationText,
  });

  Future<void> updateNotification({
    required String title,
    required String text,
  });

  Future<void> setDistanceFilter(int meters);

  Future<void> stop();

  Future<void> dispose();
}
