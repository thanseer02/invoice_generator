import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/cards/app_card.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  child: Icon(Icons.receipt),
                ),
                title: Text('Invoice #INV-00${index + 1} Created'),
                subtitle: const Text('Just now'),
                trailing: const Text('\$150.00'),
              );
            },
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms, delay: 400.ms).slideX(begin: 0.1);
  }
}
