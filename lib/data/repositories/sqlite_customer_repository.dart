import '../../domain/models/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../local/database_helper.dart';

class SqliteCustomerRepository implements CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Customer>> getAllCustomers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('customers', orderBy: 'name ASC');
    return maps.map((e) => Customer.fromJson(e)).toList();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isNotEmpty) return Customer.fromJson(maps.first);
    return null;
  }

  @override
  Future<void> createCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    await db.insert('customers', customer.toJson());
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    await db.update('customers', customer.toJson(), where: 'id = ?', whereArgs: [customer.id]);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    final db = await _dbHelper.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}
