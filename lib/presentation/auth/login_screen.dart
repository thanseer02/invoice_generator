import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/feedback/app_snackbar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.edgeInsetsAllLg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome to Invoice Generator', 
                style: Theme.of(context).textTheme.headlineMedium, 
                textAlign: TextAlign.center
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                text: 'Sign in with Google',
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().signInWithGoogle();
                  } catch (e) {
                    if(context.mounted) AppSnackbar.showError(context, e.toString());
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: 'Continue as Guest',
                variant: AppButtonVariant.secondary,
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().signInAsGuest();
                  } catch (e) {
                    if(context.mounted) AppSnackbar.showError(context, e.toString());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
