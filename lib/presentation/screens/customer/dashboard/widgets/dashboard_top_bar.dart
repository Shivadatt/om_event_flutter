import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Premium top bar for the Customer Portal.
class DashboardTopBar extends StatelessWidget {
  final CustomerDashboardController controller;
  final VoidCallback onLogout;
  final ValueChanged<int> onNavToNotifications;

  const DashboardTopBar({
    super.key,
    required this.controller,
    required this.onLogout,
    required this.onNavToNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Color(0x1AD4AF37), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBrand(context),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildBrand(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAllNamed(AppRoutes.home);
            }
          },
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OM EVENTS',
              style: GoogleFonts.italiana(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD4AF37),
                letterSpacing: 2.0,
              ),
            ),
            Text(
              'CLIENT LOUNGE',
              style: AppTheme.sansBody(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white54,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Obx(() {
      final profile = controller.rxProfile.value;
      final unread = controller.rxNotifications.where((n) => !n.isRead).length;
      return Row(
        children: [
          if (profile != null) ...[
            const _RewardPointsPill(),
            const SizedBox(width: 12),
            Text(
              'PLATINUM TIER',
              style: AppTheme.sansBody(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE6C98D),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 16),
          ],
          IconButton(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread.toString(), style: const TextStyle(fontSize: 9, color: Colors.black)),
              backgroundColor: const Color(0xFFD4AF37),
              child: const Icon(Icons.notifications_none_outlined, color: Colors.white70, size: 22),
            ),
            onPressed: () => onNavToNotifications(7),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white70, size: 20),
            onPressed: onLogout,
          ),
        ],
      );
    });
  }
}

class _RewardPointsPill extends StatelessWidget {
  const _RewardPointsPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1AD4AF37),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33D4AF37)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_outlined, color: Color(0xFFD4AF37), size: 14),
          const SizedBox(width: 6),
          Text(
            '1,500 PTS',
            style: AppTheme.sansBody(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }
}
