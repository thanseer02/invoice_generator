import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_viewmodel.dart';
import '../../services/notifications/notification_service.dart';
import '../../widgets/feedback/app_snackbar.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Reminders'),
            subtitle: const Text('Receive local alerts for due and overdue invoices'),
            value: vm.notificationsEnabled,
            onChanged: (val) async {
              await vm.saveSetting('notificationsEnabled', val.toString());
              if (val) {
                // Try initializing if they turn it on
                await NotificationService().initialize();
                if (context.mounted) {
                  AppSnackbar.showSuccess(context, 'Notifications enabled.');
                }
              }
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Reminder Schedule', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Due Soon Reminder'),
            subtitle: const Text('1 day before due date at 9:00 AM'),
            trailing: const Icon(Icons.check, color: Colors.green),
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: const Text('Overdue Alert'),
            subtitle: const Text('1 day after due date at 9:00 AM'),
            trailing: const Icon(Icons.check, color: Colors.green),
          ),
          const Divider(),
          const ListTile(
            title: Text('Recurring Invoices', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
          ListTile(
            leading: const Icon(Icons.autorenew),
            title: const Text('Generation Reminders'),
            subtitle: const Text('Get notified when it\'s time to duplicate a recurring invoice'),
            trailing: const Icon(Icons.check, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
