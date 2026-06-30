import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool isOverlay;

  const LoadingIndicator({
    super.key,
    this.message,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? AppTheme.darkGold : AppTheme.lightGold,
          ),
          strokeWidth: 3,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTheme.sansBody(
              fontSize: 13,
              color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
            ),
          ),
        ],
      ],
    );

    if (!isOverlay) {
      return Center(child: child);
    }

    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: (isDark ? AppTheme.darkCream : AppTheme.lightCream).withValues(alpha: 0.58),
            ),
          ),
        ),
        Center(child: child),
      ],
    );
  }
}
