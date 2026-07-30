import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

void setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

final Logger appLogger = Logger('AppLogger');
