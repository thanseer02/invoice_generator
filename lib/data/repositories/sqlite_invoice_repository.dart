import 'package:sqflite/sqflite.dart';
import '../../domain/models/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../local/database_helper.dart';

class SqliteInvoiceRepository implements InvoiceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Invoice>> getAllInvoices() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('invoices', orderBy: 'issueDate DESC');
    return maps.map((e) => Invoice.fromJson(e)).toList();
  }

  @override
  Future<Invoice?> getInvoiceById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('invoices', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isNotEmpty) return Invoice.fromJson(maps.first);
    return null;
  }

  @override
  Future<void> createInvoice(Invoice invoice) async {
    final db = await _dbHelper.database;
    await db.insert('invoices', invoice.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    final db = await _dbHelper.database;
    await db.update('invoices', invoice.toJson(), where: 'id = ?', whereArgs: [invoice.id]);
  }

  @override
  Future<void> deleteInvoice(String id) async {
    final db = await _dbHelper.database;
    await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Invoice>> getInvoicesByCustomerId(String customerId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'invoices',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'issueDate DESC',
    );
    return maps.map((e) => Invoice.fromJson(e)).toList();
  }
}
