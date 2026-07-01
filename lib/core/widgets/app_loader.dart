import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Centralized Loading Activity Indicator.
class AppLoader extends StatelessWidget {
  final String? message;

  const AppLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppTheme.darkGold : AppTheme.lightGold,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTheme.sansBody(
                fontSize: 14,
                color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
