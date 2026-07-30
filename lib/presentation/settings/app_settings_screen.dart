import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'settings_viewmodel.dart';
import '../../widgets/feedback/app_snackbar.dart';
import '../../core/theme/app_spacing.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionTitle(context, 'Display'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            trailing: DropdownButton<String>(
              value: vm.settings['themeMode'] ?? 'system',
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'system', child: Text('System Default')),
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
              ],
              onChanged: (val) {
                if (val != null) vm.saveSetting('themeMode', val);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: vm.appLanguage,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'es', child: Text('Español (Coming Soon)')),
                DropdownMenuItem(value: 'fr', child: Text('Français (Coming Soon)')),
              ],
              onChanged: (val) {
                if (val != null) vm.saveSetting('appLanguage', val);
              },
            ),
          ),
          const Divider(),
          _buildSectionTitle(context, 'Security'),
          SwitchListTile(
            secondary: const Icon(Icons.pin),
            title: const Text('Require PIN on Startup'),
            value: vm.requirePin,
            onChanged: (val) {
              vm.saveSetting('requirePin', val.toString());
              if (val) {
                // Mock PIN setting for now
                vm.saveSetting('appPin', '1234');
                AppSnackbar.showSuccess(context, 'PIN set to 1234 for demo purposes.');
              }
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Use Biometrics'),
            subtitle: const Text('Requires native iOS/Android configuration'),
            value: vm.useBiometric,
            onChanged: (val) {
              vm.saveSetting('useBiometric', val.toString());
            },
          ),
          const Divider(),
          _buildSectionTitle(context, 'Data & Sync'),
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Google Drive, Dropbox, Auto-backups'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/backup-settings'),
          ),
          const Divider(),
          _buildSectionTitle(context, 'System'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/notification-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Invoice Generator',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 40),
                applicationLegalese: '© 2026 Antigravity Systems',
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
