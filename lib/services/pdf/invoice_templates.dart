import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../domain/models/invoice.dart';
import '../../domain/models/customer.dart';

class PdfUtils {
  static final dateFormat = DateFormat.yMMMd();

  static pw.Widget buildHeader(String title, String invoiceNum, DateTime issueDate, DateTime dueDate, {PdfColor? color}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: color)),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Invoice #$invoiceNum', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 4),
            pw.Text('Issue Date: ${dateFormat.format(issueDate)}'),
            pw.Text('Due Date: ${dateFormat.format(dueDate)}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget buildCompanyCustomerInfo(
    Map<String, String> settings,
    Customer? customer
  ) {
    String cName = settings['companyName'] ?? 'Antigravity Systems';
    String cAddress = settings['companyAddress'] ?? '';
    String cEmail = settings['companyEmail'] ?? '';
    String cPhone = settings['companyPhone'] ?? '';
    String cGst = settings['companyGst'] ?? '';
    String logoPath = settings['logoPath'] ?? '';

    pw.Widget logoWidget = pw.SizedBox.shrink();
    if (logoPath.isNotEmpty) {
      try {
        final imageBytes = File(logoPath).readAsBytesSync();
        logoWidget = pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          height: 50,
          child: pw.Image(pw.MemoryImage(imageBytes)),
        );
      } catch (e) {
        // Failed to load image
      }
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            logoWidget,
            pw.Text('From:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text(cName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            if (cAddress.isNotEmpty) pw.Text(cAddress),
            if (cEmail.isNotEmpty) pw.Text(cEmail),
            if (cPhone.isNotEmpty) pw.Text(cPhone),
            if (cGst.isNotEmpty) pw.Text('GST: $cGst'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text(customer?.name ?? 'Unknown Customer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            if (customer?.address != null && customer!.address!.isNotEmpty) pw.Text(customer.address!),
            if (customer?.email != null && customer!.email!.isNotEmpty) pw.Text(customer.email!),
            if (customer?.phone != null && customer!.phone!.isNotEmpty) pw.Text(customer.phone!),
            if (customer?.gstNumber != null && customer!.gstNumber!.isNotEmpty) pw.Text('GST: ${customer.gstNumber!}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget buildPaymentDetails(Map<String, String> settings) {
    String bankDetails = settings['bankDetails'] ?? '';
    String upiId = settings['upiId'] ?? '';
    String upiQrPath = settings['upiQrPath'] ?? '';

    if (bankDetails.isEmpty && upiId.isEmpty && upiQrPath.isEmpty) {
      return pw.SizedBox.shrink();
    }

    pw.Widget qrWidget = pw.SizedBox.shrink();
    if (upiQrPath.isNotEmpty) {
      try {
        final imageBytes = File(upiQrPath).readAsBytesSync();
        qrWidget = pw.Container(
          height: 60,
          width: 60,
          child: pw.Image(pw.MemoryImage(imageBytes)),
        );
      } catch (e) {
        // Failed to load QR
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Payment Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (bankDetails.isNotEmpty) ...[
                    pw.Text('Bank Transfer:', style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                    pw.Text(bankDetails),
                    pw.SizedBox(height: 4),
                  ],
                  if (upiId.isNotEmpty) ...[
                    pw.Text('UPI ID:', style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                    pw.Text(upiId),
                  ],
                ]
              )
            ),
            if (upiQrPath.isNotEmpty) qrWidget,
          ]
        )
      ]
    );
  }
}

class ClassicTemplate {
  static void build(pw.Document pdf, pw.ThemeData theme, Invoice invoice, Customer? customer, Map<String, String> settings) {
    final currencyFormat = NumberFormat.currency(symbol: settings['defaultCurrency'] ?? '\$');

    pdf.addPage(pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (context) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 20),
        child: PdfUtils.buildHeader('INVOICE', invoice.invoiceNumber, invoice.issueDate, invoice.dueDate),
      ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(color: PdfColors.grey)),
      ),
      build: (context) => [
        PdfUtils.buildCompanyCustomerInfo(settings, customer),
        pw.SizedBox(height: 30),
        pw.TableHelper.fromTextArray(
          headers: ['Description', 'Qty', 'Unit Price', 'Total'],
          data: invoice.items.map((i) => [i.description, i.quantity.toString(), currencyFormat.format(i.unitPrice), currencyFormat.format(i.total)]).toList(),
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xff2c3e50)),
          cellAlignment: pw.Alignment.centerRight,
          cellAlignments: {0: pw.Alignment.centerLeft},
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Subtotal: ${currencyFormat.format(invoice.subtotal)}'),
              if (invoice.discount > 0) pw.Text('Discount: -${currencyFormat.format(invoice.discount)}'),
              if (invoice.taxAmount > 0) pw.Text('Tax: ${currencyFormat.format(invoice.taxAmount)}'),
              pw.Container(width: 120, child: pw.Divider(color: PdfColors.grey400)),
              pw.Text('Total: ${currencyFormat.format(invoice.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            ]
          )
        ),
        pw.SizedBox(height: 40),
        _buildFooterNotes(invoice, settings),
      ],
    ));
  }

  static pw.Widget _buildFooterNotes(Invoice invoice, Map<String, String> settings) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfUtils.buildPaymentDetails(settings),
              pw.SizedBox(height: 10),
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                pw.Text('Notes:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(invoice.notes!),
                pw.SizedBox(height: 10),
              ],
              if (invoice.terms != null && invoice.terms!.isNotEmpty) ...[
                pw.Text('Terms & Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(invoice.terms!),
              ],
            ]
          )
        ),
        pw.SizedBox(width: 20),
        pw.Container(
          width: 60,
          height: 60,
          child: pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: 'INV:${invoice.invoiceNumber}|TOTAL:${invoice.total}')
        )
      ]
    );
  }
}

class ModernTemplate {
  static void build(pw.Document pdf, pw.ThemeData theme, Invoice invoice, Customer? customer, Map<String, String> settings) {
    final currencyFormat = NumberFormat.currency(symbol: settings['defaultCurrency'] ?? '\$');
    final primaryColor = PdfColor.fromInt(0xff3b82f6);
    pdf.addPage(pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      header: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(32),
        color: primaryColor,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
            pw.Text('#${invoice.invoiceNumber}', style: pw.TextStyle(fontSize: 20, color: PdfColors.white)),
          ]
        )
      ),
      footer: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(32),
        alignment: pw.Alignment.center,
        child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(color: PdfColors.grey)),
      ),
      build: (context) => [
        pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfUtils.buildCompanyCustomerInfo(settings, customer),
              pw.SizedBox(height: 30),
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Qty', 'Price', 'Total'],
                data: invoice.items.map((i) => [i.description, i.quantity.toString(), currencyFormat.format(i.unitPrice), currencyFormat.format(i.total)]).toList(),
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor),
                headerDecoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 2))),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
                cellAlignment: pw.Alignment.centerRight,
                cellAlignments: {0: pw.Alignment.centerLeft},
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Subtotal: ${currencyFormat.format(invoice.subtotal)}'),
                    if (invoice.discount > 0) pw.Text('Discount: -${currencyFormat.format(invoice.discount)}'),
                    if (invoice.taxAmount > 0) pw.Text('Tax: ${currencyFormat.format(invoice.taxAmount)}'),
                    pw.SizedBox(height: 10),
                    pw.Text('Total: ${currencyFormat.format(invoice.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20, color: primaryColor)),
                  ]
                )
              ),
              pw.SizedBox(height: 40),
              ClassicTemplate._buildFooterNotes(invoice, settings), // Reuse notes rendering
            ]
          )
        )
      ],
    ));
  }
}

class MinimalTemplate {
  static void build(pw.Document pdf, pw.ThemeData theme, Invoice invoice, Customer? customer, Map<String, String> settings) {
    final currencyFormat = NumberFormat.currency(symbol: settings['defaultCurrency'] ?? '\$');
    pdf.addPage(pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Text('Invoice', style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
        pw.SizedBox(height: 10),
        pw.Text(invoice.invoiceNumber, style: pw.TextStyle(fontSize: 18, color: PdfColors.grey)),
        pw.SizedBox(height: 40),
        PdfUtils.buildCompanyCustomerInfo(settings, customer),
        pw.SizedBox(height: 40),
        pw.TableHelper.fromTextArray(
          headers: ['Description', 'Qty', 'Price', 'Total'],
          data: invoice.items.map((i) => [i.description, i.quantity.toString(), currencyFormat.format(i.unitPrice), currencyFormat.format(i.total)]).toList(),
          border: null,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerRight,
          cellAlignments: {0: pw.Alignment.centerLeft},
        ),
        pw.Divider(),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.SizedBox(height: 10),
              pw.Text('Total due: ${currencyFormat.format(invoice.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24)),
            ]
          )
        ),
        pw.SizedBox(height: 60),
        ClassicTemplate._buildFooterNotes(invoice, settings),
      ],
    ));
  }
}

class CorporateTemplate {
  static void build(pw.Document pdf, pw.ThemeData theme, Invoice invoice, Customer? customer, Map<String, String> settings) {
    final currencyFormat = NumberFormat.currency(symbol: settings['defaultCurrency'] ?? '\$');
    pdf.addPage(pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      pageTheme: pw.PageTheme(
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Center(
            child: pw.Transform.rotate(
              angle: 0.5,
              child: pw.Text(invoice.status.name.toUpperCase(), style: pw.TextStyle(color: PdfColors.grey200, fontSize: 100, fontWeight: pw.FontWeight.bold)),
            )
          )
        )
      ),
      header: (context) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 20),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(settings['companyName'] ?? 'Antigravity Systems', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Container(width: 100, height: 30, child: pw.BarcodeWidget(barcode: pw.Barcode.code128(), data: invoice.invoiceNumber)),
          ]
        ),
      ),
      build: (context) => [
        pw.Divider(),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('BILL TO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(customer?.name ?? 'Unknown'),
                if (customer?.address != null) pw.Text(customer!.address!),
              ]
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('INVOICE DETAILS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Number: ${invoice.invoiceNumber}'),
                pw.Text('Issue Date: ${PdfUtils.dateFormat.format(invoice.issueDate)}'),
                pw.Text('Due Date: ${PdfUtils.dateFormat.format(invoice.dueDate)}'),
              ]
            ),
          ]
        ),
        pw.SizedBox(height: 30),
        pw.TableHelper.fromTextArray(
          headers: ['Description', 'Qty', 'Unit Price', 'Total'],
          data: invoice.items.map((i) => [i.description, i.quantity.toString(), currencyFormat.format(i.unitPrice), currencyFormat.format(i.total)]).toList(),
          border: pw.TableBorder.symmetric(inside: const pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellAlignment: pw.Alignment.centerRight,
          cellAlignments: {0: pw.Alignment.centerLeft},
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Subtotal: ${currencyFormat.format(invoice.subtotal)}'),
              if (invoice.discount > 0) pw.Text('Discount: -${currencyFormat.format(invoice.discount)}'),
              if (invoice.taxAmount > 0) pw.Text('Tax: ${currencyFormat.format(invoice.taxAmount)}'),
              pw.Container(width: 150, child: pw.Divider()),
              pw.Text('Total: ${currencyFormat.format(invoice.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            ]
          )
        ),
        pw.SizedBox(height: 40),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  PdfUtils.buildPaymentDetails(settings),
                  pw.SizedBox(height: 10),
                  pw.Text('Terms & Conditions', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(invoice.terms ?? 'Please pay within the due date.'),
                ]
              )
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(width: 150, height: 40, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)))),
                pw.SizedBox(height: 4),
                pw.Text('Authorized Signature', style: const pw.TextStyle(color: PdfColors.grey)),
              ]
            )
          ]
        )
      ],
    ));
  }
}
