import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../analytics_viewmodel.dart';
import '../../../core/theme/app_colors.dart';

class AnalyticsRevenueChart extends StatelessWidget {
  const AnalyticsRevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();
    final metrics = vm.metrics;
    
    if (metrics.isEmpty) return const SizedBox.shrink();

    final revenueData = metrics['revenueOverTime'] as Map<DateTime, double>;
    
    if (revenueData.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: const Text('No revenue data for this period'),
        ),
      );
    }

    final sortedKeys = revenueData.keys.toList()..sort();
    final spots = <FlSpot>[];
    
    double maxRevenue = 0;
    for (int i = 0; i < sortedKeys.length; i++) {
      final value = revenueData[sortedKeys[i]]!;
      if (value > maxRevenue) maxRevenue = value;
      spots.add(FlSpot(i.toDouble(), value));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Revenue Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          if (index < 0 || index >= sortedKeys.length) {
                            return const SizedBox.shrink();
                          }
                          // Show max 5 labels to avoid clutter
                          if (sortedKeys.length > 5 && index % (sortedKeys.length ~/ 5) != 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(DateFormat('MMM d').format(sortedKeys[index]), style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (sortedKeys.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxRevenue * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
