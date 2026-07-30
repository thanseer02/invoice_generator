import '../models/invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getAllInvoices();
  Future<Invoice?> getInvoiceById(String id);
  Future<void> createInvoice(Invoice invoice);
  Future<void> updateInvoice(Invoice invoice);
  Future<void> deleteInvoice(String id);
  Future<List<Invoice>> getInvoicesByCustomerId(String customerId);
}
