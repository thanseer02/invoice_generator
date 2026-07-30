import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../widgets/inputs/app_text_field.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/feedback/app_snackbar.dart';
import '../../domain/models/customer.dart';
import 'customer_viewmodel.dart';

class CustomerFormScreen extends StatefulWidget {
  final String? customerId;

  const CustomerFormScreen({super.key, this.customerId});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _gstController;
  late final TextEditingController _notesController;

  Customer? _existingCustomer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _gstController = TextEditingController();
    _notesController = TextEditingController();
    
    _loadCustomer();
  }

  void _loadCustomer() {
    if (widget.customerId != null) {
      final vm = context.read<CustomerViewModel>();
      try {
        _existingCustomer = vm.customers.firstWhere((c) => c.id == widget.customerId);
        _nameController.text = _existingCustomer!.name;
        _emailController.text = _existingCustomer!.email ?? '';
        _phoneController.text = _existingCustomer!.phone ?? '';
        _addressController.text = _existingCustomer!.address ?? '';
        _gstController.text = _existingCustomer!.gstNumber ?? '';
        _notesController.text = _existingCustomer!.notes ?? '';
      } catch (e) {
        // Not found
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final vm = context.read<CustomerViewModel>();
      
      final customer = Customer(
        id: _existingCustomer?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        gstNumber: _gstController.text.trim().isEmpty ? null : _gstController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        isFavorite: _existingCustomer?.isFavorite ?? false,
        createdAt: _existingCustomer?.createdAt ?? DateTime.now(),
      );

      if (_existingCustomer != null) {
        await vm.updateCustomer(customer);
        if (mounted) AppSnackbar.showSuccess(context, 'Customer updated successfully');
      } else {
        await vm.addCustomer(customer);
        if (mounted) AppSnackbar.showSuccess(context, 'Customer added successfully');
      }

      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(_existingCustomer != null ? 'Edit Customer' : 'Add Customer'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.edgeInsetsAllLg,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Name *',
                controller: _nameController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Phone',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Address',
                controller: _addressController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'GST Number',
                controller: _gstController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Notes',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: 'Save Customer',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
