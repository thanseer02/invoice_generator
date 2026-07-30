import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/cards/app_card.dart';

class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ActionChip(
                label: const Text('New Invoice'),
                avatar: const Icon(Icons.receipt_long, size: 16),
                onPressed: () => context.push('/invoices/add'),
              ),
              ActionChip(
                label: const Text('View Invoices'),
                avatar: const Icon(Icons.description, size: 16),
                onPressed: () => context.push('/invoices'),
              ),
              ActionChip(
                label: const Text('Add Customer'),
                avatar: const Icon(Icons.person_add, size: 16),
                onPressed: () => context.push('/customers/add'),
              ),
              ActionChip(
                label: const Text('View Customers'),
                avatar: const Icon(Icons.people, size: 16),
                onPressed: () => context.push('/customers'),
              ),
              ActionChip(
                label: const Text('Add Product'),
                avatar: const Icon(Icons.inventory, size: 16),
                onPressed: () => context.push('/products/add'),
              ),
              ActionChip(
                label: const Text('View Products'),
                avatar: const Icon(Icons.inventory_2, size: 16),
                onPressed: () => context.push('/products'),
              ),
              ActionChip(
                label: const Text('View Reports'),
                avatar: const Icon(Icons.analytics, size: 16),
                onPressed: () => context.push('/reports'),
              ),
              ActionChip(
                label: const Text('Log Expense'),
                avatar: const Icon(Icons.money_off, size: 16),
                onPressed: () => context.push('/expenses'),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms, delay: 300.ms).slideX(begin: 0.1);
  }
}
