import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Centralized List Pagination controller.
class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
          onPressed:
              currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        const SizedBox(width: 16),
        Text(
          "PAGE $currentPage OF $totalPages",
          style: AppTheme.sansBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          onPressed:
              currentPage < totalPages
                  ? () => onPageChanged(currentPage + 1)
                  : null,
        ),
      ],
    );
  }
}
