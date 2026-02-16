import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MemberGrowthChart extends StatelessWidget {
  final Map<DateTime, int> monthlyGrowth;

  const MemberGrowthChart({super.key, required this.monthlyGrowth});

  @override
  Widget build(BuildContext context) {
    if (monthlyGrowth.isEmpty) return const SizedBox.shrink();

    final sortedEntries = monthlyGrowth.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Find max Y for scaling
    final maxY = sortedEntries
        .map((e) => e.value)
        .fold(0, (p, c) => c > p ? c : p)
        .toDouble();
    // Default max to 5 if no data, add buffer
    final optimizedMaxY = maxY == 0 ? 5.0 : maxY * 1.2;

    return ShadCard(
      title: Text(
        'Usage Trend',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      child: AspectRatio(
        aspectRatio: 1.70,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 18,
            left: 12,
            top: 24,
            bottom: 12,
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= sortedEntries.length) {
                        return const SizedBox.shrink();
                      }
                      final date = sortedEntries[index].key;
                      final month = _getMonthName(date.month);
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          month,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 != 0) return const SizedBox.shrink();
                      return Text(
                        value.toInt().toString(),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 10),
                        textAlign: TextAlign.left,
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              clipData: FlClipData.all(),
              minX: 0,
              maxX: (sortedEntries.length - 1).toDouble(),
              minY: 0,
              maxY: optimizedMaxY,
              lineBarsData: [
                LineChartBarData(
                  spots: sortedEntries.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.value.toDouble());
                  }).toList(),
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
