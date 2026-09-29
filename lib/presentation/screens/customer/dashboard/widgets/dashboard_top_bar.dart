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

  const DashboardTopBar({
    super.key,
    required this.controller,
    required this.onLogout,
    required this.onNavToNotifications,
  });

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);
    const Color borderGold = Color(0x1AD4AF37);

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: borderGold, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // ─── 1. Search Field ───
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
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
                  const SizedBox(width: 12),
                  Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: goldColor.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      cursorColor: goldColor,
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search your events, themes, or services...",
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
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // ─── 2. User Stats & Action Icons (Points + Tier + Notification + Logout) ───
          Obx(() {
            final unread = controller.rxNotifications.where((n) => !n.isRead).length;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Points Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: goldColor.withValues(alpha: 0.25),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.stars_rounded,
                            color: goldColor,
                            size: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '1,500 PTS',
                        style: AppTheme.sansBody(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Membership Tier
                Text(
                  'PLATINUM TIER',
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8CC8A),
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(width: 12),

                // Notifications Icon Button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
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
                ),

                const SizedBox(width: 4),

                // Logout Icon Button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDCD6CE),
                    size: 18,
                  ),
                  onPressed: onLogout,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
