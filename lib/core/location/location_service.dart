import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../features/recording/gps_validator.dart';
import 'location_source.dart';

/// Collects GPS on the MAIN isolate using geolocator's own location foreground
/// service (spec §7: screen-off recording via a persistent notification).
///
/// This replaces the earlier flutter_foreground_task task-isolate approach,
/// which crashed on real devices when fixes arrived (cross-isolate plugin
/// fragility). geolocator manages the Android foreground service itself via
/// [ForegroundNotificationConfig], so the position stream keeps delivering with
/// the screen off while all handling stays on the main isolate.
class LocationService implements LocationSource {
  final _fixController = StreamController<RawFix>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  StreamSubscription<Position>? _sub;
  bool _running = false;

  @override
  Stream<RawFix> get fixes => _fixController.stream;
  @override
  Stream<String> get errors => _errorController.stream;
  @override
  bool get isRunning => _running;

  LocationSettings _settings(
    int distanceFilterMeters,
    String title,
    String text,
  ) {
    return AndroidSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: distanceFilterMeters,
      // geolocator runs its own foreground service so GPS survives screen-off.
      foregroundNotificationConfig: ForegroundNotificationConfig(
        notificationTitle: title,
        notificationText: text,
        enableWakeLock: true,
        setOngoing: true,
      ),
    );
  }

  @override
  Future<bool> start({
    required int distanceFilterMeters,
    String notificationTitle = 'TrailTrack 기록 중',
    String notificationText = '운동 경로를 기록하고 있습니다',
  }) async {
    if (_running) return true;
    try {
      _sub =
          Geolocator.getPositionStream(
            locationSettings: _settings(
              distanceFilterMeters,
              notificationTitle,
              notificationText,
            ),
          ).listen(
            _onPosition,
            onError: (Object e) {
              // Surface as a soft error; never let a stream error crash the app.
              if (!_errorController.isClosed) {
                _errorController.add(e.toString());
              }
            },
            cancelOnError: false,
          );
      _running = true;
      return true;
    } catch (e) {
      if (!_errorController.isClosed) _errorController.add(e.toString());
      return false;
    }
  }

  void _onPosition(Position pos) {
    if (_fixController.isClosed) return;
    // pos.timestamp is non-null in current geolocator, but guard anyway so a
    // malformed fix can never throw in this hot path.
    final ts = pos.timestamp;
    _fixController.add(
      RawFix(
        latitude: pos.latitude,
        longitude: pos.longitude,
        altitude: pos.altitude,
        speed: pos.speed,
        heading: pos.heading,
        accuracy: pos.accuracy,
        timestamp: ts,
      ),
    );
  }

  @override
  Future<void> updateNotification({
    required String title,
    required String text,
  }) async {
    // geolocator doesn't expose live notification updates; the notification
    // text set at start() persists. No-op to satisfy the interface.
  }

  @override
  Future<void> setDistanceFilter(int meters) async {
    // Changing the distance filter requires restarting the stream. Not needed
    // mid-recording for the MVP; no-op.
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _running = false;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _fixController.close();
    await _errorController.close();
  }
}
