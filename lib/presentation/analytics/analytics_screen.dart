import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analytics_viewmodel.dart';
import 'widgets/analytics_revenue_chart.dart';
import 'widgets/top_products_chart.dart';
import 'widgets/activity_heatmap.dart';
import '../../core/theme/app_spacing.dart';
import '../../utils/formatters/currency_formatter.dart';
import '../../widgets/layout/responsive_layout.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        actions: [
          Consumer<AnalyticsViewModel>(
            builder: (context, vm, _) => PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: vm.setPresetFilter,
              itemBuilder: (context) => [
                const PopupMenuItem(value: '7days', child: Text('Last 7 Days')),
                const PopupMenuItem(value: '30days', child: Text('Last 30 Days')),
                const PopupMenuItem(value: 'thisYear', child: Text('This Year')),
                const PopupMenuItem(value: 'allTime', child: Text('All Time')),
              ],
            ),
          )
        ],
      ),
      body: Consumer<AnalyticsViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ResponsiveLayout(
            mobile: _buildMobileLayout(context, vm),
            desktop: _buildDesktopLayout(context, vm),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AnalyticsViewModel vm) {
    return SingleChildScrollView(
      padding: AppSpacing.edgeInsetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildKPIs(context, vm),
          const SizedBox(height: AppSpacing.xl),
          const AnalyticsRevenueChart(),
          const SizedBox(height: AppSpacing.xl),
          const TopProductsChart(),
          const SizedBox(height: AppSpacing.xl),
          const ActivityHeatmap(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AnalyticsViewModel vm) {
    return SingleChildScrollView(
      padding: AppSpacing.edgeInsetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildKPIs(context, vm),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 2, child: AnalyticsRevenueChart()),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                flex: 1,
                child: Column(
                  children: const [
                    TopProductsChart(),
                    SizedBox(height: AppSpacing.xl),
                    ActivityHeatmap(),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildKPIs(BuildContext context, AnalyticsViewModel vm) {
    final metrics = vm.metrics;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _KpiCard(
              title: 'Total Revenue',
              value: CurrencyFormatter.format(metrics['totalRevenue'] ?? 0),
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            _KpiCard(
              title: 'Avg Invoice',
              value: CurrencyFormatter.format(metrics['averageInvoice'] ?? 0),
              icon: Icons.receipt,
              color: Colors.blue,
            ),
            _KpiCard(
              title: 'Invoices',
              value: (metrics['invoiceCount'] ?? 0).toString(),
              icon: Icons.numbers,
              color: Colors.orange,
            ),
            _KpiCard(
              title: 'Growth',
              value: '${(metrics['growth'] as double? ?? 0).toStringAsFixed(1)}%',
              icon: (metrics['growth'] ?? 0) >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              color: (metrics['growth'] ?? 0) >= 0 ? Colors.green : Colors.red,
            ),
          ],
        );
      }
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: AppSpacing.edgeInsetsAllMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
