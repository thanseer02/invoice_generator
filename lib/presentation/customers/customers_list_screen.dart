import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import 'customer_viewmodel.dart';
import '../../../widgets/cards/app_card.dart';
import '../../../widgets/inputs/app_text_field.dart';
import '../../../widgets/layout/responsive_layout.dart';

class CustomersListScreen extends StatelessWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import') context.read<CustomerViewModel>().importFromCsv();
              if (value == 'export') context.read<CustomerViewModel>().exportToCsv();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'import', child: Text('Import from CSV')),
              const PopupMenuItem(value: 'export', child: Text('Export to CSV')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/customers/add'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Consumer<CustomerViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
          
          return Column(
            children: [
              _buildFilters(context, viewModel),
              Expanded(
                child: viewModel.customers.isEmpty
                    ? _buildEmptyState()
                    : _buildList(context, viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context, CustomerViewModel viewModel) {
    return Padding(
      padding: AppSpacing.edgeInsetsAllMd,
      child: ResponsiveLayout(
        mobile: Column(
          children: [
            _buildSearch(viewModel),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSortDropdown(viewModel),
                _buildFavoriteToggle(viewModel),
              ],
            ),
          ],
        ),
        desktop: Row(
          children: [
            Expanded(flex: 2, child: _buildSearch(viewModel)),
            const SizedBox(width: AppSpacing.md),
            _buildSortDropdown(viewModel),
            const SizedBox(width: AppSpacing.md),
            _buildFavoriteToggle(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(CustomerViewModel viewModel) {
    return AppTextField(
      hintText: 'Search by name, email or GST...',
      prefixIcon: const Icon(Icons.search),
      onChanged: viewModel.setSearchQuery,
    );
  }

  Widget _buildSortDropdown(CustomerViewModel viewModel) {
    return DropdownButton<CustomerSortOption>(
      value: viewModel.sortOption,
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(value: CustomerSortOption.nameAsc, child: Text('Name (A-Z)')),
        DropdownMenuItem(value: CustomerSortOption.nameDesc, child: Text('Name (Z-A)')),
        DropdownMenuItem(value: CustomerSortOption.newest, child: Text('Newest First')),
        DropdownMenuItem(value: CustomerSortOption.oldest, child: Text('Oldest First')),
      ],
      onChanged: (val) {
        if (val != null) viewModel.setSortOption(val);
      },
    );
  }

  Widget _buildFavoriteToggle(CustomerViewModel viewModel) {
    return FilterChip(
      label: const Text('Favorites'),
      selected: viewModel.showFavoritesOnly,
      onSelected: (_) => viewModel.toggleFavoritesOnly(),
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: AppSpacing.md),
          Text('No customers found', style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, CustomerViewModel viewModel) {
    return ListView.builder(
      padding: AppSpacing.edgeInsetsAllMd,
      itemCount: viewModel.customers.length,
      itemBuilder: (context, index) {
        final customer = viewModel.customers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(customer.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary)),
              ),
              title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(customer.email ?? customer.phone ?? 'No contact info'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      customer.isFavorite ? Icons.star : Icons.star_border,
                      color: customer.isFavorite ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () => viewModel.toggleFavorite(customer),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => context.push('/customers/\${customer.id}'),
            ),
          ),
        );
      },
    );
  }
}
