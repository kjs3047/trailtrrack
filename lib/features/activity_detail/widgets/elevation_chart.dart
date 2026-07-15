import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../chart_data.dart';

/// Distance-vs-elevation area chart (spec §10.4). Rendered in secondary navy
/// per the design system's chart guidance.
class ElevationChart extends StatelessWidget {
  const ElevationChart({super.key, required this.data});

  final ActivityChartData data;

  @override
  Widget build(BuildContext context) {
    if (data.elevationByDistance.length < 2) {
      return const _EmptyChart(label: '고도 데이터가 없습니다');
    }
    final spots = data.elevationByDistance
        .map((s) => FlSpot(s.x, s.y))
        .toList();
    final minY = (data.minElevation - 10).floorToDouble();
    final maxY = (data.maxElevation + 10).ceilToDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: data.maxDistanceKm,
        minY: minY,
        maxY: maxY,
        // Custom tooltip: the fl_chart default prints the raw double (e.g.
        // "84.91827392578125") into a 120px-wide box, so long values wrapped
        // to a second line and carried no units/context.
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.secondary,
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
                    '고도 ${s.y.round()}m\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: '출발 후 ${s.x.toStringAsFixed(2)}km 지점',
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
                    color: AppColors.secondary.withValues(alpha: 0.35),
                    strokeWidth: 1,
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2.5,
                          strokeColor: AppColors.secondary,
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
                  Text('${v.round()}m', style: const TextStyle(fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, meta) => Text(
                '${v.toStringAsFixed(1)}km',
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
            color: AppColors.secondary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.secondary.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}
