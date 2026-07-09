import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color activeColor = const Color(0xFFDFBA73); // Champagne Gold
    final Color textColor = isDark ? Colors.white : const Color(0xFF090A0D);
    final Color btnBg = isDark ? const Color(0x7311141A) : const Color(0xB5FFFFFF);
    final Color btnBorder = isDark ? const Color(0x1AFFFFFF) : const Color(0x1F000000);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: btnBg,
            border: Border.all(color: btnBorder, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: currentPage > 1 ? textColor : textColor.withValues(alpha: 0.3),
            ),
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          ),
        ),
        const SizedBox(width: 24),
        Text(
          "PAGE $currentPage OF $totalPages",
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: activeColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 24),
        Container(
          decoration: BoxDecoration(
            color: btnBg,
            border: Border.all(color: btnBorder, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: currentPage < totalPages ? textColor : textColor.withValues(alpha: 0.3),
            ),
            onPressed:
                currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
          ),
        ),
      ],
    );
  }
}
