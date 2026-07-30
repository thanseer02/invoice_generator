import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/models/invoice.dart';
import '../../domain/models/customer.dart';
import 'invoice_templates.dart';

enum PdfTemplate { classic, modern, minimal, corporate }

class PdfGenerationService {
  static Future<Uint8List> generateInvoicePdf(
    Invoice invoice,
    Customer? customer,
    Map<String, String> settings, {
    PdfTemplate template = PdfTemplate.classic,
  }) async {
    final companyName = settings['companyName'] ?? 'Antigravity Systems';
    
    final pdf = pw.Document(
      title: 'Invoice ${invoice.invoiceNumber}',
      author: companyName,
      creator: 'Invoice Generator App',
    );

    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
      italic: pw.Font.helveticaOblique(),
    );

    switch (template) {
      case PdfTemplate.classic:
        ClassicTemplate.build(pdf, theme, invoice, customer, settings);
        break;
      case PdfTemplate.modern:
        ModernTemplate.build(pdf, theme, invoice, customer, settings);
        break;
      case PdfTemplate.minimal:
        MinimalTemplate.build(pdf, theme, invoice, customer, settings);
        break;
      case PdfTemplate.corporate:
        CorporateTemplate.build(pdf, theme, invoice, customer, settings);
        break;
    }

    return pdf.save();
  }
}
