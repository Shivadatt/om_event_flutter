import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../domain/entities/admin_role.dart';
import 'admin_sidebar_item.dart';

/// Renders the secondary navigation sections (Business, Content, System) in the Admin Sidebar.
class AdminSidebarSecondaryNav extends StatelessWidget {
  final AdminRole? currentAdmin;
  final bool isCollapsed;
  final bool isDark;
  final void Function(String route) onNavigate;
  final VoidCallback onLogout;
  final Widget Function(String title) buildSectionHeader;
  final bool Function(String currentRoute, String targetRoute) isRouteActive;

  const AdminSidebarSecondaryNav({
    super.key,
    required this.currentAdmin,
    required this.isCollapsed,
    required this.isDark,
    required this.onNavigate,
    required this.onLogout,
    required this.buildSectionHeader,
    required this.isRouteActive,
  });

  @override
  Widget build(BuildContext context) {
    final isSuper = currentAdmin?.roleType == 'super_admin';
    final currentRoute = Get.currentRoute;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── BUSINESS ─────────────────────────────────────────────────
        if (isSuper || (currentAdmin?.permissions['can_manage_settings'] ?? false)) ...[
          buildSectionHeader('BUSINESS'),
          AdminSidebarItem(
            icon: Icons.business_outlined,
            label: "Business Details",
            isActive: isRouteActive(currentRoute, AppRoutes.businessDetails),
            isCollapsed: isCollapsed,
            onTap: () => onNavigate(AppRoutes.businessDetails),
          ),
          AdminSidebarItem(
            icon: Icons.settings_outlined,
            label: "Settings",
            isActive: isRouteActive(currentRoute, AppRoutes.systemSettings),
            isCollapsed: isCollapsed,
            onTap: () => onNavigate(AppRoutes.systemSettings),
          ),
        ],

        // ── CONTENT ──────────────────────────────────────────────────
        buildSectionHeader('CONTENT'),
        AdminSidebarItem(
          icon: Icons.photo_library_outlined,
          label: "Gallery",
          isActive: isRouteActive(currentRoute, AppRoutes.manageGallery),
          isCollapsed: isCollapsed,
          onTap: () => onNavigate(AppRoutes.manageGallery),
        ),
        AdminSidebarItem(
          icon: Icons.quiz_outlined,
          label: "FAQ",
          isActive: isRouteActive(currentRoute, AppRoutes.manageFaq),
          isCollapsed: isCollapsed,
          onTap: () => onNavigate(AppRoutes.manageFaq),
        ),
        AdminSidebarItem(
          icon: Icons.policy_outlined,
          label: "Policies",
          isActive: isRouteActive(currentRoute, AppRoutes.managePolicies),
          isCollapsed: isCollapsed,
          onTap: () => onNavigate(AppRoutes.managePolicies),
        ),
        AdminSidebarItem(
          icon: Icons.map_outlined,
          label: "Service Areas",
          isActive: isRouteActive(currentRoute, AppRoutes.manageServiceArea),
          isCollapsed: isCollapsed,
          onTap: () => onNavigate(AppRoutes.manageServiceArea),
        ),
        AdminSidebarItem(
          icon: Icons.notifications_active_outlined,
          label: "Notification Templates",
          isActive: isRouteActive(currentRoute, AppRoutes.manageNotificationTemplates),
          isCollapsed: isCollapsed,
          onTap: () => onNavigate(AppRoutes.manageNotificationTemplates),
        ),

        // ── SYSTEM ───────────────────────────────────────────────────
        buildSectionHeader('SYSTEM'),
        if (isSuper || (currentAdmin?.permissions['can_manage_users'] ?? false))
          AdminSidebarItem(
            icon: Icons.admin_panel_settings_outlined,
            label: "Admin Users",
            isActive: isRouteActive(currentRoute, AppRoutes.manageUsers),
            isCollapsed: isCollapsed,
            onTap: () => onNavigate(AppRoutes.manageUsers),
          ),
        AdminSidebarItem(
          icon: Icons.logout_outlined,
          label: "Logout",
          isCollapsed: isCollapsed,
          onTap: onLogout,
        ),
      ],
    );
  }
}
