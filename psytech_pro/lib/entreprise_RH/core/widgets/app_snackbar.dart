import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Messages de confirmation (turquoise) et d'erreur (rouge).
class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.turquoise);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.error);

  static void _show(BuildContext context, String message, Color color) {
    final wide = MediaQuery.of(context).size.width > 520;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        width: wide ? 440 : null,
        margin: wide ? null : const EdgeInsets.all(16),
        content: Text(message),
      ),
    );
  }
}
