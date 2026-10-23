import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/admin_controller.dart';
import '../../../controllers/auth_controller.dart';
import 'dashboard_profile_pill.dart';

/// Responsive top bar for the Admin Dashboard.
/// Adapts search, points, tier, notifications, refresh, and profile controls.
class DashboardTopBar extends StatelessWidget {
  final AuthController authController;
  final AdminController controller;
  final Color subtitleColor;
  final bool isMobile;
  final bool isTablet;

  const DashboardTopBar({
    super.key,
    required this.authController,
    required this.controller,
    required this.subtitleColor,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Container(
        width: double.infinity,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF101915),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 16, color: Colors.white38),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Search events, clients, or anything...",
                style: GoogleFonts.dmSans(fontSize: 11.5, color: Colors.white38),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(maxWidth: isTablet ? 260 : 320),
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF101915),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, size: 16, color: Colors.white38),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Search events, clients, or anything...",
                        style: GoogleFonts.dmSans(fontSize: 11.5, color: Colors.white38),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF231C0C),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Text(
                  "1,500 PTS",
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 8 : 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.diamond_outlined, size: 13, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 4),
                  Text(
                    "PLATINUM TIER",
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              SizedBox(width: isTablet ? 8 : 12),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 19,
                    color: Color(0xFFD4AF37),
                  ),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 6.5,
                      height: 6.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              IconButton(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white54),
                onPressed: () => controller.loadDashboardStats(),
              ),
              SizedBox(width: isTablet ? 8 : 12),
              DashboardProfilePill(
                authController: authController,
                isTablet: isTablet,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
