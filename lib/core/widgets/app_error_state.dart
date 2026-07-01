import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';
import 'app_button.dart';

/// Centralized Error Failure State widget.
class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.serifHeader(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.sansBody(
                fontSize: 14,
                color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(text: "Retry", onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
