import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import '../../domain/models/invoice.dart';
import '../../data/repositories/sqlite_settings_repository.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle tap
      },
    );

    if (Platform.isAndroid) {
      _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  int _generateNotificationId(String invoiceId) {
    return invoiceId.hashCode.abs();
  }

  Future<void> scheduleInvoiceReminder(Invoice invoice) async {
    final settingsRepo = SqliteSettingsRepository();
    final settings = await settingsRepo.getAllSettings();
    final globalNotificationsEnabled = settings['notificationsEnabled'] != 'false';
    
    if (!globalNotificationsEnabled) return;
    
    final notificationId = _generateNotificationId(invoice.id);
    
    // Always clear existing first if any updates occurred
    await cancelReminder(invoice.id);
    
    if (invoice.status == InvoiceStatus.paid || invoice.status == InvoiceStatus.cancelled) {
      return;
    }

    // Schedule 1 day before due date at 9 AM
    final scheduleDate = invoice.dueDate.subtract(const Duration(days: 1));
    final scheduledTime = DateTime(
      scheduleDate.year, scheduleDate.month, scheduleDate.day, 9, 0
    );

    if (scheduledTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: notificationId,
        title: 'Invoice Due Soon',
        body: 'Invoice #${invoice.invoiceNumber} is due tomorrow.',
        scheduledDate: scheduledTime,
      );
    }
    
    // Also schedule OVERDUE alert on the exact day + 1 day at 9 AM
    final overdueDate = invoice.dueDate.add(const Duration(days: 1));
    final overdueTime = DateTime(
      overdueDate.year, overdueDate.month, overdueDate.day, 9, 0
    );

    if (overdueTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: notificationId + 1, // offset by 1
        title: 'Invoice Overdue',
        body: 'Invoice #${invoice.invoiceNumber} is now overdue!',
        scheduledDate: overdueTime,
      );
    }
  }

  Future<void> cancelReminder(String invoiceId) async {
    final id = _generateNotificationId(invoiceId);
    await _notificationsPlugin.cancel(id);
    await _notificationsPlugin.cancel(id + 1);
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'invoice_reminders',
          'Invoice Reminders',
          channelDescription: 'Notifications for due and overdue invoices',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
