import 'package:geolocator/geolocator.dart';

/// A one-shot current-position fix, decoupled from the recording pipeline.
/// Used by the map's "current location" control on screens that aren't actively
/// recording (new-activity, PoC).
class CurrentLocation {
  const CurrentLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
  });
  final double latitude;
  final double longitude;
  final double? altitude;
}

/// Returns the device's current position if permission is granted and location
/// services are on; otherwise null. Never throws.
Future<CurrentLocation?> getCurrentLocation() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return CurrentLocation(
      latitude: pos.latitude,
      longitude: pos.longitude,
      altitude: pos.altitude,
    );
  } catch (_) {
    return null;
  }
}
