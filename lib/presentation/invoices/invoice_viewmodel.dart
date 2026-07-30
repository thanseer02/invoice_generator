import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../services/notifications/notification_service.dart';

class InvoiceViewModel extends ChangeNotifier {
  final InvoiceRepository _repository;

  List<Invoice> _allInvoices = [];
  List<Invoice> _filteredInvoices = [];
  
  bool _isLoading = true;
  String _searchQuery = '';
  InvoiceStatus? _statusFilter;

  InvoiceViewModel(this._repository) {
    loadInvoices();
  }

  bool get isLoading => _isLoading;
  List<Invoice> get invoices => _filteredInvoices;
  String get searchQuery => _searchQuery;
  InvoiceStatus? get statusFilter => _statusFilter;

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();

    _allInvoices = await _repository.getAllInvoices();
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(InvoiceStatus? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var filtered = _allInvoices.where((i) {
      if (_statusFilter != null && i.status != _statusFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return i.invoiceNumber.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    _filteredInvoices = filtered;
  }

  Future<void> addInvoice(Invoice invoice) async {
    final newInvoice = invoice.copyWith(createdAt: DateTime.now(), updatedAt: DateTime.now());
    await _repository.createInvoice(newInvoice);
    await NotificationService().scheduleInvoiceReminder(newInvoice);
    await loadInvoices();
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final updatedInvoice = invoice.copyWith(updatedAt: DateTime.now());
    await _repository.updateInvoice(updatedInvoice);
    
    if (invoice.status == InvoiceStatus.paid || invoice.status == InvoiceStatus.cancelled) {
      await NotificationService().cancelReminder(invoice.id);
    } else {
      await NotificationService().scheduleInvoiceReminder(invoice);
    }
    
    await loadInvoices();
  }

  Future<void> deleteInvoice(String id) async {
    await _repository.deleteInvoice(id);
    await NotificationService().cancelReminder(id);
    await loadInvoices();
  }

  Future<void> duplicateInvoice(Invoice invoice) async {
    final newInvoiceId = const Uuid().v4();
    final newItems = invoice.items.map((e) => e.copyWith(id: const Uuid().v4(), invoiceId: newInvoiceId)).toList();
    
    final newInvoice = invoice.copyWith(
      id: newInvoiceId,
      invoiceNumber: '${invoice.invoiceNumber}-COPY',
      status: InvoiceStatus.draft,
      items: newItems,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 14)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.createInvoice(newInvoice);
    await loadInvoices();
  }

  Future<void> updateStatus(Invoice invoice, InvoiceStatus newStatus) async {
    await updateInvoice(invoice.copyWith(status: newStatus));
  }

  static Invoice calculateTotals(Invoice invoice, double taxPercentage) {
    double subtotal = 0.0;
    for (var item in invoice.items) {
      subtotal += item.total;
    }
    final taxAmount = subtotal * (taxPercentage / 100);
    final total = (subtotal + taxAmount) - invoice.discount;
    return invoice.copyWith(
      subtotal: subtotal,
      taxAmount: taxAmount,
      total: total,
    );
  }
}
