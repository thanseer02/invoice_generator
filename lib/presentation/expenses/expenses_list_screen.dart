import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'expense_viewmodel.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/expense.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/expenses/new'),
          ),
        ],
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = vm.filteredExpenses;

          return Column(
            children: [
              _buildFilterBar(context, vm),
              if (expenses.isNotEmpty) _buildChart(context, expenses),
              Expanded(
                child: expenses.isEmpty
                    ? const Center(child: Text('No expenses found.'))
                    : ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return _buildExpenseTile(context, expense, vm);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, ExpenseViewModel vm) {
    return Padding(
      padding: AppSpacing.edgeInsetsAllMd,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: vm.setSearchQuery,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          DropdownButton<String?>(
            value: vm.selectedCategory,
            hint: const Text('All Categories'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Categories')),
              ...vm.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: vm.setCategoryFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<Expense> expenses) {
    final Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, Colors.amber
    ];

    int colorIndex = 0;
    final List<PieChartSectionData> sections = [];
    for (var entry in categoryTotals.entries) {
      if (entry.value > 0) {
        sections.add(PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: entry.value,
          title: entry.key,
          radius: 50,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ));
        colorIndex++;
      }
    }

    if (sections.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 200,
      padding: AppSpacing.edgeInsetsAllMd,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildExpenseTile(BuildContext context, Expense expense, ExpenseViewModel vm) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: const Icon(Icons.receipt, color: AppColors.primary),
      ),
      title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat.yMMMd().format(expense.expenseDate)),
          if (expense.notes != null && expense.notes!.isNotEmpty)
            Text(expense.notes!, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('\$${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              vm.deleteExpense(expense.id);
            },
          ),
        ],
      ),
      onTap: () => context.push('/expenses/new', extra: expense),
    );
  }
}
