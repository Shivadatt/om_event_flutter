import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Centralized Search Input component.
class AppSearchBar extends StatelessWidget {
  final String placeholder;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    required this.placeholder,
    required this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
        border: Border.all(
          color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.sansBody(
          fontSize: 14,
          color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTheme.sansBody(
            fontSize: 14,
            color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
          ),
          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: onClear,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
