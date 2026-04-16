import 'package:flutter/material.dart';
import 'package:opini_kopi/constants/app_colors.dart';

class SnackbarUtils {
  const SnackbarUtils._();

  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.danger);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.primary);
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
