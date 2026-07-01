import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Centralized Filter / Theme Label Chip.
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? AppTheme.darkGold : AppTheme.lightGold;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : Colors.transparent,
          border: Border.all(
            color:
                isSelected
                    ? Colors.transparent
                    : (isDark ? AppTheme.darkLine : AppTheme.lightLine),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTheme.sansBody(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color:
                isSelected
                    ? Colors.white
                    : (isDark ? AppTheme.darkInk : AppTheme.lightInk),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
