import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/inputs/app_text_field.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/feedback/app_snackbar.dart';
import '../../domain/models/product.dart';
import 'product_viewmodel.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _taxController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _discountController;
  late final TextEditingController _unitController;
  late final TextEditingController _categoryController;

  String? _imagePath;
  Product? _existingProduct;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _priceController = TextEditingController();
    _taxController = TextEditingController();
    _skuController = TextEditingController();
    _barcodeController = TextEditingController();
    _discountController = TextEditingController();
    _unitController = TextEditingController();
    _categoryController = TextEditingController();
    
    _loadProduct();
  }

  void _loadProduct() {
    if (widget.productId != null) {
      final vm = context.read<ProductViewModel>();
      try {
        _existingProduct = vm.products.firstWhere((p) => p.id == widget.productId);
        _nameController.text = _existingProduct!.name;
        _descController.text = _existingProduct!.description ?? '';
        _priceController.text = _existingProduct!.price.toString();
        _taxController.text = _existingProduct!.taxRate.toString();
        _skuController.text = _existingProduct!.sku ?? '';
        _barcodeController.text = _existingProduct!.barcode ?? '';
        _discountController.text = _existingProduct!.discount.toString();
        _unitController.text = _existingProduct!.unit ?? '';
        _categoryController.text = _existingProduct!.category ?? '';
        _imagePath = _existingProduct!.imagePath;
      } catch (e) {
        // Not found
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _taxController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _discountController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final vm = context.read<ProductViewModel>();
      
      final product = Product(
        id: _existingProduct?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        taxRate: double.tryParse(_taxController.text.trim()) ?? 0.0,
        sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
        discount: double.tryParse(_discountController.text.trim()) ?? 0.0,
        unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        imagePath: _imagePath,
        createdAt: _existingProduct?.createdAt ?? DateTime.now(),
      );

      if (_existingProduct != null) {
        await vm.updateProduct(product);
        if (mounted) AppSnackbar.showSuccess(context, 'Product updated successfully');
      } else {
        await vm.addProduct(product);
        if (mounted) AppSnackbar.showSuccess(context, 'Product added successfully');
      }

      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(_existingProduct != null ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.edgeInsetsAllLg,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Product Name *',
                controller: _nameController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Description',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Price *',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        if (double.tryParse(val.trim()) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Tax Rate (%)',
                      controller: _taxController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Discount',
                      controller: _discountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Unit (e.g. pcs, kg)',
                      controller: _unitController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Category',
                controller: _categoryController,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'SKU',
                      controller: _skuController,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Barcode',
                      controller: _barcodeController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: 'Save Product',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            image: _imagePath != null
                ? DecorationImage(
                    image: FileImage(File(_imagePath!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _imagePath == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: AppColors.primary, size: 32),
                    SizedBox(height: 8),
                    Text('Add Photo', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
