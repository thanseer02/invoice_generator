import 'dart:isolate';
import '../../domain/models/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';

class AnalyticsService {
  final InvoiceRepository _invoiceRepo;

  AnalyticsService(this._invoiceRepo);

  Future<Map<String, dynamic>> crunchMetrics(DateTime start, DateTime end) async {
    final allInvoices = await _invoiceRepo.getAllInvoices();
    
    return await Isolate.run(() {
      return _processData(allInvoices, start, end);
    });
  }

  static Map<String, dynamic> _processData(List<Invoice> allInvoices, DateTime start, DateTime end) {
    
    // Filter invoices by date range
    final periodInvoices = allInvoices.where((i) => 
      i.issueDate.isAfter(start.subtract(const Duration(seconds: 1))) && 
      i.issueDate.isBefore(end.add(const Duration(seconds: 1)))
    ).toList();
    
    // Calculate total revenue
    double totalRevenue = 0;
    for (var invoice in periodInvoices) {
      if (invoice.status != InvoiceStatus.cancelled) {
        totalRevenue += invoice.total;
      }
    }
    
    // Average invoice
    double averageInvoice = periodInvoices.isEmpty ? 0 : totalRevenue / periodInvoices.length;
    
    // Growth
    final duration = end.difference(start);
    final prevStart = start.subtract(duration);
    final prevEnd = start;
    
    final prevInvoices = allInvoices.where((i) => 
      i.issueDate.isAfter(prevStart.subtract(const Duration(seconds: 1))) && 
      i.issueDate.isBefore(prevEnd.add(const Duration(seconds: 1)))
    ).toList();
    
    double prevRevenue = 0;
    for (var invoice in prevInvoices) {
      if (invoice.status != InvoiceStatus.cancelled) {
        prevRevenue += invoice.total;
      }
    }
    
    double growth = 0;
    if (prevRevenue > 0) {
      growth = ((totalRevenue - prevRevenue) / prevRevenue) * 100;
    } else if (prevRevenue == 0 && totalRevenue > 0) {
      growth = 100;
    }
    
    // Top products
    Map<String, double> productSales = {};
    for (var invoice in periodInvoices) {
      if (invoice.status != InvoiceStatus.cancelled) {
        for (var item in invoice.items) {
          productSales[item.description] = (productSales[item.description] ?? 0) + item.total;
        }
      }
    }
    var sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topProducts = sortedProducts.take(5).toList();

    // Heatmap data (Date -> Invoice Count)
    Map<DateTime, int> heatmapData = {};
    for (var invoice in periodInvoices) {
      final date = DateTime(invoice.issueDate.year, invoice.issueDate.month, invoice.issueDate.day);
      heatmapData[date] = (heatmapData[date] ?? 0) + 1;
    }
    
    // Revenue over time
    Map<DateTime, double> revenueOverTime = {};
    for (var invoice in periodInvoices) {
      if (invoice.status != InvoiceStatus.cancelled) {
        final date = DateTime(invoice.issueDate.year, invoice.issueDate.month, invoice.issueDate.day);
        revenueOverTime[date] = (revenueOverTime[date] ?? 0) + invoice.total;
      }
    }
    
    return {
      'totalRevenue': totalRevenue,
      'averageInvoice': averageInvoice,
      'growth': growth,
      'invoiceCount': periodInvoices.length,
      'topProducts': topProducts,
      'heatmapData': heatmapData,
      'revenueOverTime': revenueOverTime,
    };
  }
}
