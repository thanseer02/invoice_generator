import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/cards/app_card.dart';
import '../../domain/models/invoice.dart';
import 'invoice_viewmodel.dart';
import '../customers/customer_viewmodel.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceViewModel>(
      builder: (context, viewModel, child) {
        Invoice? invoice;
        try {
          invoice = viewModel.invoices.firstWhere((i) => i.id == invoiceId);
        } catch (e) {
          // Not found
        }

        if (invoice == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Invoice Details')),
            body: const Center(child: Text('Invoice not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(invoice.invoiceNumber),
            actions: [
              PopupMenuButton<String>(
                onSelected: (val) async {
                  if (val == 'edit') {
                    context.push('/invoices/${invoice!.id}/edit');
                  } else if (val == 'duplicate') {
                    await viewModel.duplicateInvoice(invoice!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice duplicated as Draft')));
                      context.pop();
                    }
                  } else if (val == 'delete') {
                    await viewModel.deleteInvoice(invoice!.id);
                    if (context.mounted) context.pop();
                  } else if (val == 'mark_paid') {
                    await viewModel.updateStatus(invoice!, InvoiceStatus.paid);
                  } else if (val == 'mark_cancelled') {
                    await viewModel.updateStatus(invoice!, InvoiceStatus.cancelled);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                  if (invoice!.status != InvoiceStatus.paid)
                    const PopupMenuItem(value: 'mark_paid', child: Text('Mark as Paid')),
                  if (invoice.status != InvoiceStatus.cancelled)
                    const PopupMenuItem(value: 'mark_cancelled', child: Text('Mark as Cancelled')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/invoices/${invoice!.id}/preview'),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Preview PDF'),
          ),
          body: SingleChildScrollView(
            padding: AppSpacing.edgeInsetsAllLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(context, invoice),
                const SizedBox(height: AppSpacing.lg),
                _buildItemsList(context, invoice),
                const SizedBox(height: AppSpacing.lg),
                _buildTotalsCard(context, invoice),
                if ((invoice.notes != null && invoice.notes!.isNotEmpty) || (invoice.terms != null && invoice.terms!.isNotEmpty)) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildNotesCard(context, invoice),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context, Invoice invoice) {
    final dateFormatter = DateFormat.yMMMd();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Invoice: ${invoice.invoiceNumber}', style: Theme.of(context).textTheme.titleLarge),
              _buildStatusIndicator(invoice.status),
            ],
          ),
          const Divider(),
          Consumer<CustomerViewModel>(
            builder: (context, custVm, _) {
              final customerList = custVm.customers.where((c) => c.id == invoice.customerId).toList();
              final customerName = customerList.isNotEmpty ? customerList.first.name : 'Unknown Customer';
              final customerEmail = customerList.isNotEmpty ? customerList.first.email : null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Billed To:', style: TextStyle(color: Colors.grey)),
                  Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (customerEmail != null) Text(customerEmail),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Issue Date:', style: TextStyle(color: Colors.grey)),
                  Text(dateFormatter.format(invoice.issueDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Due Date:', style: TextStyle(color: Colors.grey)),
                  Text(dateFormatter.format(invoice.dueDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, Invoice invoice) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items', style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
          ...invoice.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(item.description)),
                  Expanded(child: Text('${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}')),
                  Text('\$${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(BuildContext context, Invoice invoice) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    return AppCard(
      child: Column(
        children: [
          _buildTotalRow('Subtotal', currencyFormatter.format(invoice.subtotal)),
          if (invoice.discount > 0)
            _buildTotalRow('Discount', '-${currencyFormatter.format(invoice.discount)}'),
          if (invoice.taxAmount > 0)
            _buildTotalRow('Tax', currencyFormatter.format(invoice.taxAmount)),
          const Divider(),
          _buildTotalRow('Total', currencyFormatter.format(invoice.total), isBold: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, Invoice invoice) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            Text('Notes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(invoice.notes!),
            const SizedBox(height: AppSpacing.md),
          ],
          if (invoice.terms != null && invoice.terms!.isNotEmpty) ...[
            Text('Terms & Conditions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(invoice.terms!),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(InvoiceStatus status) {
    Color color;
    switch (status) {
      case InvoiceStatus.paid:
        color = Colors.green;
        break;
      case InvoiceStatus.pending:
        color = Colors.orange;
        break;
      case InvoiceStatus.cancelled:
        color = Colors.red;
        break;
      case InvoiceStatus.draft:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
