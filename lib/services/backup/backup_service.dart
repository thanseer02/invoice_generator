import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class BackupService {
  static const _dbName = "invoice_generator.db";

  static Future<void> backupDatabase() async {
    if (kIsWeb) return;
    
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      final file = File(path);
      
      if (await file.exists()) {
        // ignore: deprecated_member_use
        await Share.shareXFiles([XFile(file.path)], subject: 'Invoice Generator Database Backup');
      }
    } catch (e) {
      debugPrint('Backup error: $e');
      rethrow;
    }
  }

  static Future<bool> restoreDatabase() async {
    if (kIsWeb) return false;
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      
      if (result != null && result.files.single.path != null) {
        final sourcePath = result.files.single.path!;
        
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, _dbName);
        
        final destFile = File(path);
        await File(sourcePath).copy(destFile.path);
        
        return true; // Requires app restart to take effect
      }
    } catch (e) {
      debugPrint('Restore error: $e');
    }
    return false;
  }
}
