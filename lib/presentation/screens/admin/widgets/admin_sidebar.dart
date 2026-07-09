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
              AdminSidebarItem(
                icon: Icons.dashboard_outlined,
                label: "Dashboard",
                isActive: currentRoute == AppRoutes.adminDashboard,
                isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.adminDashboard),
              ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_categories'] ?? false))
                AdminSidebarItem(
                  icon: Icons.category_outlined,
                  label: "Categories",
                  isActive: currentRoute == AppRoutes.manageCategories,
                  isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageCategories),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_items'] ?? false))
                AdminSidebarItem(
                  icon: Icons.stars_outlined,
                  label: "Experiences",
                  isActive: currentRoute == AppRoutes.manageExperiences,
                  isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageExperiences),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_customers'] ?? false))
                AdminSidebarItem(
                  icon: Icons.people_outline,
                  label: "Customers",
                  isActive: currentRoute == AppRoutes.manageCustomers,
                  isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageCustomers),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_leads'] ?? false))
                AdminSidebarItem(
                  icon: Icons.contact_phone_outlined,
                  label: "Leads",
                  isActive: currentRoute == AppRoutes.manageLeads,
                  isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageLeads),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_quotes'] ?? false))
                AdminSidebarItem(
                  icon: Icons.receipt_long_outlined,
                  label: "Quotations",
                  isActive: currentRoute == AppRoutes.manageQuotes,
                  isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageQuotes),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_users'] ?? false))
                AdminSidebarItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: "Users",
                  isActive: currentRoute == AppRoutes.manageUsers,
                  isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageUsers),
                ),
              AdminSidebarItem(
                icon: Icons.rate_review_outlined,
                label: "Reviews",
                isActive: currentRoute == AppRoutes.manageReviews || currentRoute == '/admin/reviews',
                isCollapsed: isCollapsed,
                onTap: () => _navigate(AppRoutes.manageReviews),
              ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_settings'] ?? false)) ...[
                AdminSidebarItem(
                  icon: Icons.business_outlined,
                  label: "Business Details",
                  isActive: currentRoute == AppRoutes.businessDetails,
                  isCollapsed: isCollapsed,
                  onTap: () => _navigate(AppRoutes.businessDetails),
                ),
                AdminSidebarItem(
                  icon: Icons.settings_outlined,
                  label: "Settings",
                  isActive: currentRoute == AppRoutes.systemSettings,
                  isCollapsed: isCollapsed,
                  onTap: () => _navigate(AppRoutes.systemSettings),
                ),
              ],
              Divider(
                color: isDark ? AppColors.darkLine : AppColors.lightLine,
                height: 32,
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
            onPressed: () {
              Get.back();
              authController.logout();
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
