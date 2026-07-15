import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import 'widgets/recent_activity_tile.dart';

/// Full activity-history list (the "활동" tab, spec §10.1 "기록 목록").
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activitiesStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('활동 기록')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (activities) {
          final completed = activities
              .where((a) => a.status == 'completed')
              .toList();
          if (completed.isEmpty) {
            return Center(
              child: Text('기록된 활동이 없습니다', style: AppTypography.bodyLg),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppTheme.spaceSm),
            itemCount: completed.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppTheme.spaceXs),
            itemBuilder: (context, i) {
              final a = completed[i];
              return RecentActivityTile(
                activity: a,
                onTap: () => context.push(Routes.activityDetailPath(a.id)),
              );
            },
          );
        },
      ),
    );
  }
}
