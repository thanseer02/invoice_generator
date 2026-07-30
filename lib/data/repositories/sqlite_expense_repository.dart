import 'package:sqflite/sqflite.dart';
import '../../domain/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../local/database_helper.dart';

class SqliteExpenseRepository implements ExpenseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Expense>> getAllExpenses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('expenses', orderBy: 'expenseDate DESC');
    return maps.map((e) => Expense.fromJson(e)).toList();
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('expenses', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isNotEmpty) return Expense.fromJson(maps.first);
    return null;
  }

  @override
  Future<void> createExpense(Expense expense) async {
    final db = await _dbHelper.database;
    await db.insert('expenses', expense.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    await db.update('expenses', expense.toJson(), where: 'id = ?', whereArgs: [expense.id]);
  }

  @override
  Future<void> deleteExpense(String id) async {
    final db = await _dbHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
