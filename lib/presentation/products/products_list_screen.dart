import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import 'product_viewmodel.dart';
import '../../domain/models/product.dart';
import '../../../widgets/cards/app_card.dart';
import '../../../widgets/layout/responsive_layout.dart';

class ProductsListScreen extends StatelessWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/products/add'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Consumer<ProductViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
          
          return Column(
            children: [
              _buildFilters(context, viewModel),
              Expanded(
                child: viewModel.products.isEmpty
                    ? _buildEmptyState()
                    : _buildList(context, viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context, ProductViewModel viewModel) {
    return Padding(
      padding: AppSpacing.edgeInsetsAllMd,
      child: ResponsiveLayout(
        mobile: Column(
          children: [
            _buildSearch(viewModel),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(child: _buildSortDropdown(viewModel)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildCategoryDropdown(viewModel)),
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
            _buildCategoryDropdown(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(ProductViewModel viewModel) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Search by name, SKU or barcode...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: viewModel.setSearchQuery,
    );
  }

  Widget _buildSortDropdown(ProductViewModel viewModel) {
    return DropdownButton<ProductSortOption>(
      value: viewModel.sortOption,
      isExpanded: true,
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(value: ProductSortOption.nameAsc, child: Text('Name (A-Z)')),
        DropdownMenuItem(value: ProductSortOption.nameDesc, child: Text('Name (Z-A)')),
        DropdownMenuItem(value: ProductSortOption.priceHighLow, child: Text('Price (High to Low)')),
        DropdownMenuItem(value: ProductSortOption.priceLowHigh, child: Text('Price (Low to High)')),
        DropdownMenuItem(value: ProductSortOption.newest, child: Text('Newest')),
      ],
      onChanged: (val) {
        if (val != null) viewModel.setSortOption(val);
      },
    );
  }

  Widget _buildCategoryDropdown(ProductViewModel viewModel) {
    final categories = viewModel.availableCategories;
    return DropdownButton<String?>(
      value: viewModel.selectedCategory,
      isExpanded: true,
      underline: const SizedBox(),
      hint: const Text('All Categories'),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('All Categories')),
        ...categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
      ],
      onChanged: viewModel.setCategoryFilter,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          SizedBox(height: AppSpacing.md),
          Text('No products found', style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, ProductViewModel viewModel) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    return ResponsiveLayout(
      mobile: ListView.builder(
        padding: AppSpacing.edgeInsetsAllMd,
        itemCount: viewModel.products.length,
        itemBuilder: (context, index) {
          final product = viewModel.products[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildProductTile(context, product, currencyFormatter, viewModel),
          );
        },
      ),
      desktop: GridView.builder(
        padding: AppSpacing.edgeInsetsAllMd,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 110,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: viewModel.products.length,
        itemBuilder: (context, index) {
          final product = viewModel.products[index];
          return _buildProductTile(context, product, currencyFormatter, viewModel);
        },
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product, NumberFormat format, ProductViewModel viewModel) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.imagePath != null
              ? Image.file(File(product.imagePath!), width: 56, height: 56, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder())
              : _buildPlaceholder(),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\${format.format(product.price)} \${product.unit != null ? "per \${product.unit}" : ""}',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            if (product.sku != null && product.sku!.isNotEmpty)
              Text('SKU: \${product.sku}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'edit') context.push('/products/\${product.id}/edit');
            if (val == 'delete') viewModel.deleteProduct(product.id);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
          ],
        ),
        onTap: () => context.push('/products/\${product.id}/edit'),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: const Icon(Icons.inventory, color: AppColors.primary),
    );
  }
}
