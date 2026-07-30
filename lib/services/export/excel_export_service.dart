import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/report_models.dart';

class ExcelExportService {
  static Future<void> exportFinancialReport(ProfitReport profit, RevenueReport revenue) async {
    if (kIsWeb) {
      debugPrint("Excel Export on Web requires specialized handling.");
      return;
    }

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Financial Report'];
    excel.setDefaultSheet(sheetObject.sheetName);

    sheetObject.appendRow([TextCellValue('Metric'), TextCellValue('Value')]);
    
    sheetObject.appendRow([TextCellValue('Total Revenue'), DoubleCellValue(profit.totalRevenue)]);
    sheetObject.appendRow([TextCellValue('Total Expenses'), DoubleCellValue(profit.totalExpenses)]);
    sheetObject.appendRow([TextCellValue('Total Tax'), DoubleCellValue(profit.totalTax)]);
    sheetObject.appendRow([TextCellValue('Net Profit'), DoubleCellValue(profit.netProfit)]);
    
    sheetObject.appendRow([TextCellValue('')]);
    sheetObject.appendRow([TextCellValue('Invoice Count'), IntCellValue(revenue.invoiceCount)]);
    sheetObject.appendRow([TextCellValue('Collected Revenue'), DoubleCellValue(revenue.collectedRevenue)]);
    sheetObject.appendRow([TextCellValue('Pending Revenue'), DoubleCellValue(revenue.pendingRevenue)]);

    var fileBytes = excel.save();
    
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Financial_Report.xlsx');
    
    await file.writeAsBytes(fileBytes!);
    
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], subject: 'Financial Report');
  }
}
