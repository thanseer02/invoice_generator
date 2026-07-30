import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../domain/models/invoice.dart';
import '../../domain/models/customer.dart';

class PdfUtils {
  static final currencyFormat = NumberFormat.currency(symbol: '\$');
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
    String companyName, String companyEmail, String companyPhone, String companyAddress,
    Customer? customer
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('From:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text(companyName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(companyAddress),
            pw.Text(companyEmail),
            pw.Text(companyPhone),
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
}

class ClassicTemplate {
  static void build(pw.Document pdf, pw.ThemeData theme, Invoice invoice, Customer? customer, String cName, String cEmail, String cPhone, String cAddress) {
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
        PdfUtils.buildCompanyCustomerInfo(cName, cEmail, cPhone, cAddress, customer),
        pw.SizedBox(height: 30),
        pw.TableHelper.fromTextArray(
          headers: ['Description', 'Qty', 'Unit Price', 'Total'],
          data: invoice.items.map((i) => [i.description, i.quantity.toString(), PdfUtils.currencyFormat.format(i.unitPrice), PdfUtils.currencyFormat.format(i.total)]).toList(),
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
              pw.Text('Subtotal: ${PdfUtils.currencyFormat.format(invoice.subtotal)}'),
              if (invoice.discount > 0) pw.Text('Discount: -${PdfUtils.currencyFormat.format(invoice.discount)}'),
              if (invoice.taxAmount > 0) pw.Text('Tax: ${PdfUtils.currencyFormat.format(invoice.taxAmount)}'),
              pw.Container(width: 120, child: pw.Divider(color: PdfColors.grey400)),
              pw.Text('Total: ${PdfUtils.currencyFormat.format(invoice.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            ]
          )
        ),
        pw.SizedBox(height: 40),
        _buildFooterNotes(invoice),
      ],
    ));
  }

  static pw.Widget _buildFooterNotes(Invoice invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
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
  static void build(pw.Document pdf, pw.ThemeData theme, Invoice invoice, Customer? customer, String cName, String cEmail, String cPhone, String cAddress) {
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
              PdfUtils.buildCompanyCustomerInfo(cName, cEmail, cPhone, cAddress, customer),
              pw.SizedBox(height: 30),
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Qty', 'Price', 'Total'],
                data: invoice.items.map((i) => [i.description, i.quantity.toString(), PdfUtils.currencyFormat.format(i.unitPrice), PdfUtils.currencyFormat.format(i.total)]).toList(),
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
                    pw.Text('Subtotal: ${PdfUtils.currencyFormat.format(invoice.subtotal)}'),
                    if (invoice.discount > 0) pw.Text('Discount: -${PdfUtils.currencyFormat.format(invoice.discount)}'),
                    if (invoice.taxAmount > 0) pw.Text('Tax: ${PdfUtils.currencyFormat.format(invoice.taxAmount)}'),
                    pw.SizedBox(height: 10),
                    pw.Text('Total: ${PdfUtils.currencyFormat.format(invoice.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20, color: primaryColor)),
                  ]
                )
              ),
              pw.SizedBox(height: 40),
              ClassicTemplate._buildFooterNotes(invoice), // Reuse notes rendering
            ]
          )
        )
      ],
    ));
  }
}

class MinimalTemplate {
  static void build(pw.Document pdf, pw.ThemeData theme, Invoice invoice, Customer? customer, String cName, String cEmail, String cPhone, String cAddress) {
    pdf.addPage(pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Text('Invoice', style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
        pw.SizedBox(height: 10),
        pw.Text(invoice.invoiceNumber, style: pw.TextStyle(fontSize: 18, color: PdfColors.grey)),
        pw.SizedBox(height: 40),
        PdfUtils.buildCompanyCustomerInfo(cName, cEmail, cPhone, cAddress, customer),
        pw.SizedBox(height: 40),
        pw.TableHelper.fromTextArray(
          headers: ['Description', 'Qty', 'Price', 'Total'],
          data: invoice.items.map((i) => [i.description, i.quantity.toString(), PdfUtils.currencyFormat.format(i.unitPrice), PdfUtils.currencyFormat.format(i.total)]).toList(),
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
              pw.Text('Total due: ${PdfUtils.currencyFormat.format(invoice.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24)),
            ]
          )
        ),
        pw.SizedBox(height: 60),
        ClassicTemplate._buildFooterNotes(invoice),
      ],
    ));
  }
}

class CorporateTemplate {
  static void build(pw.Document pdf, pw.ThemeData theme, Invoice invoice, Customer? customer, String cName, String cEmail, String cPhone, String cAddress) {
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
            pw.Text(cName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
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
          data: invoice.items.map((i) => [i.description, i.quantity.toString(), PdfUtils.currencyFormat.format(i.unitPrice), PdfUtils.currencyFormat.format(i.total)]).toList(),
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
              pw.Text('Subtotal: ${PdfUtils.currencyFormat.format(invoice.subtotal)}'),
              if (invoice.discount > 0) pw.Text('Discount: -${PdfUtils.currencyFormat.format(invoice.discount)}'),
              if (invoice.taxAmount > 0) pw.Text('Tax: ${PdfUtils.currencyFormat.format(invoice.taxAmount)}'),
              pw.Container(width: 150, child: pw.Divider()),
              pw.Text('Total: ${PdfUtils.currencyFormat.format(invoice.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
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
