import 'package:sqflite/sqflite.dart';
import '../../domain/models/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../local/database_helper.dart';

class SqliteInvoiceRepository implements InvoiceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Invoice>> _getInvoicesWithItems(List<Map<String, dynamic>> invoiceMaps, Database db) async {
    List<Invoice> invoices = [];
    for (var map in invoiceMaps) {
      final mutableMap = Map<String, dynamic>.from(map);
      final itemsMaps = await db.query('invoice_items', where: 'invoiceId = ?', whereArgs: [mutableMap['id']]);
      mutableMap['items'] = itemsMaps;
      invoices.add(Invoice.fromJson(mutableMap));
    }
    return invoices;
  }

  @override
  Future<List<Invoice>> getAllInvoices() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('invoices', orderBy: 'issueDate DESC');
    return await _getInvoicesWithItems(maps, db);
  }

  @override
  Future<Invoice?> getInvoiceById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('invoices', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isNotEmpty) {
      final invoices = await _getInvoicesWithItems(maps, db);
      return invoices.first;
    }
    return null;
  }

  @override
  Future<void> createInvoice(Invoice invoice) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final invoiceMap = invoice.toJson();
      invoiceMap.remove('items');
      await txn.insert('invoices', invoiceMap, conflictAlgorithm: ConflictAlgorithm.replace);
      
      for (var item in invoice.items) {
        await txn.insert('invoice_items', item.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final invoiceMap = invoice.toJson();
      invoiceMap.remove('items');
      await txn.update('invoices', invoiceMap, where: 'id = ?', whereArgs: [invoice.id]);
      
      // Delete existing items and insert new ones
      await txn.delete('invoice_items', where: 'invoiceId = ?', whereArgs: [invoice.id]);
      for (var item in invoice.items) {
        await txn.insert('invoice_items', item.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  @override
  Future<void> deleteInvoice(String id) async {
    final db = await _dbHelper.database;
    await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
    // The CASCADE on the invoice_items table will automatically delete the items.
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
    return await _getInvoicesWithItems(maps, db);
  }
}
