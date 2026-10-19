import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Compact Top Header for the Client Lounge.
/// Exactly matches the target reference design with search input,
/// dynamic reward points pill, membership tier, notifications, and logout.
class DashboardTopBar extends StatelessWidget {
  final CustomerDashboardController controller;
  final VoidCallback onLogout;
  final ValueChanged<int> onNavToNotifications;
  final VoidCallback? onOpenDrawer;
  final bool isMobile;
  final bool isTablet;

  const DashboardTopBar({
    super.key,
    required this.controller,
    required this.onLogout,
    required this.onNavToNotifications,
    this.onOpenDrawer,
    this.isMobile = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const Color goldColor = Color(0xFFD4AF37);
    const Color borderGold = Color(0x1AD4AF37);

    final bool effectiveMobile = isMobile || screenWidth < 600;
    final bool effectiveTablet = isTablet || (screenWidth >= 600 && screenWidth < 1024);

    return Obx(() {
      final profile = controller.rxProfile.value;
      String customerName = profile?.fullName.trim() ?? '';
      if (customerName.isEmpty ||
          customerName.toLowerCase() == 'guest' ||
          customerName.toLowerCase() == 'null') {
        customerName = 'SHIWA';
      }
      final profileImageUrl = profile?.profileImageUrl ?? '';
      final unread = controller.rxNotifications.where((n) => !n.isRead).length;

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: effectiveMobile ? 12 : (effectiveTablet ? 16 : 24),
          vertical: effectiveMobile ? 8 : 0,
        ),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(color: borderGold, width: 1.0),
          ),
        ),
        child: effectiveMobile
            ? _buildMobileBar(customerName, profileImageUrl, unread, goldColor)
            : SizedBox(
                height: effectiveTablet ? 58 : 58,
                child: effectiveTablet
                    ? _buildTabletBar(customerName, profileImageUrl, unread, goldColor, screenWidth)
                    : _buildDesktopBar(unread, goldColor, screenWidth),
              ),
      );
    });
  }

  // ─── Mobile Top Bar: [☰] [Avatar + Name] [Spacer] [Bell] [Logout] + Search Row ───
  Widget _buildMobileBar(String name, String imageUrl, int unread, Color goldColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 48,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: Color(0xFFDCD6CE), size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: onOpenDrawer,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildUserBadge(name, imageUrl, goldColor),
              ),
              _buildNotificationButton(unread, goldColor),
              const SizedBox(width: 4),
              _buildLogoutButton(),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _buildSearchBox(goldColor, isCompact: true),
        const SizedBox(height: 4),
      ],
    );
  }

  // ─── Tablet Top Bar: [Avatar + Name] [Search] [Spacer] [PTS] [TIER] [Bell] [Logout] ───
  Widget _buildTabletBar(String name, String imageUrl, int unread, Color goldColor, double screenWidth) {
    final bool showSearch = screenWidth >= 700;

    return Row(
      children: [
        _buildUserBadge(name, imageUrl, goldColor),
        if (showSearch) ...[
          const SizedBox(width: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: _buildSearchBox(goldColor, isCompact: true),
          ),
        ],
        const Spacer(),
        _buildPointsBadge(goldColor),
        const SizedBox(width: 10),
        Text(
          'PLATINUM TIER',
          style: AppTheme.sansBody(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8CC8A),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 8),
        _buildNotificationButton(unread, goldColor),
        const SizedBox(width: 4),
        _buildLogoutButton(),
      ],
    );
  }

  // ─── Desktop / Laptop Top Bar: [Search] [Spacer] [PTS] [TIER] [Bell] [Logout] ───
  Widget _buildDesktopBar(int unread, Color goldColor, double screenWidth) {
    final double searchWidth = screenWidth < 1200 ? 280 : 360;

    return Row(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: searchWidth),
          child: _buildSearchBox(goldColor),
        ),
        const Spacer(),
        _buildPointsBadge(goldColor),
        const SizedBox(width: 12),
        Text(
          'PLATINUM TIER',
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE8CC8A),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 10),
        _buildNotificationButton(unread, goldColor),
        const SizedBox(width: 4),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildUserBadge(String name, String imageUrl, Color goldColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: goldColor.withValues(alpha: 0.6), width: 1.0),
            color: const Color(0xFF101914),
          ),
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "S",
                        style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "S",
                      style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.sansBody(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Client Lounge',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.sansBody(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: goldColor.withValues(alpha: 0.85),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox(Color goldColor, {bool isCompact = false}) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFF101914),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(
            Icons.search_rounded,
            size: 15,
            color: goldColor.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              cursorColor: goldColor,
              style: AppTheme.sansBody(
                fontSize: 11,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: isCompact ? "Search..." : "Search your events, themes, or services...",
                hintStyle: AppTheme.sansBody(
                  fontSize: 10.5,
                  color: const Color(0xFF6B7E76),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBadge(Color goldColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: goldColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goldColor.withValues(alpha: 0.25),
            ),
            child: Center(
              child: Icon(
                Icons.stars_rounded,
                color: goldColor,
                size: 10,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '1,500 PTS',
            style: AppTheme.sansBody(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: goldColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(int unread, Color goldColor) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(
          unread.toString(),
          style: const TextStyle(fontSize: 8.5, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: goldColor,
        child: const Icon(
          Icons.notifications_none_outlined,
          color: Color(0xFFDCD6CE),
          size: 19,
        ),
      ),
      onPressed: () => onNavToNotifications(7),
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      icon: const Icon(
        Icons.logout_rounded,
        color: Color(0xFFDCD6CE),
        size: 18,
      ),
      onPressed: onLogout,
    );
  }
}
