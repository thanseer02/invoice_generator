import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../widgets/layout/responsive_layout.dart';
import '../utils/formatters/currency_formatter.dart';
import 'dashboard/dashboard_viewmodel.dart';
import 'dashboard/widgets/stat_card.dart';
import 'dashboard/widgets/revenue_expense_chart.dart';
import 'dashboard/widgets/quick_actions_panel.dart';
import 'dashboard/widgets/recent_activity_list.dart';
import '../data/repositories/sqlite_invoice_repository.dart';
import '../data/repositories/sqlite_expense_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(
        invoiceRepo: SqliteInvoiceRepository(),
        expenseRepo: SqliteExpenseRepository(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
            const SizedBox(width: AppSpacing.sm),
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: AppSpacing.md),
          ],
        ),
        body: Consumer<DashboardViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return ResponsiveLayout(
              mobile: _buildMobileLayout(context, viewModel),
              desktop: _buildDesktopLayout(context, viewModel),
            );
          }
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DashboardViewModel vm) {
    return SingleChildScrollView(
      padding: AppSpacing.edgeInsetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatsGrid(context, vm, crossAxisCount: 2),
          const SizedBox(height: AppSpacing.lg),
          const RevenueExpenseChart(),
          const SizedBox(height: AppSpacing.lg),
          const QuickActionsPanel(),
          const SizedBox(height: AppSpacing.lg),
          const RecentActivityList(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DashboardViewModel vm) {
    return SingleChildScrollView(
      padding: AppSpacing.edgeInsetsAllLg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              children: [
                _buildStatsGrid(context, vm, crossAxisCount: 3),
                const SizedBox(height: AppSpacing.xl),
                const RevenueExpenseChart(),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            flex: 3,
            child: Column(
              children: const [
                QuickActionsPanel(),
                SizedBox(height: AppSpacing.xl),
                RecentActivityList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardViewModel vm, {required int crossAxisCount}) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: "Today's Sales",
          value: CurrencyFormatter.format(vm.todaysSales),
          icon: Icons.monetization_on,
          iconColor: AppColors.primary,
        ),
        StatCard(
          title: 'Monthly Sales',
          value: CurrencyFormatter.format(vm.monthlySales),
          icon: Icons.calendar_month,
          iconColor: AppColors.primary,
        ),
        StatCard(
          title: 'Pending Amount',
          value: CurrencyFormatter.format(vm.pendingAmount),
          icon: Icons.pending_actions,
          iconColor: AppColors.warning,
        ),
        StatCard(
          title: 'Paid Amount',
          value: CurrencyFormatter.format(vm.paidAmount),
          icon: Icons.check_circle,
          iconColor: AppColors.success,
        ),
        StatCard(
          title: 'Total Invoices',
          value: vm.invoiceCount.toString(),
          icon: Icons.receipt_long,
          iconColor: AppColors.secondary,
        ),
      ],
    );
  }
}
