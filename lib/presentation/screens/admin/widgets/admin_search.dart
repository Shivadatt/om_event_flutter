import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

/// Reusable Admin Search bar widget.
class AdminSearch extends StatelessWidget {
  final String placeholder;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AdminSearch({
    super.key,
    required this.placeholder,
    required this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1915),
        border: Border.all(color: const Color(0x21FFFFFF), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.sansBody(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTheme.sansBody(
            fontSize: 14,
            color: const Color(0xFFAAB4AE),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFFC8A26A),
          ),
          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
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
