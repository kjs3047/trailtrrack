import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/activity_detail/activity_detail_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/history_screen.dart';
import '../features/map/cesium_poc_screen.dart';
import '../features/recording/new_activity_screen.dart';
import '../features/recording/recording_screen.dart';
import '../features/settings/settings_screen.dart';

/// Route path constants. Use these instead of string literals at call sites.
abstract final class Routes {
  static const dashboard = '/';
  static const history = '/history';
  static const newActivity = '/new';
  static const recording = '/recording';
  static const settings = '/settings';

  /// Activity detail; `:id` is the activity UUID.
  static const activityDetail = '/activity/:id';
  static String activityDetailPath(String id) => '/activity/$id';

  /// M1 Cesium proof-of-concept screen (dev/on-device verification).
  static const cesiumPoc = '/cesium-poc';
}

/// Application router. A flat go_router config — the MVP has no nested shells
/// beyond the dashboard's own bottom navigation, which is handled inside
/// [DashboardScreen] rather than a ShellRoute to keep things simple (spec §4).
final GoRouter appRouter = GoRouter(
  initialLocation: Routes.dashboard,
  routes: [
    GoRoute(
      path: Routes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: Routes.history,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: Routes.newActivity,
      builder: (context, state) => const NewActivityScreen(),
    ),
    GoRoute(
      path: Routes.recording,
      builder: (context, state) => const RecordingScreen(),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: Routes.activityDetail,
      builder: (context, state) =>
          ActivityDetailScreen(activityId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: Routes.cesiumPoc,
      builder: (context, state) => const CesiumPocScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Route error: ${state.error}'))),
);
