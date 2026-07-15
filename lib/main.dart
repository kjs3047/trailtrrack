import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration (Cesium ion token, feature flags) before
  // building the UI. Never throws — see AppConfig.load.
  await AppConfig.load();

  runApp(const ProviderScope(child: TrailTrackApp()));
}
