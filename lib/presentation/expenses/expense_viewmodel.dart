import 'package:flutter/foundation.dart';
import '../../domain/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _repository;
  
  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String _searchQueryLower = '';
  
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;
  
  final List<String> categories = [
    'Office Supplies',
    'Travel',
    'Meals & Entertainment',
    'Software & Subscriptions',
    'Hardware & Equipment',
    'Utilities',
    'Marketing',
    'Other'
  ];

  ExpenseViewModel(this._repository) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _expenses = await _repository.getAllExpenses();
    } catch (e) {
      debugPrint('Error loading expenses: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  List<Expense> get filteredExpenses {
    return _expenses.where((exp) {
      final matchesSearch = _searchQueryLower.isEmpty ||
          (exp.notes?.toLowerCase().contains(_searchQueryLower) ?? false) ||
          exp.category.toLowerCase().contains(_searchQueryLower);
          
      final matchesCategory = _selectedCategory == null || exp.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQueryLower = query.toLowerCase();
    notifyListeners();
  }
  
  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _repository.createExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _repository.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _repository.deleteExpense(id);
    await loadExpenses();
  }
}
