import 'package:flutter/material.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/models/report_models.dart';
import '../../services/reporting/reporting_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final InvoiceRepository invoiceRepo;
  final ExpenseRepository expenseRepo;

  bool isLoading = true;
  double todaysSales = 0.0;
  double monthlySales = 0.0;
  double pendingAmount = 0.0;
  double paidAmount = 0.0;
  int invoiceCount = 0;

  DashboardViewModel({
    required this.invoiceRepo,
    required this.expenseRepo,
  }) {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      final invoices = await invoiceRepo.getAllInvoices();
      final expenses = await expenseRepo.getAllExpenses();

      final reporting = ReportingService(
        invoices: invoices,
        expenses: expenses,
        customers: [], // Not needed for revenue stats
        products: [],  // Not needed for revenue stats
      );

      final dailyRevenue = reporting.generateRevenueReport(TimePeriod.daily);
      final monthlyRevenue = reporting.generateRevenueReport(TimePeriod.monthly);
      final allTimeRevenue = reporting.generateRevenueReport(TimePeriod.allTime);

      todaysSales = dailyRevenue.totalRevenue;
      monthlySales = monthlyRevenue.totalRevenue;
      pendingAmount = allTimeRevenue.pendingRevenue;
      paidAmount = allTimeRevenue.collectedRevenue;
      invoiceCount = allTimeRevenue.invoiceCount;
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
