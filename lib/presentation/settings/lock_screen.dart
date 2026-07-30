import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'settings_viewmodel.dart';
import '../../core/theme/app_spacing.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _enteredPin = '';

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
      });
      
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    final vm = context.read<SettingsViewModel>();
    final targetPin = vm.appPin.isEmpty ? '1234' : vm.appPin;
    
    if (_enteredPin == targetPin) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN')),
      );
      setState(() {
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    
    // If PIN is not required, just go to home immediately
    if (!vm.isLoading && !vm.requirePin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            Text('Enter PIN', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPin.length 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            const SizedBox(height: 60),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildKey('1'), _buildKey('2'), _buildKey('3')]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildKey('4'), _buildKey('5'), _buildKey('6')]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildKey('7'), _buildKey('8'), _buildKey('9')]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(width: 80, height: 80),
          _buildKey('0'),
          _buildDeleteKey(),
        ]),
      ],
    );
  }

  Widget _buildKey(String digit) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => _onDigitPressed(digit),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.withValues(alpha: 0.1)),
          child: Text(digit, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: _onDeletePressed,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          child: const Icon(Icons.backspace, size: 28),
        ),
      ),
    );
  }
}
