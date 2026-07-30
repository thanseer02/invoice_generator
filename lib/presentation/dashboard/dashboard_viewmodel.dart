import 'package:flutter/material.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/expense_repository.dart';

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

    // Generate dummy dashboard data for now
    await Future.delayed(const Duration(milliseconds: 800));
    
    todaysSales = 1250.00;
    monthlySales = 14500.50;
    pendingAmount = 3200.00;
    paidAmount = 11300.50;
    invoiceCount = 42;

    isLoading = false;
    notifyListeners();
  }
}
