import 'package:flutter/material.dart';
import '../logging/logger.dart';

void setupErrorHandler() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    appLogger.severe('Flutter Error: ${details.exception}', details.exception, details.stack);
  };
}
