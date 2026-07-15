import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central, typed access to environment configuration.
///
/// Secrets (Cesium ion token, feature flags) are injected through a bundled
/// `.env` asset rather than hard-coded in source (spec §3). Call [load] once
/// during startup before reading any value.
class AppConfig {
  AppConfig._();

  static bool _loaded = false;

  /// Loads the `.env` asset. Safe to call multiple times; the underlying
  /// [dotenv] load is idempotent. Never throws on a missing file so the app
  /// still boots in environments where `.env` was not provided — callers get
  /// empty/default values instead.
  static Future<void> load() async {
    if (_loaded) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Missing or malformed .env: initialise with an empty map so the app
      // still boots. Map/backup features degrade gracefully (see CesiumMapView
      // / backup UI) rather than crash. Spec §14/§20.
      dotenv.loadFromString(envString: '', isOptional: true);
    }
    _loaded = true;
  }

  /// Cesium ion access token used for World Terrain and ion imagery.
  /// Empty string when unset — the map falls back to terrain-less rendering.
  static String get cesiumIonToken => dotenv.maybeGet('CESIUM_ION_TOKEN') ?? '';

  static bool get hasCesiumIonToken => cesiumIonToken.trim().isNotEmpty;

  /// Whether the Google Drive backup UI is offered. Defaults to true.
  static bool get googleDriveEnabled =>
      (dotenv.maybeGet('GOOGLE_DRIVE_ENABLED') ?? 'true').toLowerCase() !=
      'false';

  /// The **Web** OAuth client ID, required by google_sign_in 7.x on Android as
  /// `serverClientId`. Without it sign-in throws clientConfigurationError.
  /// Empty when unset — the Drive UI then shows a setup message.
  static String get googleServerClientId =>
      dotenv.maybeGet('GOOGLE_DRIVE_SERVER_CLIENT_ID') ?? '';

  static bool get hasGoogleServerClientId =>
      googleServerClientId.trim().isNotEmpty;
}
