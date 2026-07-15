import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/activity_type.dart';
import '../../core/utils/formatters.dart';
import '../backup/backup_flow.dart';
import 'dashboard_charts_data.dart';
import 'dashboard_summary.dart';
import 'widgets/recovery_dialog.dart';
import 'widgets/recent_activity_tile.dart';
import 'widgets/type_breakdown_chart.dart';
import 'widgets/weekly_distance_chart.dart';

/// Main dashboard (mockup _3): aggregate stats, recent activities, and the
/// Record FAB + Drive save/load entry points.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _recoveryHandled = false;

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);

    // Offer recovery of an interrupted recording once, after first frame.
    ref.listen(recoverableActivityProvider, (_, next) {
      final row = next.value;
      if (row != null && !_recoveryHandled) {
        _recoveryHandled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showRecovery(row);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('TRAILTRACK'),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            child: Icon(Icons.person, color: AppColors.onPrimary, size: 20),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Google Drive 불러오기',
            onPressed: () => BackupFlow(ref).runLoad(context),
            icon: const Icon(Icons.cloud_download_outlined),
          ),
          IconButton(
            tooltip: 'Google Drive 저장',
            onPressed: () => BackupFlow(ref).runSave(context),
            icon: const Icon(Icons.cloud_upload_outlined),
          ),
        ],
      ),
      body: activitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('데이터 오류: $e')),
        data: (activities) => _body(context, activities),
      ),
      // Centered "+" FAB floating above the bottom nav (centerFloat leaves a
      // gap so it never overlaps the tab bar).
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.newActivity),
        backgroundColor: AppColors.safetyOrange,
        foregroundColor: AppColors.onSafetyOrange,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 1) context.push(Routes.history);
          if (i == 2) context.push(Routes.settings);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: '대시보드',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: '활동',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, List<ActivityRow> activities) {
    final summary = DashboardSummary.fromActivities(activities);
    final recent = activities
        .where((a) => a.status == 'completed')
        .take(5)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceSm,
        AppTheme.spaceMd,
        AppTheme.spaceSm,
        120,
      ),
      children: [
        _StatHeroCard(
          label: '총 누적 거리',
          value: Formatters.distanceKm(summary.totalDistanceMeters),
          unit: 'km',
          highlighted: true,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          children: [
            Expanded(
              child: _StatHeroCard(
                label: '총 활동 시간',
                value: Formatters.duration(
                  Duration(seconds: summary.totalActiveSeconds),
                ),
                unit: '',
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: _StatHeroCard(
                label: '활동 횟수',
                value: '${summary.activityCount}',
                unit: '회',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          children: [
            Expanded(
              child: _StatHeroCard(
                label: '최고 고도',
                value: Formatters.altitude(summary.maxAltitude),
                unit: 'm',
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: _StatHeroCard(
                label: '누적 상승',
                value: summary.totalElevationGain.round().toString(),
                unit: 'm',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        _ChartCard(
          title: '주간 통계',
          height: 200,
          child: WeeklyDistanceChart(
            data: WeeklyDistance.fromActivities(activities, DateTime.now()),
            todayIndex: DateTime.now().weekday - 1,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        _ChartCard(
          title: '운동 유형별 비율',
          height: 150,
          child: TypeBreakdownChart(
            data: TypeBreakdown.fromActivities(activities),
          ),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Text('최근 활동', style: AppTypography.headlineLgMobile),
        const SizedBox(height: AppTheme.spaceSm),
        if (recent.isEmpty)
          const _EmptyRecent()
        else
          ...recent.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spaceXs),
              child: RecentActivityTile(
                activity: a,
                onTap: () => context.push(Routes.activityDetailPath(a.id)),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showRecovery(ActivityRow row) async {
    final controller = ref.read(recordingControllerProvider);
    final choice = await showRecoveryDialog(
      context,
      activityType: ActivityType.fromId(row.activityType),
      distanceMeters: row.totalDistanceMeters,
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case RecoveryChoice.resume:
        await controller.resumeExisting(row.id);
        if (mounted) context.go(Routes.recording);
      case RecoveryChoice.saveAndEnd:
        await controller.finalizeRecovered(row.id);
        ref.invalidate(recoverableActivityProvider);
      case RecoveryChoice.discard:
        await controller.deleteRecovered(row.id);
        ref.invalidate(recoverableActivityProvider);
    }
  }
}

class _StatHeroCard extends StatelessWidget {
  const _StatHeroCard({
    required this.label,
    required this.value,
    required this.unit,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final String unit;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.labelCaps),
            const SizedBox(height: AppTheme.spaceXs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: AppTypography.statHuge.copyWith(
                        color: highlighted
                            ? AppColors.primary
                            : AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(unit, style: AppTypography.bodyLg),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.height,
    required this.child,
  });

  final String title;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.labelCaps),
            const SizedBox(height: AppTheme.spaceSm),
            SizedBox(height: height, child: child),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('기록된 활동이 없습니다', style: AppTypography.bodyLg),
            const SizedBox(height: 4),
            Text(
              '새 운동을 시작해 첫 기록을 만들어보세요',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
