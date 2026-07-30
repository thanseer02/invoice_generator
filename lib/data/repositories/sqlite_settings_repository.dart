import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';

class SqliteSettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Map<String, String>> getAllSettings() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('settings');
    
    final Map<String, String> settings = {};
    for (final map in maps) {
      settings[map['key'] as String] = map['value'] as String;
    }
    return settings;
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
