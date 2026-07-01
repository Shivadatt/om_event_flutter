import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Centralized Inner Section Title label.
class AppSectionTitle extends StatelessWidget {
  final String title;

  const AppSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.sansBody(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
