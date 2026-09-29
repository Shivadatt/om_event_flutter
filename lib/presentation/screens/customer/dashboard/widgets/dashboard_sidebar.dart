import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Compact Desktop sidebar navigation panel for the Client Lounge.
/// Exactly matches the target reference design with docked layout,
/// OM Events monogram header, and sleek vertical navigation tiles.
class DashboardSidebar extends StatelessWidget {
  final CustomerDashboardController controller;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const DashboardSidebar({
    super.key,
    required this.controller,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color sidebarBg = Color(0xFF09120E);
    const Color goldColor = Color(0xFFD4AF37);
    const Color borderGold = Color(0x1AD4AF37);

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: sidebarBg,
        border: Border(
          right: BorderSide(color: borderGold, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Brand Header (Monogram + OM Events + CLIENT LOUNGE) ───
          _buildBrandHeader(goldColor),

          const SizedBox(height: 10),

          // ─── Vertical Navigation Menu ───
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildNavItem(
                  title: 'Overview',
                  icon: Icons.dashboard_outlined,
                  index: 0,
                ),
                _buildNavItem(
                  title: 'Inquiries',
                  icon: Icons.assignment_outlined,
                  index: 1,
                ),
                _buildNavItem(
                  title: 'Quotations',
                  icon: Icons.description_outlined,
                  index: 2,
                ),
                _buildNavItem(
                  title: 'Event Gallery',
                  icon: Icons.photo_library_outlined,
                  index: 5,
                ),
                _buildNavItem(
                  title: 'Wishlist',
                  icon: Icons.favorite_border_rounded,
                  index: 6,
                ),
                Obx(() {
                  final unread = controller.rxNotifications.where((n) => !n.isRead).length;
                  return _buildNavItem(
                    title: 'Notifications',
                    icon: Icons.notifications_none_outlined,
                    index: 7,
                    badgeCount: unread > 0 ? unread : null,
                  );
                }),
                _buildNavItem(
                  title: 'Profile Settings',
                  icon: Icons.person_outline_rounded,
                  index: 8,
                ),
                _buildNavItem(
                  title: 'Concierge Support',
                  icon: Icons.help_outline_rounded,
                  index: 9,
                ),
                _buildNavItem(
                  title: 'Office Maps & Legal',
                  icon: Icons.gavel_outlined,
                  index: 10,
                ),
                _buildNavItem(
                  title: 'Alert Preferences',
                  icon: Icons.settings_outlined,
                  index: 11,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(Color goldColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Monogram circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: goldColor.withValues(alpha: 0.8), width: 1.2),
                  color: const Color(0xFF131F18),
                ),
                child: Center(
                  child: Text(
                    "OE",
                    style: GoogleFonts.italiana(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: goldColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OM EVENTS',
                    style: GoogleFonts.italiana(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: goldColor,
                      letterSpacing: 1.4,
                    ),
                  ),
                  Text(
                    'AND DECORATORS',
                    style: AppTheme.sansBody(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white54,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              'CLIENT LOUNGE',
              style: AppTheme.sansBody(
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                color: goldColor.withValues(alpha: 0.85),
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String title,
    required IconData icon,
    required int index,
    int? badgeCount,
  }) {
    final bool isActive = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        onTap: () => onIndexChanged(index),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive
                ? const Color(0x35D4AF37)
                : Colors.transparent,
            border: isActive
                ? Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.65), width: 1.1)
                : null,
          ),
          child: Row(
            children: [
              if (isActive)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0xFF1B231D),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4), width: 0.8),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 13,
                      color: const Color(0xFFE8CC8A),
                    ),
                  ),
                )
              else
                Icon(
                  icon,
                  size: 16,
                  color: const Color(0xFF8B9D95),
                ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.sansBody(
                    fontSize: 11.5,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? const Color(0xFFE8CC8A) : const Color(0xFFC5BDB2),
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
