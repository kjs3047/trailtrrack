import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

/// Root application widget. Wires the design-system theme and the go_router
/// configuration. Riverpod's [ProviderScope] is installed above this in
/// `main.dart`.
class TrailTrackApp extends StatelessWidget {
  const TrailTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrailTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
