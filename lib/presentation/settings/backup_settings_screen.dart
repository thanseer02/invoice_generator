import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_viewmodel.dart';
import '../../services/backup/backup_service.dart';
import '../../services/backup/cloud_backup_provider.dart';
import '../../widgets/feedback/app_snackbar.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  final CloudBackupProvider _driveProvider = GoogleDriveProvider();
  final CloudBackupProvider _dropboxProvider = DropboxProvider();

  bool _isSyncing = false;

  Future<void> _handleCloudBackup(CloudBackupProvider provider, SettingsViewModel vm) async {
    setState(() => _isSyncing = true);
    try {
      await BackupService.backupToCloud(provider, vm);
      if (mounted) AppSnackbar.showSuccess(context, 'Successfully backed up to ${provider.providerName}');
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Backup failed: $e');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _handleCloudRestore(CloudBackupProvider provider, SettingsViewModel vm) async {
    setState(() => _isSyncing = true);
    try {
      final hasConflict = await BackupService.checkConflict(provider, vm);
      if (hasConflict && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sync Conflict Detected'),
            content: const Text('Your local database has recent changes that are newer than the cloud backup. Restoring now will overwrite your recent work.\n\nDo you want to proceed and overwrite local changes?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Overwrite Local', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (proceed != true) {
          return;
        }
      }

      // Mock download & restore
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Restore Successful'),
            content: const Text('The database has been restored from the cloud. Please restart the app.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Restore failed: $e');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Sync')),
      body: _isSyncing 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          const ListTile(
            title: Text('Cloud Accounts', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
          ListTile(
            leading: const Icon(Icons.add_to_drive),
            title: const Text('Google Drive'),
            subtitle: Text(_driveProvider.isAuthenticated ? 'Connected' : 'Not Connected'),
            trailing: TextButton(
              onPressed: () {
                if (_driveProvider.isAuthenticated) {
                  _driveProvider.signOut();
                  setState(() {});
                } else {
                  _driveProvider.authenticate().then((_) => setState(() {}));
                }
              },
              child: Text(_driveProvider.isAuthenticated ? 'Disconnect' : 'Connect'),
            ),
          ),
          if (_driveProvider.isAuthenticated) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => _handleCloudBackup(_driveProvider, vm), child: const Text('Backup Now'))),
                  const SizedBox(width: 16),
                  Expanded(child: OutlinedButton(onPressed: () => _handleCloudRestore(_driveProvider, vm), child: const Text('Restore'))),
                ],
              ),
            ),
            const Divider(),
          ],
          
          ListTile(
            leading: const Icon(Icons.cloud_queue),
            title: const Text('Dropbox'),
            subtitle: Text(_dropboxProvider.isAuthenticated ? 'Connected' : 'Not Connected'),
            trailing: TextButton(
              onPressed: () {
                if (_dropboxProvider.isAuthenticated) {
                  _dropboxProvider.signOut();
                  setState(() {});
                } else {
                  _dropboxProvider.authenticate().then((_) => setState(() {}));
                }
              },
              child: Text(_dropboxProvider.isAuthenticated ? 'Disconnect' : 'Connect'),
            ),
          ),
          if (_dropboxProvider.isAuthenticated) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => _handleCloudBackup(_dropboxProvider, vm), child: const Text('Backup Now'))),
                  const SizedBox(width: 16),
                  Expanded(child: OutlinedButton(onPressed: () => _handleCloudRestore(_dropboxProvider, vm), child: const Text('Restore'))),
                ],
              ),
            ),
          ],
          const Divider(),

          const ListTile(
            title: Text('Automatic Backup', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
          ListTile(
            title: const Text('Frequency'),
            trailing: DropdownButton<String>(
              value: vm.autoBackupFrequency,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'never', child: Text('Never')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              ],
              onChanged: (val) {
                if (val != null) vm.saveSetting('autoBackupFrequency', val);
              },
            ),
          ),
          if (vm.lastBackupTimestamp.isNotEmpty)
            ListTile(
              title: const Text('Last Sync', style: TextStyle(fontSize: 12, color: Colors.grey)),
              subtitle: Text(vm.lastBackupTimestamp, style: const TextStyle(fontSize: 12)),
            ),
          
          const Divider(),
          const ListTile(
            title: Text('Manual Device Backup', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Export Database File'),
            onTap: () async {
              try {
                await BackupService.backupDatabase();
              } catch (e) {
                if (context.mounted) AppSnackbar.showError(context, 'Export failed: $e');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Import Database File'),
            onTap: () async {
              final success = await BackupService.restoreDatabase();
              if (success && context.mounted) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Restore Successful'),
                    content: const Text('The database has been restored. Please restart the app.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
