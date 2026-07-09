import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

class AdminEmptyState extends StatelessWidget {
  final String title;
  final String message;

  const AdminEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color iconColor = const Color(0xFFDFBA73); // Champagne Gold
    final Color titleColor = isDark ? Colors.white : const Color(0xFF090A0D);
    final Color msgColor = isDark ? const Color(0xFFAAB4AE) : const Color(0xFF6B7280);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 44,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: AppTheme.serifHeader(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.sansBody(
                  fontSize: 13,
                  color: msgColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
