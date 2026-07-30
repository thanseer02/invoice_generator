import 'dart:async';
import 'package:flutter/material.dart';
import 'package:invoice_genarator/data/repositories/firebase_auth_repository.dart';
import 'package:invoice_genarator/data/repositories/sqlite_expense_repository.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/logging/logger.dart';
import 'core/error/error_handler.dart';
import 'core/providers/auth_provider.dart';
import 'data/repositories/sqlite_customer_repository.dart';
import 'data/repositories/sqlite_product_repository.dart';
import 'data/repositories/sqlite_invoice_repository.dart';
import 'presentation/customers/customer_viewmodel.dart';
import 'presentation/products/product_viewmodel.dart';
import 'presentation/invoices/invoice_viewmodel.dart';
import 'presentation/expenses/expense_viewmodel.dart';
import 'presentation/settings/settings_viewmodel.dart';
import 'data/repositories/sqlite_settings_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/analytics/analytics_service.dart';
import 'presentation/analytics/analytics_viewmodel.dart';
import 'package:go_router/go_router.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    setupLogger();
    setupErrorHandler();
    
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Oops! Something went wrong.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(details.exceptionAsString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    };
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(FirebaseAuthRepository())),
          ChangeNotifierProvider(create: (_) => CustomerViewModel(SqliteCustomerRepository())),
          ChangeNotifierProvider(create: (_) => ProductViewModel(SqliteProductRepository())),
          ChangeNotifierProvider(create: (_) => InvoiceViewModel(SqliteInvoiceRepository())),
          ChangeNotifierProvider(create: (_) => ExpenseViewModel(SqliteExpenseRepository())),
          ChangeNotifierProvider(create: (_) => SettingsViewModel(SqliteSettingsRepository())),
          ChangeNotifierProvider(create: (_) => AnalyticsViewModel(AnalyticsService(SqliteInvoiceRepository()))),
        ],
        child: const InvoiceApp(),
      ),
    );
  }, (error, stack) {
    appLogger.severe('Uncaught Exception: $error', error, stack);
  });
}

class InvoiceApp extends StatefulWidget {
  const InvoiceApp({super.key});

  @override
  State<InvoiceApp> createState() => _InvoiceAppState();
}

class _InvoiceAppState extends State<InvoiceApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settingsVm, child) {
        return MaterialApp.router(
          title: 'Invoice Generator',
          themeMode: settingsVm.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: _router,
        );
      }
    );
  }
}
