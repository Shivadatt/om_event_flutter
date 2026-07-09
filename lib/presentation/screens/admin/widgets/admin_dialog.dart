import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

/// Reusable Admin overlay Dialog.
class AdminDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const AdminDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0D1915),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x21FFFFFF), width: 1),
      ),
      title: Text(
        title,
        style: AppTheme.serifHeader(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: content,
      actions: actions,
    );
  }
}
