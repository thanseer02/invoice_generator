import 'package:flutter/material.dart';

class AppDialogs {
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
