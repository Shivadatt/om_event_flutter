import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

/// Reusable Admin Header toolbar widget.
class AdminHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const AdminHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color titleColor = isDark ? Colors.white : const Color(0xFF090A0D);
    final Color subtitleColor = isDark ? const Color(0xFFAAB4AE) : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "ADMIN",
                      style: AppTheme.sansBody(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFDFBA73),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 12,
                      color: subtitleColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title.toUpperCase(),
                      style: AppTheme.sansBody(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: subtitleColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTheme.serifHeader(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...[
            const SizedBox(width: 16),
            Row(children: actions!),
          ],
        ],
      ),
    );
  }
}
