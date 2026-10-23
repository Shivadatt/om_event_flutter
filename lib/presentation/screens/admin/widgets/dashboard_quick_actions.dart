import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../domain/entities/admin_role.dart';

/// Responsive Quick Actions section for the Admin Dashboard.
/// Renders a 2x2 grid on mobile and a wrap row on desktop and tablet.
class DashboardQuickActions extends StatelessWidget {
  final bool isSuper;
  final AdminRole? currentAdmin;
  final bool isMobile;

  const DashboardQuickActions({
    super.key,
    required this.isSuper,
    required this.currentAdmin,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final pills = [
      if (isSuper || (currentAdmin?.permissions['can_manage_categories'] ?? false))
        _buildQuickActionPill(
          label: "Add Category",
          icon: Icons.create_new_folder_outlined,
          onTap: () => Get.toNamed(AppRoutes.manageCategories),
          isGrid: isMobile,
        ),
      if (isSuper || (currentAdmin?.permissions['can_manage_items'] ?? false))
        _buildQuickActionPill(
          label: "Add Inspiration",
          icon: Icons.image_outlined,
          onTap: () => Get.toNamed(AppRoutes.manageExperiences),
          isGrid: isMobile,
        ),
      if (isSuper || (currentAdmin?.permissions['can_manage_quotes'] ?? false))
        _buildQuickActionPill(
          label: "Create Quote",
          icon: Icons.receipt_long_outlined,
          onTap: () => Get.toNamed(AppRoutes.manageQuotes),
          isGrid: isMobile,
        ),
      if (isSuper || (currentAdmin?.permissions['can_manage_customers'] ?? false))
        _buildQuickActionPill(
          label: "Add Customer",
          icon: Icons.person_add_outlined,
          onTap: () => Get.toNamed(AppRoutes.manageCustomers),
          isGrid: isMobile,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "QUICK ACTIONS",
          style: GoogleFonts.dmSans(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            color: const Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 10),
        if (isMobile)
          Column(
            children: [
              if (pills.length >= 2) ...[
                Row(
                  children: [
                    Expanded(child: pills[0]),
                    const SizedBox(width: 10),
                    Expanded(child: pills[1]),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              if (pills.length >= 4)
                Row(
                  children: [
                    Expanded(child: pills[2]),
                    const SizedBox(width: 10),
                    Expanded(child: pills[3]),
                  ],
                ),
            ],
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: pills,
          ),
      ],
    );
  }

  Widget _buildQuickActionPill({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isGrid = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isGrid ? 8 : 14,
          vertical: 8,
        ),
        alignment: isGrid ? Alignment.center : null,
        decoration: BoxDecoration(
          color: const Color(0xFF101C16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: isGrid ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: isGrid ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFD4AF37)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
