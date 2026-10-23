import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';

/// Header widget for the Admin Sidebar, supporting both expanded and collapsed modes.
class AdminSidebarHeader extends StatelessWidget {
  final bool isCollapsed;
  final bool isDark;

  const AdminSidebarHeader({
    super.key,
    required this.isCollapsed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCollapsed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkLine : AppColors.lightLine,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkForestSecondary : AppColors.lightForestSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryAccent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Text(
                "OE",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryAccent,
                  fontFamily: 'serif',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "OM EVENTS",
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: isDark ? AppColors.darkInk : AppColors.lightInk,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "STUDIO ADMIN",
                    style: AppTheme.sansBody(
                      fontSize: 9,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkLine : AppColors.lightLine,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, size: 20, color: AppColors.primaryAccent),
              tooltip: "Open Menu",
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkForestSecondary : AppColors.lightForestSecondary,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: const Text(
              "OE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryAccent,
                fontFamily: 'serif',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
