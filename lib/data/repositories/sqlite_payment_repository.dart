import 'package:sqflite/sqflite.dart';
import '../../domain/models/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../local/database_helper.dart';

class SqlitePaymentRepository implements PaymentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Payment>> getAllPayments() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('payments', orderBy: 'paymentDate DESC');
    return maps.map((e) => Payment.fromJson(e)).toList();
  }

  @override
  Future<Payment?> getPaymentById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('payments', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isNotEmpty) return Payment.fromJson(maps.first);
    return null;
  }

  @override
  Future<void> createPayment(Payment payment) async {
    final db = await _dbHelper.database;
    await db.insert('payments', payment.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updatePayment(Payment payment) async {
    final db = await _dbHelper.database;
    await db.update('payments', payment.toJson(), where: 'id = ?', whereArgs: [payment.id]);
  }

  @override
  Future<void> deletePayment(String id) async {
    final db = await _dbHelper.database;
    await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Payment>> getPaymentsByInvoiceId(String invoiceId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
      orderBy: 'paymentDate DESC',
    );
    return maps.map((e) => Payment.fromJson(e)).toList();
  }
}
