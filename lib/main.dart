import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/logging/logger.dart';
import 'core/error/error_handler.dart';
import 'core/providers/auth_provider.dart';
import 'data/repositories/firebase_auth_repository.dart';
import 'data/repositories/sqlite_customer_repository.dart';
import 'presentation/customers/customer_viewmodel.dart';
// import 'package:firebase_core/firebase_core.dart'; // TODO: Uncomment when Firebase config is generated
import 'package:go_router/go_router.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // await Firebase.initializeApp(); // TODO: Uncomment when Firebase config is generated
    setupLogger();
    setupErrorHandler();
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(FirebaseAuthRepository())),
          ChangeNotifierProvider(create: (_) => CustomerViewModel(SqliteCustomerRepository())),
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
    return MaterialApp.router(
      title: 'Invoice Generator',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
