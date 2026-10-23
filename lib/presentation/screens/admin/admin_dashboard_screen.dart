import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/dashboard_booking_alerts.dart';
import 'widgets/dashboard_content_sections.dart';
import 'widgets/dashboard_greeting_section.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_summary_cards.dart';
import 'widgets/dashboard_top_bar.dart';

/// Core Dashboard landing page for administrators and managers.
/// Responsively composes the header, KPIs, quick actions, analytics, and booking feeds.
class AdminDashboardScreen extends GetView<AdminController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 700;
    final isTablet = screenWidth >= 700 && screenWidth < 1024;

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
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 12 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header / Search & Profile Bar ────────────────
                  DashboardTopBar(
                    authController: authController,
                    controller: controller,
                    subtitleColor: subtitleColor,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isMobile ? 14 : 18),

                  // ── Greeting Header ──────────────────────────────────
                  DashboardGreetingSection(
                    currentAdmin: currentAdmin,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    isMobile: isMobile,
                  ),

                  // ── Pending Proposal Reviews Alert Banner ───────────
                  const DashboardBookingAlerts(),

                  // ── 4 Compact KPI Cards ──────────────────────────────
                  DashboardSummaryCards(
                    controller: controller,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isMobile ? 16 : 20),

                  // ── Quick Actions ────────────────────────────────────
                  DashboardQuickActions(
                    isSuper: isSuper,
                    currentAdmin: currentAdmin,
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 20 : 24),

                  // ── Analytics & Inquiries ────────────────────────────
                  DashboardAnalyticsSection(controller: controller),
                  const SizedBox(height: 24),

                  // ── Upcoming Celebrations & Recent Bookings ───────────
                  const DashboardEventsAndBookingsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
