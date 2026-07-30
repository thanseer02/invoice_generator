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

class InvoicesListScreen extends StatelessWidget {
  const InvoicesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/invoices/add'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Consumer<InvoiceViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
          
          return Column(
            children: [
              _buildFilters(context, viewModel),
              Expanded(
                child: viewModel.invoices.isEmpty
                    ? _buildEmptyState()
                    : _buildList(context, viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context, InvoiceViewModel viewModel) {
    return Padding(
      padding: AppSpacing.edgeInsetsAllMd,
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search by invoice number...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: viewModel.setSearchQuery,
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(viewModel, null, 'All'),
                const SizedBox(width: AppSpacing.sm),
                _buildStatusChip(viewModel, InvoiceStatus.draft, 'Draft'),
                const SizedBox(width: AppSpacing.sm),
                _buildStatusChip(viewModel, InvoiceStatus.pending, 'Pending'),
                const SizedBox(width: AppSpacing.sm),
                _buildStatusChip(viewModel, InvoiceStatus.paid, 'Paid'),
                const SizedBox(width: AppSpacing.sm),
                _buildStatusChip(viewModel, InvoiceStatus.cancelled, 'Cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(InvoiceViewModel viewModel, InvoiceStatus? status, String label) {
    final isSelected = viewModel.statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => viewModel.setStatusFilter(status),
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: AppSpacing.md),
          Text('No invoices found', style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, InvoiceViewModel viewModel) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    return ListView.builder(
      padding: AppSpacing.edgeInsetsAllMd,
      itemCount: viewModel.invoices.length,
      itemBuilder: (context, index) {
        final invoice = viewModel.invoices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(currencyFormatter.format(invoice.total), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  Consumer<CustomerViewModel>(
                    builder: (context, custVm, _) {
                      final customerList = custVm.customers.where((c) => c.id == invoice.customerId).toList();
                      final customerName = customerList.isNotEmpty ? customerList.first.name : 'Unknown Customer';
                      return Text('To: $customerName');
                    },
                  ),
                  Text('Due: ${DateFormat.yMMMd().format(invoice.dueDate)}'),
                  const SizedBox(height: AppSpacing.xs),
                  _buildStatusIndicator(invoice.status),
                ],
              ),
              onTap: () => context.push('/invoices/${invoice.id}'),
            ),
          ),
        );
      },
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
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
