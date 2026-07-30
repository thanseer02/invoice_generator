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
  
  String _selectedCategory = 'Other';
  DateTime _expenseDate = DateTime.now();
  String? _receiptPath;
  bool _isOcrProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toString();
      _notesController.text = widget.expense!.notes ?? '';
      _selectedCategory = widget.expense!.category;
      _expenseDate = widget.expense!.expenseDate;
      _receiptPath = widget.expense!.receiptPath;
    } else {
      _selectedCategory = context.read<ExpenseViewModel>().categories.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _receiptPath = pickedFile.path;
      });
    }
  }

  Future<void> _runOcr() async {
    if (_receiptPath == null) return;
    
    setState(() => _isOcrProcessing = true);
    
    try {
      final amount = await OcrService.extractTotalAmountFromImage(_receiptPath!);
      if (amount != null && mounted) {
        setState(() {
          _amountController.text = amount.toStringAsFixed(2);
        });
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
        setState(() => _isOcrProcessing = false);
      }
    }
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      category: _selectedCategory,
      amount: amount,
      expenseDate: _expenseDate,
      notes: _notesController.text,
      receiptPath: _receiptPath,
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
              
              DropdownButtonFormField<String>(
                initialValue: categories.contains(_selectedCategory) ? _selectedCategory : categories.first,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_expenseDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _expenseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() => _expenseDate = date);
                  }
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
        if (_receiptPath != null) ...[
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
                    File(_receiptPath!),
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
                      onPressed: () => setState(() => _receiptPath = null),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isOcrProcessing ? null : _runOcr,
              icon: _isOcrProcessing 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.document_scanner),
              label: Text(_isOcrProcessing ? 'Scanning...' : 'Scan with OCR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
