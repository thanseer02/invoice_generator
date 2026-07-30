import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../analytics_viewmodel.dart';
import '../../../core/theme/app_colors.dart';

class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();
    final metrics = vm.metrics;
    
    if (metrics.isEmpty) return const SizedBox.shrink();

    final heatmapData = metrics['heatmapData'] as Map<DateTime, int>;
    
    if (heatmapData.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: const Text('No activity data available'),
        ),
      );
    }

    // Generate last 30 days grid
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<DateTime> days = [];
    for (int i = 29; i >= 0; i--) {
      days.add(today.subtract(Duration(days: i)));
    }

    int maxCount = 1;
    for (var count in heatmapData.values) {
      if (count > maxCount) maxCount = count;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Invoice Activity (30 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: days.map((day) {
                final count = heatmapData[day] ?? 0;
                double opacity = count / maxCount;
                if (count == 0) opacity = 0.05;
                if (opacity > 0 && opacity < 0.2) opacity = 0.2; // Min visibility

                return Tooltip(
                  message: '${day.month}/${day.day}: $count invoices',
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: count == 0 ? Colors.grey.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
