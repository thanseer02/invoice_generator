import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/cards/app_card.dart';
import '../../domain/models/customer.dart';
import 'customer_viewmodel.dart';

class CustomerDetailScreen extends StatelessWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerViewModel>(
      builder: (context, viewModel, child) {
        Customer? customer;
        try {
          customer = viewModel.customers.firstWhere((c) => c.id == customerId);
        } catch (e) {
          // Not found
        }

        if (customer == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Customer Details')),
            body: const Center(child: Text('Customer not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name),
            actions: [
              IconButton(
                icon: Icon(
                  customer.isFavorite ? Icons.star : Icons.star_border,
                  color: customer.isFavorite ? Colors.amber : null,
                ),
                onPressed: () => viewModel.toggleFavorite(customer!),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/customers/\${customer!.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () async {
                  await viewModel.deleteCustomer(customer!.id);
                  if (context.mounted) context.pop();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: AppSpacing.edgeInsetsAllLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, customer),
                const SizedBox(height: AppSpacing.lg),
                _buildQuickActions(customer),
                const SizedBox(height: AppSpacing.lg),
                _buildDetailsCard(context, customer),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Customer customer) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            customer.name[0].toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.name, style: Theme.of(context).textTheme.headlineSmall),
              if (customer.email != null) Text(customer.email!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(Customer customer) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (customer.phone != null && customer.phone!.isNotEmpty)
          ActionChip(
            avatar: const Icon(Icons.phone, size: 16),
            label: const Text('Call'),
            onPressed: () => _launchUrl('tel:\${customer.phone}'),
          ),
        if (customer.email != null && customer.email!.isNotEmpty)
          ActionChip(
            avatar: const Icon(Icons.email, size: 16),
            label: const Text('Email'),
            onPressed: () => _launchUrl('mailto:\${customer.email}'),
          ),
        ActionChip(
          avatar: const Icon(Icons.receipt_long, size: 16),
          label: const Text('New Invoice'),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context, Customer customer) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          _buildDetailRow('Phone', customer.phone ?? 'N/A'),
          _buildDetailRow('Email', customer.email ?? 'N/A'),
          _buildDetailRow('Address', customer.address ?? 'N/A'),
          _buildDetailRow('GST Number', customer.gstNumber ?? 'N/A'),
          if (customer.notes != null && customer.notes!.isNotEmpty) ...[
            const Divider(),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.xs),
            Text(customer.notes!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
