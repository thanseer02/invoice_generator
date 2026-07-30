import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../widgets/inputs/app_text_field.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/feedback/app_snackbar.dart';
import '../../domain/models/invoice.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/models/product.dart';
import 'invoice_viewmodel.dart';
import '../customers/customer_viewmodel.dart';
import '../products/product_viewmodel.dart';
import '../../../widgets/pickers/app_date_picker.dart';

class InvoiceFormScreen extends StatefulWidget {
  final String? invoiceId;

  const InvoiceFormScreen({super.key, this.invoiceId});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _invoiceNumController;
  late final TextEditingController _notesController;
  late final TextEditingController _termsController;
  late final TextEditingController _discountController;
  late final TextEditingController _taxController;

  String? _selectedCustomerId;
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));
  List<InvoiceItem> _items = [];
  InvoiceStatus _status = InvoiceStatus.draft;

  Invoice? _existingInvoice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _invoiceNumController = TextEditingController(text: 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}');
    _notesController = TextEditingController();
    _termsController = TextEditingController();
    _discountController = TextEditingController(text: '0');
    _taxController = TextEditingController(text: '0');
    
    _loadInvoice();
  }

  void _loadInvoice() {
    if (widget.invoiceId != null) {
      final vm = context.read<InvoiceViewModel>();
      try {
        _existingInvoice = vm.invoices.firstWhere((i) => i.id == widget.invoiceId);
        _invoiceNumController.text = _existingInvoice!.invoiceNumber;
        _selectedCustomerId = _existingInvoice!.customerId;
        _issueDate = _existingInvoice!.issueDate;
        _dueDate = _existingInvoice!.dueDate;
        _notesController.text = _existingInvoice!.notes ?? '';
        _termsController.text = _existingInvoice!.terms ?? '';
        _discountController.text = _existingInvoice!.discount.toString();
        _taxController.text = _existingInvoice!.taxAmount.toString();
        _items = List.from(_existingInvoice!.items);
        _status = _existingInvoice!.status;
      } catch (e) {
        // Not found
      }
    }
    setState(() => _isLoading = false);
  }

  void _addItem() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ProductSelectorSheet(
        onProductSelected: (Product product) {
          setState(() {
            _items.add(InvoiceItem(
              id: const Uuid().v4(),
              invoiceId: '',
              productId: product.id,
              description: product.name,
              quantity: 1,
              unitPrice: product.price,
              total: product.price,
            ));
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCustomerId == null) {
        AppSnackbar.showError(context, 'Please select a customer');
        return;
      }
      if (_items.isEmpty) {
        AppSnackbar.showError(context, 'Please add at least one item');
        return;
      }

      final vm = context.read<InvoiceViewModel>();
      final invoiceId = _existingInvoice?.id ?? const Uuid().v4();
      
      final taxRate = double.tryParse(_taxController.text) ?? 0.0;
      final discount = double.tryParse(_discountController.text) ?? 0.0;

      final finalItems = _items.map((e) => e.copyWith(invoiceId: invoiceId, total: e.quantity * e.unitPrice)).toList();

      Invoice invoice = Invoice(
        id: invoiceId,
        invoiceNumber: _invoiceNumController.text.trim(),
        customerId: _selectedCustomerId!,
        issueDate: _issueDate,
        dueDate: _dueDate,
        items: finalItems,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        terms: _termsController.text.trim().isEmpty ? null : _termsController.text.trim(),
        discount: discount,
        taxAmount: taxRate,
        status: _status,
        createdAt: _existingInvoice?.createdAt ?? DateTime.now(),
      );

      invoice = InvoiceViewModel.calculateTotals(invoice, taxRate);

      if (_existingInvoice != null) {
        await vm.updateInvoice(invoice);
        if (mounted) AppSnackbar.showSuccess(context, 'Invoice updated successfully');
      } else {
        await vm.addInvoice(invoice);
        if (mounted) AppSnackbar.showSuccess(context, 'Invoice created successfully');
      }

      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(_existingInvoice != null ? 'Edit Invoice' : 'New Invoice'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.edgeInsetsAllLg,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Invoice Number *',
                      controller: _invoiceNumController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Status'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<InvoiceStatus>(
                          isDense: true,
                          value: _status,
                          items: InvoiceStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _status = val);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Consumer<CustomerViewModel>(
                builder: (context, custVm, _) {
                  return InputDecorator(
                    decoration: const InputDecoration(labelText: 'Customer *'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        isDense: true,
                        value: _selectedCustomerId,
                        items: custVm.customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (val) => setState(() => _selectedCustomerId = val),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await AppDatePicker.selectDate(
                          context,
                          initialDate: _issueDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _issueDate = date);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Issue Date'),
                        child: Text(DateFormat.yMMMd().format(_issueDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await AppDatePicker.selectDate(
                          context,
                          initialDate: _dueDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _dueDate = date);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Due Date'),
                        child: Text(DateFormat.yMMMd().format(_dueDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Padding(
                    padding: AppSpacing.edgeInsetsAllSm,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: TextFormField(
                            initialValue: item.quantity.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Qty'),
                            onChanged: (val) {
                              final qty = int.tryParse(val) ?? 1;
                              setState(() {
                                _items[index] = item.copyWith(quantity: qty, total: qty * item.unitPrice);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text('\$${item.total.toStringAsFixed(2)}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => _items.removeAt(index)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              AppButton(
                text: 'Add Item',
                onPressed: _addItem,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Discount Amount',
                      controller: _discountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              AppTextField(
                label: 'Notes',
                controller: _notesController,
                maxLines: 2,
              ),
              AppTextField(
                label: 'Terms & Conditions',
                controller: _termsController,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: 'Save Invoice',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductSelectorSheet extends StatelessWidget {
  final Function(Product) onProductSelected;

  const _ProductSelectorSheet({required this.onProductSelected});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, vm, _) {
        if (vm.products.isEmpty) {
          return const Center(child: Text('No products available. Add some first!'));
        }
        return ListView.builder(
          itemCount: vm.products.length,
          itemBuilder: (context, index) {
            final p = vm.products[index];
            return ListTile(
              title: Text(p.name),
              subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
              onTap: () => onProductSelected(p),
            );
          },
        );
      },
    );
  }
}
