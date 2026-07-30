import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../local/database_helper.dart';

class SqliteProductRepository implements ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Product>> getAllProducts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('products', orderBy: 'name ASC');
    return maps.map((e) => Product.fromJson(e)).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isNotEmpty) return Product.fromJson(maps.first);
    return null;
  }

  @override
  Future<void> createProduct(Product product) async {
    final db = await _dbHelper.database;
    await db.insert('products', product.toJson());
  }

  @override
  Future<void> updateProduct(Product product) async {
    final db = await _dbHelper.database;
    await db.update('products', product.toJson(), where: 'id = ?', whereArgs: [product.id]);
  }

  @override
  Future<void> deleteProduct(String id) async {
    final db = await _dbHelper.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
