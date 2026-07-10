import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';
import '../../core/constants/app_colors.dart';

/// Centralized Text Form Input component.
class AppTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final double borderRadius;

  const AppTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve dynamic colors based on theme context
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTheme.sansBody(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: goldColor,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            style: AppTheme.sansBody(
              fontSize: 14,
              color: inkColor,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTheme.sansBody(
                fontSize: 14,
                color: mutedColor,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: true,
              fillColor: paperColor,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: lineColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: goldColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
