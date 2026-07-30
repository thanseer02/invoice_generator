import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'settings_viewmodel.dart';
import '../../core/theme/app_spacing.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _gstCtrl;
  late TextEditingController _bankDetailsCtrl;
  late TextEditingController _upiIdCtrl;
  late TextEditingController _currencyCtrl;
  late TextEditingController _prefixCtrl;
  
  String? _logoPath;
  String? _upiQrPath;

  @override
  void initState() {
    super.initState();
    final vm = context.read<SettingsViewModel>();
    
    _nameCtrl = TextEditingController(text: vm.companyName);
    _addressCtrl = TextEditingController(text: vm.companyAddress);
    _emailCtrl = TextEditingController(text: vm.companyEmail);
    _phoneCtrl = TextEditingController(text: vm.companyPhone);
    _gstCtrl = TextEditingController(text: vm.companyGst);
    _bankDetailsCtrl = TextEditingController(text: vm.bankDetails);
    _upiIdCtrl = TextEditingController(text: vm.upiId);
    _currencyCtrl = TextEditingController(text: vm.defaultCurrency);
    _prefixCtrl = TextEditingController(text: vm.invoicePrefix);
    
    _logoPath = vm.logoPath.isEmpty ? null : vm.logoPath;
    _upiQrPath = vm.upiQrPath.isEmpty ? null : vm.upiQrPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _gstCtrl.dispose();
    _bankDetailsCtrl.dispose();
    _upiIdCtrl.dispose();
    _currencyCtrl.dispose();
    _prefixCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          _logoPath = pickedFile.path;
        } else {
          _upiQrPath = pickedFile.path;
        }
      });
    }
  }

  void _saveSettings() {
    if (!_formKey.currentState!.validate()) return;
    
    final vm = context.read<SettingsViewModel>();
    vm.saveMultipleSettings({
      'companyName': _nameCtrl.text,
      'companyAddress': _addressCtrl.text,
      'companyEmail': _emailCtrl.text,
      'companyPhone': _phoneCtrl.text,
      'companyGst': _gstCtrl.text,
      'bankDetails': _bankDetailsCtrl.text,
      'upiId': _upiIdCtrl.text,
      'defaultCurrency': _currencyCtrl.text,
      'invoicePrefix': _prefixCtrl.text,
      'logoPath': _logoPath ?? '',
      'upiQrPath': _upiQrPath ?? '',
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Company Profile Saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.edgeInsetsAllLg,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Branding'),
              _buildImagePicker('Company Logo', _logoPath, () => _pickImage(true)),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildSectionTitle('Contact Information'),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()))),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildSectionTitle('Tax & Formatting'),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _gstCtrl, decoration: const InputDecoration(labelText: 'GST/Tax Number', border: OutlineInputBorder()))),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: TextFormField(controller: _currencyCtrl, decoration: const InputDecoration(labelText: 'Currency Symbol', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _prefixCtrl,
                decoration: const InputDecoration(labelText: 'Invoice Prefix (e.g. INV-)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildSectionTitle('Payment Details (Printed on Invoice)'),
              TextFormField(
                controller: _bankDetailsCtrl,
                decoration: const InputDecoration(labelText: 'Bank Account & IFSC', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _upiIdCtrl,
                decoration: const InputDecoration(labelText: 'UPI ID', border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildImagePicker('UPI QR Code', _upiQrPath, () => _pickImage(false)),
              
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Save Profile'),
                  onPressed: _saveSettings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImagePicker(String label, String? currentPath, VoidCallback onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: onPick,
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
            ),
            child: currentPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(currentPath), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error)),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, color: Colors.grey),
                      SizedBox(height: 4),
                      Text('Upload', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
