import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

/// Reusable Admin Pagination control widget.
class AdminPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const AdminPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 14,
            color: Colors.white,
          ),
          onPressed:
              currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        const SizedBox(width: 16),
        Text(
          "PAGE $currentPage OF $totalPages",
          style: AppTheme.sansBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFC8A26A),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.white,
          ),
          onPressed:
              currentPage < totalPages
                  ? () => onPageChanged(currentPage + 1)
                  : null,
        ),
      ],
    );
  }
}
