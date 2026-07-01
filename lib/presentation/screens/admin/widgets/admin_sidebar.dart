import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../domain/entities/admin_role.dart';
import '../../../controllers/auth_controller.dart';
import 'admin_sidebar_item.dart';

/// Decoupled sidebar/drawer component rendering the administrative navigation items.
class AdminSidebar extends StatelessWidget {
  /// The active logged-in admin role configuration.
  final AdminRole? currentAdmin;

  /// Whether the navigation items are being rendered inside a mobile Drawer.
  final bool isMobileDrawer;

  /// Creates an [AdminSidebar] widget instance.
  const AdminSidebar({
    super.key,
    required this.currentAdmin,
    this.isMobileDrawer = false,
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

    Widget content = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF254235), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF162822),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFC8A26A), width: 1),
                ),
                child: Text(
                  "OE",
                  style: AppTheme.serifHeader(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC8A26A),
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
                      color: const Color(0xFFF4F4F4),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "STUDIO ADMIN",
                    style: AppTheme.sansBody(
                      fontSize: 9,
                      color: const Color(0xFFA4A9A7),
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            children: [
              AdminSidebarItem(
                icon: Icons.dashboard_outlined,
                label: "Dashboard",
                isActive: true,
                onTap: () {
                  if (isMobileDrawer) {
                    Get.back();
                  }
                },
              ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_categories'] ?? false))
                AdminSidebarItem(
                  icon: Icons.category_outlined,
                  label: "Categories",
                  onTap: () => _navigate(AppRoutes.manageCategories),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_items'] ?? false))
                AdminSidebarItem(
                  icon: Icons.stars_outlined,
                  label: "Experiences",
                  onTap: () => _navigate(AppRoutes.manageExperiences),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_customers'] ?? false))
                AdminSidebarItem(
                  icon: Icons.people_outline,
                  label: "Customers",
                  onTap: () => _navigate(AppRoutes.manageCustomers),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_leads'] ?? false))
                AdminSidebarItem(
                  icon: Icons.contact_phone_outlined,
                  label: "Leads",
                  onTap: () => _navigate(AppRoutes.manageLeads),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_quotes'] ?? false))
                AdminSidebarItem(
                  icon: Icons.receipt_long_outlined,
                  label: "Quotations",
                  onTap: () => _navigate(AppRoutes.manageQuotes),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_quotes'] ?? false))
                AdminSidebarItem(
                  icon: Icons.bookmark_outline,
                  label: "Bookings",
                  onTap: () => _navigate(AppRoutes.manageBookings),
                ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_users'] ?? false))
                AdminSidebarItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: "Users",
                  onTap: () => _navigate(AppRoutes.manageUsers),
                ),
              AdminSidebarItem(
                icon: Icons.rate_review_outlined,
                label: "Reviews",
                onTap: () => _navigate('/admin/reviews'),
              ),
              if (isSuper ||
                  (currentAdmin?.permissions['can_manage_settings'] ?? false))
                AdminSidebarItem(
                  icon: Icons.settings_outlined,
                  label: "Settings",
                  onTap: () => _navigate(AppRoutes.systemSettings),
                ),
              const Divider(color: Color(0xFF254235), height: 32),
              AdminSidebarItem(
                icon: Icons.logout_outlined,
                label: "Logout",
                onTap: () => authController.logout(),
              ),
            ],
          ),
        ),
      ],
    );

    if (isMobileDrawer) {
      return Drawer(
        child: Container(color: const Color(0xFF0D1915), child: content),
      );
    }

    return content;
  }
}
