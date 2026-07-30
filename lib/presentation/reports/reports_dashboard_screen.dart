import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/report_models.dart';
import '../../services/export/csv_export_service.dart';
import '../../services/export/excel_export_service.dart';
import '../../core/theme/app_spacing.dart';
import 'reports_viewmodel.dart';
import '../../data/repositories/sqlite_invoice_repository.dart';
import '../../data/repositories/sqlite_expense_repository.dart';
import '../../data/repositories/sqlite_customer_repository.dart';
import '../../data/repositories/sqlite_product_repository.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsViewModel(
        invoiceRepo: SqliteInvoiceRepository(),
        expenseRepo: SqliteExpenseRepository(),
        customerRepo: SqliteCustomerRepository(),
        productRepo: SqliteProductRepository(),
      ),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  TimePeriod _selectedPeriod = TimePeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportsViewModel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.reportingService == null) {
      return const Scaffold(body: Center(child: Text('Failed to load reports')));
    }

    final profitReport = vm.reportingService!.generateProfitReport(_selectedPeriod);
    final revenueReport = vm.reportingService!.generateRevenueReport(_selectedPeriod);
    final topCustomers = vm.reportingService!.getTopCustomers(_selectedPeriod, limit: 5);
    final topProducts = vm.reportingService!.getTopProducts(_selectedPeriod, limit: 5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          DropdownButton<TimePeriod>(
            value: _selectedPeriod,
            dropdownColor: Theme.of(context).cardColor,
            underline: const SizedBox(),
            items: TimePeriod.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedPeriod = val);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.edgeInsetsAllLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinancialSummary(context, profitReport, revenueReport),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTopEntitiesTable(context, 'Top Customers', topCustomers)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: _buildTopEntitiesTable(context, 'Top Products', topProducts)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildTopEntitiesTable(context, 'Top Customers', topCustomers),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTopEntitiesTable(context, 'Top Products', topProducts),
                  ],
                );
              }
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(BuildContext context, ProfitReport profit, RevenueReport revenue) {
    return Card(
      child: Padding(
        padding: AppSpacing.edgeInsetsAllLg,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Financial Summary', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => ExcelExportService.exportFinancialReport(profit, revenue),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Export Excel'),
                ),
              ],
            ),
            const Divider(height: 32),
            Wrap(
              spacing: 32,
              runSpacing: 16,
              alignment: WrapAlignment.spaceAround,
              children: [
                _buildStat('Net Profit', profit.netProfit, Colors.green),
                _buildStat('Total Revenue', profit.totalRevenue, Colors.blue),
                _buildStat('Total Expenses', profit.totalExpenses, Colors.red),
                _buildStat('Collected Tax', profit.totalTax, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('\$${value.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildTopEntitiesTable(BuildContext context, String title, List<TopEntityReport> entities) {
    return Card(
      child: Padding(
        padding: AppSpacing.edgeInsetsAllLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => CsvExportService.exportTopEntities('$title - ${_selectedPeriod.name}', entities),
                  icon: const Icon(Icons.download),
                  label: const Text('CSV'),
                )
              ],
            ),
            const Divider(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Volume')),
                  DataColumn(label: Text('Revenue')),
                ],
                rows: entities.map((e) => DataRow(cells: [
                  DataCell(Text(e.entityName)),
                  DataCell(Text(e.count.toString())),
                  DataCell(Text('\$${e.totalValue.toStringAsFixed(2)}')),
                ])).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
