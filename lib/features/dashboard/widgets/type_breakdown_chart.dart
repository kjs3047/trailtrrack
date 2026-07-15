import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/activity_type.dart';
import '../dashboard_charts_data.dart';

/// Activity-type breakdown pie chart with a legend (spec §10.1).
class TypeBreakdownChart extends StatelessWidget {
  const TypeBreakdownChart({super.key, required this.data});

  final TypeBreakdown data;

  static const _palette = <ActivityType, Color>{
    ActivityType.walk: AppColors.primary,
    ActivityType.run: AppColors.safetyOrange,
    ActivityType.hike: AppColors.secondary,
    ActivityType.trailRun: AppColors.tertiary,
    ActivityType.cycle: AppColors.primaryContainer,
  };

  @override
  Widget build(BuildContext context) {
    if (data.total == 0) {
      return const Center(
        child: Text(
          '활동 데이터가 없습니다',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    final entries = data.slices.entries.toList();
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 28,
              sections: [
                for (final e in entries)
                  PieChartSectionData(
                    value: e.value.toDouble(),
                    color: _palette[e.key] ?? AppColors.outline,
                    title: '${(e.value / data.total * 100).round()}%',
                    radius: 44,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _palette[e.key] ?? AppColors.outline,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${e.key.label} ${e.value}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
