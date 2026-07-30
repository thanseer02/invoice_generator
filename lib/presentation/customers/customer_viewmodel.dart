import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/customer.dart';
import '../../domain/repositories/customer_repository.dart';

enum CustomerSortOption { nameAsc, nameDesc, newest, oldest }

class CustomerViewModel extends ChangeNotifier {
  final CustomerRepository _repository;

  List<Customer> _allCustomers = [];
  List<Customer> _filteredCustomers = [];
  
  bool _isLoading = true;
  bool _showFavoritesOnly = false;
  String _searchQuery = '';
  CustomerSortOption _sortOption = CustomerSortOption.nameAsc;

  CustomerViewModel(this._repository) {
    loadCustomers();
  }

  bool get isLoading => _isLoading;
  List<Customer> get customers => _filteredCustomers;
  bool get showFavoritesOnly => _showFavoritesOnly;
  CustomerSortOption get sortOption => _sortOption;
  String get searchQuery => _searchQuery;

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    _allCustomers = await _repository.getAllCustomers();
    _applyFiltersAndSort();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortOption(CustomerSortOption option) {
    _sortOption = option;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    var filtered = _allCustomers.where((c) {
      if (_showFavoritesOnly && !c.isFavorite) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = c.name.toLowerCase().contains(query);
        final emailMatch = (c.email ?? '').toLowerCase().contains(query);
        final gstMatch = (c.gstNumber ?? '').toLowerCase().contains(query);
        return nameMatch || emailMatch || gstMatch;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortOption) {
        case CustomerSortOption.nameAsc:
          return a.name.compareTo(b.name);
        case CustomerSortOption.nameDesc:
          return b.name.compareTo(a.name);
        case CustomerSortOption.newest:
          return (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now());
        case CustomerSortOption.oldest:
          return (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
      }
    });

    _filteredCustomers = filtered;
  }

  Future<void> addCustomer(Customer customer) async {
    final newCustomer = customer.copyWith(createdAt: DateTime.now(), updatedAt: DateTime.now());
    await _repository.createCustomer(newCustomer);
    await loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    final updatedCustomer = customer.copyWith(updatedAt: DateTime.now());
    await _repository.updateCustomer(updatedCustomer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await _repository.deleteCustomer(id);
    await loadCustomers();
  }

  Future<void> toggleFavorite(Customer customer) async {
    await updateCustomer(customer.copyWith(isFavorite: !customer.isFavorite));
  }

  Future<void> exportToCsv() async {
    List<List<String>> csvData = [
      ['ID', 'Name', 'Email', 'Phone', 'Address', 'GST Number', 'Notes', 'Is Favorite', 'Created At']
    ];

    for (var c in _allCustomers) {
      csvData.add([
        c.id, c.name, c.email ?? '', c.phone ?? '', c.address ?? '', c.gstNumber ?? '', c.notes ?? '', c.isFavorite.toString(), c.createdAt?.toIso8601String() ?? ''
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final path = '\${directory.path}/customers_export.csv';
    final file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'Customers Export');
  }

  Future<void> importFromCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final input = File(result.files.single.path!).openRead();
      final fields = await input.transform(const Utf8Decoder()).transform(const CsvToListConverter()).toList();

      if (fields.length > 1) { // Skip header
        for (var i = 1; i < fields.length; i++) {
          final row = fields[i];
          if (row.length >= 2) {
            final name = row[1].toString();
            if (name.isNotEmpty) {
              final newCustomer = Customer(
                id: const Uuid().v4(),
                name: name,
                email: row.length > 2 ? row[2].toString() : null,
                phone: row.length > 3 ? row[3].toString() : null,
                address: row.length > 4 ? row[4].toString() : null,
                gstNumber: row.length > 5 ? row[5].toString() : null,
                notes: row.length > 6 ? row[6].toString() : null,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await _repository.createCustomer(newCustomer);
            }
          }
        }
        await loadCustomers();
      }
    }
  }
}
