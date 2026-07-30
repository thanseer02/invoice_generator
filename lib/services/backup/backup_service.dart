import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'cloud_backup_provider.dart';
import '../../presentation/settings/settings_viewmodel.dart';

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

  static Future<void> backupToCloud(CloudBackupProvider provider, SettingsViewModel vm) async {
    if (kIsWeb) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    final file = File(path);
    if (!await file.exists()) return;

    if (!provider.isAuthenticated) {
      final success = await provider.authenticate();
      if (!success) throw Exception('Authentication failed');
    }

    final uploaded = await provider.uploadBackup(file);
    if (uploaded) {
      await vm.saveSetting('lastBackupTimestamp', DateTime.now().toIso8601String());
    } else {
      throw Exception('Upload failed');
    }
  }

  static Future<bool> checkConflict(CloudBackupProvider provider, SettingsViewModel vm) async {
    if (!provider.isAuthenticated) {
      await provider.authenticate();
    }
    final cloudDate = await provider.getLastBackupTimestamp();
    if (cloudDate == null) return false; // No cloud backup to conflict with

    final localDateStr = vm.dbLastModifiedTimestamp;
    final localDate = DateTime.tryParse(localDateStr) ?? DateTime.now();

    // If local database was modified AFTER the cloud backup was created, there is a conflict
    return localDate.isAfter(cloudDate);
  }
}
