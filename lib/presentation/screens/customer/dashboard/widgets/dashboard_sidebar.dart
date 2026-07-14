import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Desktop sidebar navigation panel for the Customer Portal.
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
    return Container(
      width: 270,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF171411),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x22D4AF37), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          _buildProfileCard(),
          const Divider(color: Color(0x1AD4AF37), height: 1),
          _buildNavList(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Obx(() {
        final profile = controller.rxProfile.value;
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              ),
              padding: const EdgeInsets.all(3),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF2A241F),
                backgroundImage: profile?.profileImageUrl.isNotEmpty == true
                    ? CachedNetworkImageProvider(
                        profile!.profileImageUrl,
                        maxWidth: 160,
                        maxHeight: 160,
                      )
                    : null,
                child: profile?.profileImageUrl.isEmpty == true
                    ? const Icon(Icons.person_outline, size: 40, color: Color(0xFFD4AF37))
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              profile?.fullName.toUpperCase() ?? 'CLIENT',
              style: GoogleFonts.italiana(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              profile?.email ?? '',
              style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNavList() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        children: [
          SidebarTile(title: 'Overview', icon: Icons.dashboard_outlined, isActive: selectedIndex == 0, onTap: () => onIndexChanged(0)),
          SidebarTile(title: 'Inquiries', icon: Icons.assignment_outlined, isActive: selectedIndex == 1, onTap: () => onIndexChanged(1)),
          SidebarTile(title: 'Quotations', icon: Icons.description_outlined, isActive: selectedIndex == 2, onTap: () => onIndexChanged(2)),
          SidebarTile(title: 'Event Gallery', icon: Icons.photo_library_outlined, isActive: selectedIndex == 5, onTap: () => onIndexChanged(5)),
          SidebarTile(title: 'Wishlist', icon: Icons.favorite_border, isActive: selectedIndex == 6, onTap: () => onIndexChanged(6)),
          Obx(() {
            final unread = controller.rxNotifications.where((n) => !n.isRead).length;
            return SidebarTile(
              title: 'Notifications',
              icon: Icons.notifications_none_outlined,
              isActive: selectedIndex == 7,
              badgeCount: unread > 0 ? unread : null,
              onTap: () => onIndexChanged(7),
            );
          }),
          SidebarTile(title: 'Profile Settings', icon: Icons.person_outline, isActive: selectedIndex == 8, onTap: () => onIndexChanged(8)),
          SidebarTile(title: 'Concierge Support', icon: Icons.contact_support_outlined, isActive: selectedIndex == 9, onTap: () => onIndexChanged(9)),
          SidebarTile(title: 'Office Maps & Legal', icon: Icons.gavel_outlined, isActive: selectedIndex == 10, onTap: () => onIndexChanged(10)),
          SidebarTile(title: 'Alert Preferences', icon: Icons.settings_outlined, isActive: selectedIndex == 11, onTap: () => onIndexChanged(11)),
        ],
      ),
    );
  }
}

/// Reusable sidebar navigation tile with optional badge.
class SidebarTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final int? badgeCount;

  const SidebarTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isActive
            ? const LinearGradient(colors: [Color(0x33D4AF37), Color(0x0AD4AF37)])
            : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? const Color(0xFFD4AF37) : Colors.white60, size: 20),
        title: Text(
          title,
          style: AppTheme.sansBody(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFFD4AF37) : Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
        trailing: badgeCount != null && badgeCount! > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '',
                  style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
