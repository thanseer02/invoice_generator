import 'package:flutter/foundation.dart';
import 'cloud_backup_provider.dart';
import '../../presentation/settings/settings_viewmodel.dart';
import 'backup_service.dart';

class AutoBackupService {
  static void initialize() {
    // In production, this would initialize a background task runner like workmanager:
    // Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
    
    // We would register a periodic task:
    // Workmanager().registerPeriodicTask(
    //   "1",
    //   "autoBackupTask",
    //   frequency: Duration(hours: 24),
    // );
    debugPrint('AutoBackupService Initialized (MOCK)');
  }

  // This would be the method called by Workmanager in the background isolate
  static Future<void> executeBackgroundBackup(SettingsViewModel vm, CloudBackupProvider provider) async {
    final frequency = vm.autoBackupFrequency;
    if (frequency == 'never') return;

    final lastSyncStr = vm.lastBackupTimestamp;
    if (lastSyncStr.isNotEmpty) {
      final lastSync = DateTime.parse(lastSyncStr);
      final now = DateTime.now();
      
      if (frequency == 'daily' && now.difference(lastSync).inHours < 24) return;
      if (frequency == 'weekly' && now.difference(lastSync).inDays < 7) return;
    }

    try {
      await BackupService.backupToCloud(provider, vm);
      debugPrint('Background backup successful.');
    } catch (e) {
      debugPrint('Background backup failed: $e');
    }
  }
}
