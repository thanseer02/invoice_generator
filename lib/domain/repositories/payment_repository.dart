import '../models/payment.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getAllPayments();
  Future<Payment?> getPaymentById(String id);
  Future<void> createPayment(Payment payment);
  Future<void> updatePayment(Payment payment);
  Future<void> deletePayment(String id);
  Future<List<Payment>> getPaymentsByInvoiceId(String invoiceId);
}
