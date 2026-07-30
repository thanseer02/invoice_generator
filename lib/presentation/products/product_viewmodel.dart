import 'package:flutter/material.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';

enum ProductSortOption { nameAsc, nameDesc, priceHighLow, priceLowHigh, newest }

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;
  ProductSortOption _sortOption = ProductSortOption.nameAsc;

  ProductViewModel(this._repository) {
    loadProducts();
  }

  bool get isLoading => _isLoading;
  List<Product> get products => _filteredProducts;
  ProductSortOption get sortOption => _sortOption;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  List<String> get availableCategories {
    final categories = _allProducts.map((p) => p.category).whereType<String>().toSet().toList();
    categories.sort();
    return categories;
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    _allProducts = await _repository.getAllProducts();
    _applyFiltersAndSort();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortOption(ProductSortOption option) {
    _sortOption = option;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    var filtered = _allProducts.where((p) {
      if (_selectedCategory != null && p.category != _selectedCategory) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = p.name.toLowerCase().contains(query);
        final skuMatch = (p.sku ?? '').toLowerCase().contains(query);
        final barcodeMatch = (p.barcode ?? '').toLowerCase().contains(query);
        return nameMatch || skuMatch || barcodeMatch;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortOption) {
        case ProductSortOption.nameAsc:
          return a.name.compareTo(b.name);
        case ProductSortOption.nameDesc:
          return b.name.compareTo(a.name);
        case ProductSortOption.priceHighLow:
          return b.price.compareTo(a.price);
        case ProductSortOption.priceLowHigh:
          return a.price.compareTo(b.price);
        case ProductSortOption.newest:
          return (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now());
      }
    });

    _filteredProducts = filtered;
  }

  Future<void> addProduct(Product product) async {
    final newProduct = product.copyWith(createdAt: DateTime.now(), updatedAt: DateTime.now());
    await _repository.createProduct(newProduct);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    final updatedProduct = product.copyWith(updatedAt: DateTime.now());
    await _repository.updateProduct(updatedProduct);
    await loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    await loadProducts();
  }
}
