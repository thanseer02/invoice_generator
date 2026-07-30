import 'package:flutter/material.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../services/reporting/reporting_service.dart';

class ReportsViewModel extends ChangeNotifier {
  final InvoiceRepository invoiceRepo;
  final ExpenseRepository expenseRepo;
  final CustomerRepository customerRepo;
  final ProductRepository productRepo;

  ReportingService? reportingService;
  bool isLoading = true;

  ReportsViewModel({
    required this.invoiceRepo,
    required this.expenseRepo,
    required this.customerRepo,
    required this.productRepo,
  }) {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      final invoices = await invoiceRepo.getAllInvoices();
      final expenses = await expenseRepo.getAllExpenses();
      final customers = await customerRepo.getAllCustomers();
      final products = await productRepo.getAllProducts();

      reportingService = ReportingService(
        invoices: invoices,
        expenses: expenses,
        customers: customers,
        products: products,
      );
    } catch (e) {
      debugPrint('Error loading reports data: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
