import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/admin_role.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_booking_controller.dart';
import 'widgets/inquiries_trend_chart.dart';
import 'widgets/recent_inquiries_widget.dart';
import 'widgets/dashboard_booking_alerts.dart';
import 'widgets/dashboard_recent_bookings.dart';
import 'widgets/dashboard_upcoming_events.dart';

/// Core Dashboard landing page for administrators and managers.
/// Refined to closely match the Option 1 Elegant Classic Style reference design:
/// - Constrained max content width (1360px) preventing stretched cards
/// - Top bar with search input, points badge, tier indicator, notification bell, and admin profile pill
/// - Elegant greeting and formatted date
/// - Compact pending proposal reviews alert banner
/// - 4 compact KPI cards with fixed heights, trend badges, and gold icons
/// - Compact quick action buttons
/// - Balanced 2-column middle section (Booking Trend 65% + Latest Inquiries 35%)
/// - Balanced 2-column bottom section (Upcoming Celebrations 50% + Recent Bookings 50%)
class AdminDashboardScreen extends GetView<AdminController> {
  const AdminDashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }

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
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoadingStats.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
            ),
          );
        }

        final currentAdmin = authController.rxAdminRole.value;
        final isSuper = currentAdmin?.roleType == 'super_admin';

        return RefreshIndicator(
          onRefresh: () => controller.loadDashboardStats(),
          color: AppColors.primaryAccent,
          backgroundColor: isDark ? AppColors.darkForest : AppColors.lightForest,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header / Search & Profile Bar ────────────────
                  _buildTopBar(context, authController, subtitleColor),
                  const SizedBox(height: 18),

                  // ── Greeting Header ──────────────────────────────────
                  _buildGreeting(currentAdmin, textColor, subtitleColor),

                  // ── Pending Proposal Reviews Alert Banner ───────────
                  const DashboardBookingAlerts(),

                  // ── 4 Compact KPI Cards ──────────────────────────────
                  _buildKpiCardsSection(),
                  const SizedBox(height: 20),

                  // ── Quick Actions ────────────────────────────────────
                  _buildQuickActions(isSuper, currentAdmin),
                  const SizedBox(height: 24),

                  // ── Analytics & Inquiries 2-Column Split ─────────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 950) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 7,
                              child: InquiriesTrendChart(),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              flex: 3,
                              child: RecentInquiriesWidget(
                                controller: controller,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            const InquiriesTrendChart(),
                            const SizedBox(height: 18),
                            RecentInquiriesWidget(controller: controller),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Upcoming Celebrations & Recent Bookings ───────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 950) {
                        return const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: DashboardUpcomingEvents()),
                            SizedBox(width: 18),
                            Expanded(child: DashboardRecentBookings()),
                          ],
                        );
                      } else {
                        return const Column(
                          children: [
                            DashboardUpcomingEvents(),
                            SizedBox(height: 18),
                            DashboardRecentBookings(),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Top Bar with Search, PTS, Tier, Notification, and Profile ────────
  Widget _buildTopBar(
    BuildContext context,
    AuthController authController,
    Color subtitleColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Search box
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
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

          // Right Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1,500 PTS Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
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
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Platinum Tier
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.diamond_outlined, size: 14, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 5),
                  Text(
                    "PLATINUM TIER",
                    style: GoogleFonts.dmSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Notification Bell with Badge
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
              const SizedBox(width: 8),

              // Refresh Button
              IconButton(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white54),
                onPressed: () => controller.loadDashboardStats(),
              ),
              const SizedBox(width: 12),

              // Admin Profile Pill
              Obx(() {
                final currentAdmin = authController.rxAdminRole.value;
                if (currentAdmin == null) return const SizedBox();
                final name = currentAdmin.name.isEmpty
                    ? currentAdmin.email.split('@').first
                    : currentAdmin.name;
                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

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
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ── Greeting Section ───────────────────────────────────────────────
  Widget _buildGreeting(AdminRole? currentAdmin, Color textColor, Color subtitleColor) {
    final name = currentAdmin != null
        ? (currentAdmin.name.isEmpty ? currentAdmin.email.split('@').first : currentAdmin.name)
        : 'Super Admin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_getGreeting()}, $name,",
          style: GoogleFonts.italiana(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          "Here's what happening with your studio today · ${_getFormattedDate()}",
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  // ── 4 KPI Cards Section with Fixed Compact Height ──────────────────
  Widget _buildKpiCardsSection() {
    return Obx(() {
      final bookingCtrl = Get.isRegistered<AdminBookingController>()
          ? Get.find<AdminBookingController>()
          : null;

      final card1 = _buildKpiCard(
        label: "TOTAL BOOKINGS",
        value: (bookingCtrl?.totalCount.value ?? controller.quoteCount.value).toString(),
        trend: "▲ +12%",
        desc: "vs last month",
        icon: Icons.calendar_today_outlined,
      );

      final card2 = _buildKpiCard(
        label: "PENDING ACTION",
        value: (bookingCtrl?.pendingCount.value ?? 0).toString(),
        trend: "▲ +5%",
        desc: "Requires your attention",
        icon: Icons.access_time_rounded,
      );

      final card3 = _buildKpiCard(
        label: "CONFIRMED EVENTS",
        value: (bookingCtrl?.confirmedCount.value ?? 0).toString(),
        trend: null,
        desc: "This month",
        icon: Icons.check_circle_outline_rounded,
      );

      final card4 = _buildKpiCard(
        label: "UPCOMING EVENTS",
        value: (bookingCtrl?.upcomingEventsCount.value ?? 0).toString(),
        trend: null,
        desc: "Next 30 days",
        icon: Icons.event_note_outlined,
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (width > 950) {
            return Row(
              children: [
                Expanded(child: card1),
                const SizedBox(width: 14),
                Expanded(child: card2),
                const SizedBox(width: 14),
                Expanded(child: card3),
                const SizedBox(width: 14),
                Expanded(child: card4),
              ],
            );
          } else if (width > 550) {
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 106,
              children: [card1, card2, card3, card4],
            );
          } else {
            return Column(
              children: [
                card1,
                const SizedBox(height: 12),
                card2,
                const SizedBox(height: 12),
                card3,
                const SizedBox(height: 12),
                card4,
              ],
            );
          }
        },
      );
    });
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    String? trend,
    required String desc,
    required IconData icon,
  }) {
    return Container(
      height: 106,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF101C16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3328), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white60,
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF182820),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icon, size: 15, color: const Color(0xFFD4AF37)),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (trend != null) ...[
                const SizedBox(width: 6),
                Text(
                  trend,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: trend.contains('+') || trend.contains('▲')
                        ? const Color(0xFF22C55E)
                        : Colors.white60,
                  ),
                ),
              ],
            ],
          ),
          Text(
            desc,
            style: GoogleFonts.dmSans(
              fontSize: 9.5,
              color: Colors.white38,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Quick Actions Row with Compact Pill Buttons ────────────────────
  Widget _buildQuickActions(bool isSuper, AdminRole? currentAdmin) {
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (isSuper || (currentAdmin?.permissions['can_manage_categories'] ?? false))
              _buildQuickActionPill(
                label: "Add Category",
                icon: Icons.create_new_folder_outlined,
                onTap: () => Get.toNamed(AppRoutes.manageCategories),
              ),
            if (isSuper || (currentAdmin?.permissions['can_manage_items'] ?? false))
              _buildQuickActionPill(
                label: "Add Inspiration",
                icon: Icons.image_outlined,
                onTap: () => Get.toNamed(AppRoutes.manageExperiences),
              ),
            if (isSuper || (currentAdmin?.permissions['can_manage_quotes'] ?? false))
              _buildQuickActionPill(
                label: "Create Quote",
                icon: Icons.receipt_long_outlined,
                onTap: () => Get.toNamed(AppRoutes.manageQuotes),
              ),
            if (isSuper || (currentAdmin?.permissions['can_manage_customers'] ?? false))
              _buildQuickActionPill(
                label: "Add Customer",
                icon: Icons.person_add_outlined,
                onTap: () => Get.toNamed(AppRoutes.manageCustomers),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionPill({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF101C16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFD4AF37)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
