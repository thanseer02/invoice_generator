import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'expense_viewmodel.dart';
import '../../domain/models/expense.dart';
import '../../services/ocr/ocr_service.dart';
import '../../core/theme/app_spacing.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;
  
  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  final _categoryNotifier = ValueNotifier<String>('Other');
  final _dateNotifier = ValueNotifier<DateTime>(DateTime.now());
  final _receiptNotifier = ValueNotifier<String?>(null);
  final _ocrProcessingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toString();
      _notesController.text = widget.expense!.notes ?? '';
      _categoryNotifier.value = widget.expense!.category;
      _dateNotifier.value = widget.expense!.expenseDate;
      _receiptNotifier.value = widget.expense!.receiptPath;
    } else {
      // Must read outside of initState, but since categories are likely loaded, we can delay it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final categories = context.read<ExpenseViewModel>().categories;
          if (categories.isNotEmpty) _categoryNotifier.value = categories.first;
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _categoryNotifier.dispose();
    _dateNotifier.dispose();
    _receiptNotifier.dispose();
    _ocrProcessingNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      _receiptNotifier.value = pickedFile.path;
    }
  }

  Future<void> _runOcr() async {
    final path = _receiptNotifier.value;
    if (path == null) return;
    
    _ocrProcessingNotifier.value = true;
    
    try {
      final amount = await OcrService.extractTotalAmountFromImage(path);
      if (amount != null && mounted) {
        _amountController.text = amount.toStringAsFixed(2);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amount extracted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extract amount: $e')),
        );
      }
    } finally {
      if (mounted) {
        _ocrProcessingNotifier.value = false;
      }
    }
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      category: _categoryNotifier.value,
      amount: amount,
      expenseDate: _dateNotifier.value,
      notes: _notesController.text,
      receiptPath: _receiptNotifier.value,
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final vm = context.read<ExpenseViewModel>();
    if (widget.expense == null) {
      vm.addExpense(expense);
    } else {
      vm.updateExpense(expense);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.read<ExpenseViewModel>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'New Expense' : 'Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExpense,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.edgeInsetsAllLg,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildReceiptSection(),
              const SizedBox(height: AppSpacing.xl),
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  if (double.tryParse(val) == null) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              
              ValueListenableBuilder<String>(
                valueListenable: _categoryNotifier,
                builder: (context, cat, _) {
                  return DropdownButtonFormField<String>(
                    initialValue: categories.contains(cat) ? cat : (categories.isNotEmpty ? categories.first : null),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) _categoryNotifier.value = val;
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              
              ValueListenableBuilder<DateTime>(
                valueListenable: _dateNotifier,
                builder: (context, dateVal, _) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle: Text(DateFormat.yMMMd().format(dateVal)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dateVal,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        _dateNotifier.value = date;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptSection() {
    return ValueListenableBuilder<String?>(
      valueListenable: _receiptNotifier,
      builder: (context, receiptPath, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Receipt', style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Attach'),
                ),
              ],
            ),
            if (receiptPath != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(receiptPath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                          onPressed: () => _receiptNotifier.value = null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ValueListenableBuilder<bool>(
                valueListenable: _ocrProcessingNotifier,
                builder: (context, isOcrProcessing, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isOcrProcessing ? null : _runOcr,
                      icon: isOcrProcessing 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.document_scanner),
                      label: Text(isOcrProcessing ? 'Scanning...' : 'Scan with OCR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
