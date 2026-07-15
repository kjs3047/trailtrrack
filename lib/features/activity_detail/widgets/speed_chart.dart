import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../chart_data.dart';

/// Time-vs-speed line chart (spec §10.4).
class SpeedChart extends StatelessWidget {
  const SpeedChart({super.key, required this.data});

  final ActivityChartData data;

  @override
  Widget build(BuildContext context) {
    if (data.speedByTime.length < 2) {
      return const Center(
        child: Text(
          '속도 데이터가 없습니다',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    final spots = data.speedByTime.map((s) => FlSpot(s.x, s.y)).toList();
    final maxY = (data.maxSpeedKmh + 2).ceilToDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: data.durationSeconds,
        minY: 0,
        maxY: maxY,
        // Custom tooltip — see ElevationChart: the default printed the raw
        // double with no units and wrapped long values onto a second line.
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            maxContentWidth: 180,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spots) => spots
                .map(
                  (s) => LineTooltipItem(
                    '${s.y.toStringAsFixed(1)} km/h\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '시작 후 '
                            '${Formatters.duration(Duration(seconds: s.x.round()))}'
                            ' 경과',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
          getTouchedSpotIndicator: (barData, indexes) => indexes
              .map(
                (i) => TouchedSpotIndicatorData(
                  FlLine(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    strokeWidth: 1,
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2.5,
                          strokeColor: AppColors.primary,
                        ),
                  ),
                ),
              )
              .toList(),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.outlineVariant, strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, meta) =>
                  Text('${v.round()}', style: const TextStyle(fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: (data.durationSeconds / 4).clamp(1, double.infinity),
              getTitlesWidget: (v, meta) => Text(
                Formatters.duration(Duration(seconds: v.round())),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
