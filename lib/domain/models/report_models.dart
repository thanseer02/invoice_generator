enum TimePeriod { daily, weekly, monthly, yearly, allTime }

class RevenueReport {
  final double totalRevenue;
  final double collectedRevenue;
  final double pendingRevenue;
  final int invoiceCount;

  RevenueReport({
    required this.totalRevenue,
    required this.collectedRevenue,
    required this.pendingRevenue,
    required this.invoiceCount,
  });
}

class ProfitReport {
  final double totalRevenue;
  final double totalExpenses;
  final double totalTax;
  final double netProfit;

  ProfitReport({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalTax,
    required this.netProfit,
  });
}

class TopEntityReport {
  final String entityName;
  final double totalValue;
  final int count;

  TopEntityReport({
    required this.entityName,
    required this.totalValue,
    required this.count,
  });
}

class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint(this.label, this.value);
}
