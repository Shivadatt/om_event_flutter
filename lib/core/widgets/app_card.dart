import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Centralized Container Card widget.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
        border: Border.all(
          color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: card);
    }
    return card;
  }
}
