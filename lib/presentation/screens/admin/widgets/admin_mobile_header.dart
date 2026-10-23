import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';

/// Top bar header specifically rendered on mobile devices for the Admin layout.
class AdminMobileHeader extends StatelessWidget {
  final dynamic currentAdmin;
  final bool isDark;

  const AdminMobileHeader({
    super.key,
    required this.currentAdmin,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final name = currentAdmin != null
        ? (currentAdmin.name.toString().isNotEmpty
            ? currentAdmin.name.toString()
            : currentAdmin.email.toString().split('@').first)
        : 'Super Admin';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkForest : AppColors.lightForest,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkLine : AppColors.lightLine,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.primaryAccent),
              tooltip: "Open Menu",
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkForestSecondary : AppColors.lightForestSecondary,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.3),
                width: 1.0,
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "OM EVENTS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.darkInk : AppColors.lightInk,
                  ),
                ),
                Text(
                  "STUDIO ADMIN",
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 20,
                color: Color(0xFFD4AF37),
              ),
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => Get.toNamed('/admin/profile'),
            borderRadius: BorderRadius.circular(14),
            child: CircleAvatar(
              radius: 13,
              backgroundColor: const Color(0xFF1E3027),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
