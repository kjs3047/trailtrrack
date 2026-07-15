import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../dashboard_charts_data.dart';

/// Weekly distance bar chart (mockup _3). Today's bar is highlighted in the
/// primary forest green; the rest use a muted tint.
class WeeklyDistanceChart extends StatelessWidget {
  const WeeklyDistanceChart({
    super.key,
    required this.data,
    required this.todayIndex,
  });

  final WeeklyDistance data;
  final int todayIndex; // 0=Mon .. 6=Sun

  static const _labels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final maxY = (data.maxKm <= 0 ? 1.0 : data.maxKm) * 1.2;
    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= _labels.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_labels[i], style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < 7; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data.bars[i],
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  color: i == todayIndex
                      ? AppColors.primary
                      : AppColors.primaryContainer.withValues(alpha: 0.35),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
