import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../../domain/models/invoice.dart';
import '../../domain/models/customer.dart';
import '../../services/pdf/pdf_generation_service.dart';
import '../settings/settings_viewmodel.dart';
import '../../services/pdf/pdf_export_service.dart';
import 'invoice_viewmodel.dart';
import '../customers/customer_viewmodel.dart';
import '../../../widgets/feedback/app_snackbar.dart';

class PdfPreviewScreen extends StatefulWidget {
  final String invoiceId;

  const PdfPreviewScreen({super.key, required this.invoiceId});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  PdfTemplate _selectedTemplate = PdfTemplate.classic;

  @override
  Widget build(BuildContext context) {
    final invoiceVm = context.watch<InvoiceViewModel>();
    final customerVm = context.watch<CustomerViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();

    Invoice? invoice;
    try {
      invoice = invoiceVm.invoices.firstWhere((i) => i.id == widget.invoiceId);
    } catch (e) {
      // not found
    }

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PDF Preview')),
        body: const Center(child: Text('Invoice not found')),
      );
    }

    Customer? customer;
    try {
      customer = customerVm.customers.firstWhere((c) => c.id == invoice!.customerId);
    } catch (e) {
      // not found
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: PdfPreview(
        build: (format) => PdfGenerationService.generateInvoicePdf(
          invoice!,
          customer,
          settingsVm.settings,
          template: _selectedTemplate,
        ),
        canChangeOrientation: false,
        canChangePageFormat: false,
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.save),
            onPressed: (context, build, pageFormat) async {
              final bytes = await build(pageFormat);
              final path = await PdfExportService.savePdfLocally(bytes, 'Invoice_${invoice!.invoiceNumber}.pdf');
              if (context.mounted && path != null) {
                AppSnackbar.showSuccess(context, kIsWeb ? 'Downloaded' : 'Saved to $path');
              }
            },
          ),
          PdfPreviewAction(
            icon: const Icon(Icons.email),
            onPressed: (context, build, pageFormat) async {
              final bytes = await build(pageFormat);
              await PdfExportService.emailPdf(bytes, 'Invoice_${invoice!.invoiceNumber}.pdf');
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SegmentedButton<PdfTemplate>(
            segments: PdfTemplate.values.map((t) {
              return ButtonSegment<PdfTemplate>(
                value: t,
                label: Text(t.name[0].toUpperCase() + t.name.substring(1)),
              );
            }).toList(),
            selected: {_selectedTemplate},
            onSelectionChanged: (Set<PdfTemplate> selection) {
              setState(() {
                _selectedTemplate = selection.first;
              });
            },
          ),
        ),
      ),
    );
  }
}
