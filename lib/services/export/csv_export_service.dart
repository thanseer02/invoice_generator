import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/report_models.dart';

class CsvExportService {
  static Future<void> exportTopEntities(String title, List<TopEntityReport> data) async {
    List<List<dynamic>> rows = [
      ['Entity Name', 'Count/Quantity', 'Total Value'],
    ];

    for (final item in data) {
      rows.add([item.entityName, item.count, item.totalValue.toStringAsFixed(2)]);
    }

    String csv = rows.map((r) => r.join(',')).join('\\n');
    
    if (kIsWeb) {
      debugPrint("CSV Export on Web requires specialized handling.");
      return;
    }
    
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${title.replaceAll(' ', '_')}.csv');
    await file.writeAsString(csv);
    
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], subject: title);
  }
}
