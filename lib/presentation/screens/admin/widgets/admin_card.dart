import 'package:flutter/material.dart';

/// Reusable Admin Container Card widget redesigned for luxury SaaS styling.
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? widgetBorderColor;

  const AdminCard({
    super.key,
    required this.child,
    this.padding,
    this.widgetBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0x9E11141A) : const Color(0xB5FFFFFF);
    final Color borderColor = isDark ? const Color(0x1AFFFFFF) : const Color(0x1F000000);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: widgetBorderColor ?? borderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
          
        ),
        child: child,
      ),
    );
  }
}
