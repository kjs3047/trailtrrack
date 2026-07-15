import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Staged runtime-permission requests (spec §7): permissions are requested at
/// the point of use, not all at once on launch. No background-location is ever
/// requested (screen-off recording uses a foreground service instead).
class PermissionService {
  const PermissionService();

  /// Ensure foreground location permission + services are ready to start a
  /// recording. Returns a typed result the UI can act on.
  Future<LocationPermissionResult> ensureLocationForRecording() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionResult.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionResult.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionResult.deniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionResult.granted;
      case LocationPermission.unableToDetermine:
        return LocationPermissionResult.denied;
    }
  }

  /// Ask for the notifications permission (Android 13+) so the foreground
  /// service can show its persistent notification.
  Future<bool> ensureNotifications() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Ask for camera permission at the point the user taps the camera button.
  Future<bool> ensureCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> openSettings() => openAppSettings();
}

enum LocationPermissionResult {
  granted,
  denied,
  deniedForever,
  serviceDisabled;

  bool get isGranted => this == LocationPermissionResult.granted;

  String get message => switch (this) {
    LocationPermissionResult.granted => '위치 권한이 허용되었습니다',
    LocationPermissionResult.denied => '위치 권한이 필요합니다',
    LocationPermissionResult.deniedForever => '위치 권한이 영구 거부되었습니다. 설정에서 허용해 주세요',
    LocationPermissionResult.serviceDisabled => '기기의 위치 서비스를 켜 주세요',
  };
}
