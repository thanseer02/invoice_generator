import 'package:sqflite/sqflite.dart';
import '../../domain/models/setting.dart';
import '../../domain/repositories/settings_repository.dart';
import '../local/database_helper.dart';

class SqliteSettingsRepository implements SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Setting>> getAllSettings() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('settings');
    return maps.map((e) => Setting.fromJson(e)).toList();
  }

  @override
  Future<Setting?> getSettingByKey(String key) async {
    final db = await _dbHelper.database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key], limit: 1);
    if (maps.isNotEmpty) return Setting.fromJson(maps.first);
    return null;
  }

  @override
  Future<void> saveSetting(Setting setting) async {
    final db = await _dbHelper.database;
    await db.insert('settings', setting.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteSetting(String key) async {
    final db = await _dbHelper.database;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }
}
