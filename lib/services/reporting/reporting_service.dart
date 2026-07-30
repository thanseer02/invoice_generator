import '../../domain/models/invoice.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/product.dart';
import '../../domain/models/report_models.dart';

class ReportingService {
  final List<Invoice> invoices;
  final List<Expense> expenses;
  final List<Customer> customers;
  final List<Product> products;

  ReportingService({
    required this.invoices,
    required this.expenses,
    required this.customers,
    required this.products,
  });

  List<Invoice> filterInvoicesByPeriod(TimePeriod period) {
    final now = DateTime.now();
    return invoices.where((inv) {
      final diff = now.difference(inv.issueDate);
      switch (period) {
        case TimePeriod.daily: return diff.inDays <= 1;
        case TimePeriod.weekly: return diff.inDays <= 7;
        case TimePeriod.monthly: return diff.inDays <= 30;
        case TimePeriod.yearly: return diff.inDays <= 365;
        case TimePeriod.allTime: return true;
      }
    }).toList();
  }

  List<Expense> filterExpensesByPeriod(TimePeriod period) {
    final now = DateTime.now();
    return expenses.where((exp) {
      final diff = now.difference(exp.expenseDate);
      switch (period) {
        case TimePeriod.daily: return diff.inDays <= 1;
        case TimePeriod.weekly: return diff.inDays <= 7;
        case TimePeriod.monthly: return diff.inDays <= 30;
        case TimePeriod.yearly: return diff.inDays <= 365;
        case TimePeriod.allTime: return true;
      }
    }).toList();
  }

  RevenueReport generateRevenueReport(TimePeriod period) {
    final filtered = filterInvoicesByPeriod(period);
    double total = 0, collected = 0, pending = 0;

    for (final inv in filtered) {
      if (inv.status != InvoiceStatus.cancelled) {
        total += inv.total;
        if (inv.status == InvoiceStatus.paid) {
          collected += inv.total;
        } else {
          pending += inv.total;
        }
      }
    }

    return RevenueReport(
      totalRevenue: total,
      collectedRevenue: collected,
      pendingRevenue: pending,
      invoiceCount: filtered.where((i) => i.status != InvoiceStatus.cancelled).length,
    );
  }

  ProfitReport generateProfitReport(TimePeriod period) {
    final revenue = generateRevenueReport(period);
    final filteredExp = filterExpensesByPeriod(period);
    final filteredInv = filterInvoicesByPeriod(period);

    double totalExp = 0;
    for (final exp in filteredExp) {
      totalExp += exp.amount;
    }

    double totalTax = 0;
    for (final inv in filteredInv) {
      if (inv.status != InvoiceStatus.cancelled) {
        totalTax += inv.taxAmount;
      }
    }

    double netRevenue = revenue.totalRevenue - totalTax;
    double netProfit = netRevenue - totalExp;

    return ProfitReport(
      totalRevenue: revenue.totalRevenue,
      totalExpenses: totalExp,
      totalTax: totalTax,
      netProfit: netProfit,
    );
  }

  List<TopEntityReport> getTopCustomers(TimePeriod period, {int limit = 10}) {
    final filtered = filterInvoicesByPeriod(period);
    final Map<String, double> customerSales = {};
    final Map<String, int> customerCount = {};

    for (final inv in filtered) {
      if (inv.status != InvoiceStatus.cancelled) {
        customerSales[inv.customerId] = (customerSales[inv.customerId] ?? 0) + inv.total;
        customerCount[inv.customerId] = (customerCount[inv.customerId] ?? 0) + 1;
      }
    }

    final List<TopEntityReport> report = [];
    for (final entry in customerSales.entries) {
      final customer = customers.firstWhere((c) => c.id == entry.key, orElse: () => Customer(id: '', name: 'Unknown', email: ''));
      report.add(TopEntityReport(
        entityName: customer.name,
        totalValue: entry.value,
        count: customerCount[entry.key] ?? 0,
      ));
    }

    report.sort((a, b) => b.totalValue.compareTo(a.totalValue));
    return report.take(limit).toList();
  }

  List<TopEntityReport> getTopProducts(TimePeriod period, {int limit = 10}) {
    final filtered = filterInvoicesByPeriod(period);
    final Map<String, double> productSales = {};
    final Map<String, int> productCount = {};

    for (final inv in filtered) {
      if (inv.status != InvoiceStatus.cancelled) {
        for (final item in inv.items) {
          final pid = item.productId ?? 'unknown';
          productSales[pid] = (productSales[pid] ?? 0) + item.total;
          productCount[pid] = (productCount[pid] ?? 0) + item.quantity.toInt();
        }
      }
    }

    final List<TopEntityReport> report = [];
    for (final entry in productSales.entries) {
      final product = products.firstWhere((p) => p.id == entry.key, orElse: () => Product(id: '', name: entry.key, price: 0));
      report.add(TopEntityReport(
        entityName: product.name,
        totalValue: entry.value,
        count: productCount[entry.key] ?? 0,
      ));
    }

    report.sort((a, b) => b.totalValue.compareTo(a.totalValue));
    return report.take(limit).toList();
  }
}
