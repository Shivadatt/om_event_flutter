import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const CustomInput({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              filled: true,
              fillColor: Colors.transparent,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
