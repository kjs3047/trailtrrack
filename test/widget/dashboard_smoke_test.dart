import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trailtrack/app/providers.dart';
import 'package:trailtrack/core/database/app_database.dart';
import 'package:trailtrack/features/dashboard/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard renders header, FAB and empty recent state', (
    tester,
  ) async {
    // Tall surface so the whole dashboard fits without scrolling.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const DashboardScreen())],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Static overrides so no live DB stream / recovery timer lingers past
          // widget disposal (keeps the widget test hermetic).
          activitiesStreamProvider.overrideWith(
            (ref) => Stream<List<ActivityRow>>.value(const []),
          ),
          recoverableActivityProvider.overrideWith((ref) async => null),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.text('TRAILTRACK'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget); // Record FAB
    expect(find.text('총 누적 거리'), findsOneWidget);
    expect(find.text('기록된 활동이 없습니다'), findsOneWidget);
  });
}
