import 'package:flutter/material.dart';
import '../../services/analytics/analytics_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsService _service;
  
  bool _isLoading = true;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  Map<String, dynamic> _metrics = {};
  
  AnalyticsViewModel(this._service) {
    loadMetrics();
  }
  
  bool get isLoading => _isLoading;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  Map<String, dynamic> get metrics => _metrics;
  
  Future<void> loadMetrics() async {
    _isLoading = true;
    notifyListeners();
    
    _metrics = await _service.crunchMetrics(_startDate, _endDate);
    
    _isLoading = false;
    notifyListeners();
  }
  
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    loadMetrics();
  }
  
  void setPresetFilter(String filter) {
    final now = DateTime.now();
    switch (filter) {
      case '7days':
        setDateRange(now.subtract(const Duration(days: 7)), now);
        break;
      case '30days':
        setDateRange(now.subtract(const Duration(days: 30)), now);
        break;
      case 'thisYear':
        setDateRange(DateTime(now.year, 1, 1), now);
        break;
      case 'allTime':
        setDateRange(DateTime(2000), now);
        break;
    }
  }
}
