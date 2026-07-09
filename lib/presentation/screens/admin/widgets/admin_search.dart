import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

/// Custom search text input box styled with a premium glass surface and Champagne Gold accents.
class AdminSearch extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback onClear;

  const AdminSearch({
    super.key,
    required this.controller,
    required this.placeholder,
    this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0x9E11141A) : const Color(0xB5FFFFFF);
    final Color borderColor = isDark ? const Color(0x1AFFFFFF) : const Color(0x1F000000);
    final Color textColor = isDark ? Colors.white : const Color(0xFF090A0D);
    final Color hintColor = isDark ? const Color(0xFFAAB4AE) : const Color(0xFF6B7280);
    final Color iconColor = const Color(0xFFDFBA73); // Champagne Gold

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
        
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.sansBody(fontSize: 14, color: textColor),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTheme.sansBody(
            fontSize: 14,
            color: hintColor,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: iconColor,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: iconColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
