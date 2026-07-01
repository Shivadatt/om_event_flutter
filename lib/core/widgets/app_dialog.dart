import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Centralized Custom Dialog Frame component.
class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      title: Text(
        title,
        style: AppTheme.serifHeader(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
        ),
      ),
      content: content,
      actions: actions,
    );
  }
}
