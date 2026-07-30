import 'package:flutter/material.dart';
import '../widgets/buttons/app_button.dart';
import '../widgets/inputs/app_text_field.dart';
import '../widgets/cards/app_card.dart';
import '../widgets/feedback/app_snackbar.dart';
import '../widgets/feedback/app_dialogs.dart';
import '../widgets/pickers/app_date_picker.dart';
import '../utils/formatters/currency_formatter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Gallery'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Typography', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          const Text('This is Body Large text.'),
          const SizedBox(height: 32),
          Text('Buttons', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              AppButton(text: 'Primary', onPressed: () {}),
              AppButton(text: 'Secondary', variant: AppButtonVariant.secondary, onPressed: () {}),
              AppButton(text: 'Outlined', variant: AppButtonVariant.outlined, onPressed: () {}),
              AppButton(text: 'Text', variant: AppButtonVariant.text, onPressed: () {}),
            ],
          ),
          const SizedBox(height: 32),
          Text('Inputs', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          const AppTextField(label: 'Username', hint: 'Enter your username'),
          const SizedBox(height: 32),
          Text('Feedback & Utilities', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Card Component Example'),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Show Snackbar',
                  onPressed: () => AppSnackbar.showSuccess(context, 'Operation successful!'),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Show Dialog',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => AppDialogs.showConfirmDialog(
                    context,
                    title: 'Confirm Action',
                    content: 'Are you sure you want to proceed?',
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Select Date',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => AppDatePicker.selectDate(
                    context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Currency Formatting', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(
            'Formatted value: ${CurrencyFormatter.format(1234.56)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
