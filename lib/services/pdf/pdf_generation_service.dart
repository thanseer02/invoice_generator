import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/models/invoice.dart';
import '../../domain/models/customer.dart';
import 'invoice_templates.dart';

enum PdfTemplate { classic, modern, minimal, corporate }

class PdfGenerationService {
  static Future<Uint8List> generateInvoicePdf(
    Invoice invoice,
    Customer? customer, {
    PdfTemplate template = PdfTemplate.classic,
    String companyName = 'Antigravity Systems',
    String companyEmail = 'billing@antigravity.dev',
    String companyPhone = '+1 (555) 019-2837',
    String companyAddress = '742 Evergreen Terrace, Springfield',
  }) async {
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
        ClassicTemplate.build(pdf, theme, invoice, customer, companyName, companyEmail, companyPhone, companyAddress);
        break;
      case PdfTemplate.modern:
        ModernTemplate.build(pdf, theme, invoice, customer, companyName, companyEmail, companyPhone, companyAddress);
        break;
      case PdfTemplate.minimal:
        MinimalTemplate.build(pdf, theme, invoice, customer, companyName, companyEmail, companyPhone, companyAddress);
        break;
      case PdfTemplate.corporate:
        CorporateTemplate.build(pdf, theme, invoice, customer, companyName, companyEmail, companyPhone, companyAddress);
        break;
    }

    return pdf.save();
  }
}
