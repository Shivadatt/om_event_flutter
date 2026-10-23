import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../controllers/auth_controller.dart';

/// Admin profile pill/avatar shown on the top bar.
class DashboardProfilePill extends StatelessWidget {
  final AuthController authController;
  final bool isTablet;

  const DashboardProfilePill({
    super.key,
    required this.authController,
    required this.isTablet,
  });

  Color _getBadgeColor(String role) {
    switch (role) {
      case 'super_admin':
        return AppColors.primaryAccent;
      case 'demo_admin':
        return AppColors.secondaryAccent;
      case 'staff':
        return AppColors.highlight;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentAdmin = authController.rxAdminRole.value;
      if (currentAdmin == null) return const SizedBox();
      final name = currentAdmin.name.isEmpty
          ? currentAdmin.email.split('@').first
          : currentAdmin.name;
      final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

      if (isTablet) {
        return InkWell(
          onTap: () => Get.toNamed('/admin/profile'),
          borderRadius: BorderRadius.circular(16),
          child: CircleAvatar(
            radius: 14,
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
        );
      }

      return InkWell(
        onTap: () => Get.toNamed('/admin/profile'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF101915),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
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
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    currentAdmin.roleType.replaceAll('_', ' ').toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 7.5,
                      fontWeight: FontWeight.bold,
                      color: _getBadgeColor(currentAdmin.roleType),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: Colors.white38,
              ),
            ],
          ),
        ),
      );
    });
  }
}
