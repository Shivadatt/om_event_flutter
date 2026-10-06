import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/admin_role.dart';
import '../../../controllers/auth_controller.dart';
import 'admin_sidebar_item.dart';

/// Decoupled sidebar/drawer component rendering the administrative navigation items.
class AdminSidebar extends StatelessWidget {
  /// The active logged-in admin role configuration.
  final AdminRole? currentAdmin;

  /// Whether the navigation items are being rendered inside a mobile Drawer.
  final bool isMobileDrawer;

  /// Whether the sidebar should be rendered in a collapsed, icon-only state.
  final bool isCollapsed;

  /// Creates an [AdminSidebar] widget instance.
  const AdminSidebar({
    super.key,
    required this.currentAdmin,
    this.isMobileDrawer = false,
    this.isCollapsed = false,
  });

  void _navigate(String routeName) {
    if (isMobileDrawer) {
      Get.back();
    }
    Get.toNamed(routeName);
  }

  String _normalizeRoute(String route) {
    final clean = route.split('?').first.split('#').first.trim();
    if (clean.length > 1 && clean.endsWith('/')) {
      return clean.substring(0, clean.length - 1);
    }
    return clean;
  }

  bool _isRouteActive(String currentRoute, String targetRoute) {
    final cleanCurrent = _normalizeRoute(currentRoute);
    final cleanTarget = _normalizeRoute(targetRoute);
    if (cleanCurrent.isEmpty || cleanTarget.isEmpty) return false;
    if (cleanCurrent == cleanTarget) return true;
    if (cleanCurrent.startsWith('$cleanTarget/')) return true;
    return false;
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    if (isCollapsed) {
      return Divider(
        color: isDark ? AppColors.darkLine : AppColors.lightLine,
        height: 16,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: isDark ? AppColors.darkLine : AppColors.lightLine,
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isSuper = currentAdmin?.roleType == 'super_admin';
    final currentRoute = Get.currentRoute;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Column(
      children: [
        if (!isCollapsed) Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkLine : AppColors.lightLine,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkForestSecondary : AppColors.lightForestSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryAccent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Text(
                  "OE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                    fontFamily: 'serif',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "OM EVENTS",
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: isDark ? AppColors.darkInk : AppColors.lightInk,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "STUDIO ADMIN",
                    style: AppTheme.sansBody(
                      fontSize: 9,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            children: [
              // ── OVERVIEW ─────────────────────────────────────────────────
              if (!isCollapsed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'OVERVIEW',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.8,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ),
              AdminSidebarItem(
                icon: Icons.dashboard_outlined,
                label: "Dashboard",
                isActive: _isRouteActive(currentRoute, AppRoutes.adminDashboard),
                isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.adminDashboard),
              ),

              // ── OPERATIONS ───────────────────────────────────────────────
              _buildSectionHeader('OPERATIONS', isDark),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_customers'] ?? false))
                AdminSidebarItem(
                  icon: Icons.people_outline,
                  label: "Customers",
                  isActive: _isRouteActive(currentRoute, AppRoutes.manageCustomers),
                  isCollapsed: isCollapsed,
                  onTap: () => _navigate(AppRoutes.manageCustomers),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_leads'] ?? false))
                AdminSidebarItem(
                  icon: Icons.contact_phone_outlined,
                  label: "Leads",
                  isActive: _isRouteActive(currentRoute, AppRoutes.manageLeads),
                  isCollapsed: isCollapsed,
                  onTap: () => _navigate(AppRoutes.manageLeads),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_quotes'] ?? false))
                AdminSidebarItem(
                  icon: Icons.receipt_long_outlined,
                  label: "Quotations",
                  isActive: _isRouteActive(currentRoute, AppRoutes.manageQuotes),
                  isCollapsed: isCollapsed,
                  onTap: () => _navigate(AppRoutes.manageQuotes),
                ),
              AdminSidebarItem(
                icon: Icons.book_online_outlined,
                label: "Bookings",
                isActive: _isRouteActive(currentRoute, AppRoutes.adminBookings),
                isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.adminBookings),
              ),
              AdminSidebarItem(
                icon: Icons.calendar_month_outlined,
                label: "Availability",
                isActive: _isRouteActive(currentRoute, AppRoutes.adminAvailability),
                isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.adminAvailability),
              ),
              AdminSidebarItem(
                icon: Icons.rate_review_outlined,
                label: "Reviews",
                isActive: _isRouteActive(currentRoute, AppRoutes.manageReviews),
                isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageReviews),
              ),

              // ── CATALOG ──────────────────────────────────────────────────
              _buildSectionHeader('CATALOG', isDark),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_categories'] ?? false))
                AdminSidebarItem(
                  icon: Icons.category_outlined,
                  label: "Categories",
                  isActive: _isRouteActive(currentRoute, AppRoutes.manageCategories),
                  isCollapsed: isCollapsed,
                  onTap: () => _navigate(AppRoutes.manageCategories),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_items'] ?? false))
                AdminSidebarItem(
                  icon: Icons.stars_outlined,
                  label: "Experiences",
                  isActive: _isRouteActive(currentRoute, AppRoutes.manageExperiences),
                  isCollapsed: isCollapsed,
                  onTap: () => _navigate(AppRoutes.manageExperiences),
                ),

              // ── BUSINESS ─────────────────────────────────────────────────
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_settings'] ?? false)) ...[
                _buildSectionHeader('BUSINESS', isDark),
                AdminSidebarItem(
                  icon: Icons.business_outlined,
                  label: "Business Details",
                  isActive: _isRouteActive(currentRoute, AppRoutes.businessDetails),
                  isCollapsed: isCollapsed,
                  onTap: () => _navigate(AppRoutes.businessDetails),
                ),
                AdminSidebarItem(
                  icon: Icons.settings_outlined,
                  label: "Settings",
                  isActive: _isRouteActive(currentRoute, AppRoutes.systemSettings),
                  isCollapsed: isCollapsed,
                  onTap: () => _navigate(AppRoutes.systemSettings),
                ),
              ],

              // ── CONTENT ──────────────────────────────────────────────────
              _buildSectionHeader('CONTENT', isDark),
              AdminSidebarItem(
                icon: Icons.photo_library_outlined,
                label: "Gallery",
                isActive: _isRouteActive(currentRoute, AppRoutes.manageGallery),
                isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageGallery),
              ),
              AdminSidebarItem(
                icon: Icons.quiz_outlined,
                label: "FAQ",
                isActive: _isRouteActive(currentRoute, AppRoutes.manageFaq),
                isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageFaq),
              ),
              AdminSidebarItem(
                icon: Icons.policy_outlined,
                label: "Policies",
                isActive: _isRouteActive(currentRoute, AppRoutes.managePolicies),
                isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.managePolicies),
              ),
              AdminSidebarItem(
                icon: Icons.map_outlined,
                label: "Service Areas",
                isActive: _isRouteActive(currentRoute, AppRoutes.manageServiceArea),
                isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageServiceArea),
              ),
              AdminSidebarItem(
                icon: Icons.notifications_active_outlined,
                label: "Notification Templates",
                isActive: _isRouteActive(currentRoute, AppRoutes.manageNotificationTemplates),
                isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageNotificationTemplates),
              ),

              // ── SYSTEM ───────────────────────────────────────────────────
              _buildSectionHeader('SYSTEM', isDark),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_users'] ?? false))
                AdminSidebarItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: "Admin Users",
                  isActive: _isRouteActive(currentRoute, AppRoutes.manageUsers),
                  isCollapsed: isCollapsed,
                  onTap: () => _navigate(AppRoutes.manageUsers),
                ),
              AdminSidebarItem(
                icon: Icons.logout_outlined,
                label: "Logout",
                isCollapsed: isCollapsed,
                onTap: () => _showLogoutDialog(context, authController),
              ),
            ],
          ),
        ),
      ],
    );

    if (isMobileDrawer) {
      return Drawer(
        child: Container(
          color: isDark ? AppColors.darkCream : AppColors.lightCream,
          child: content,
        ),
      );
    }

    return content;
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141A18) : const Color(0xFFFBF9F4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFFC9A77E).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        title: Text(
          "LOG OUT",
          style: AppTheme.serifHeader(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
            letterSpacing: 1.5,
          ),
        ),
        content: Text(
          "Are you sure you want to log out of OM Events CMS?",
          style: AppTheme.sansBody(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "CANCEL",
              style: AppTheme.sansBody(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9A77E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              Get.back();
              await authController.logout();
            },
            child: Text(
              "CONFIRM",
              style: AppTheme.sansBody(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF091210),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
