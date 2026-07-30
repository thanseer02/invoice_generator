import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/logging/logger.dart';
import 'core/error/error_handler.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    setupLogger();
    setupErrorHandler();
    
    runApp(
      MultiProvider(
        providers: [
          // TODO: Add your global providers here
          Provider<int>.value(value: 42), // Dummy provider to satisfy MultiProvider
        ],
        child: const InvoiceApp(),
      ),
    );
  }, (error, stack) {
    appLogger.severe('Uncaught Exception: $error', error, stack);
  });
}

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Invoice Generator',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
