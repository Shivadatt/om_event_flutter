import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Centralized Divider line.
class AppDivider extends StatelessWidget {
  final double height;

  const AppDivider({super.key, this.height = 1});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Divider(
      height: height,
      color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
      thickness: 1,
    );
  }
}
