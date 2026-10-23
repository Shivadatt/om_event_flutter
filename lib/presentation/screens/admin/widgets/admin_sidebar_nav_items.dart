import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/admin_role.dart';
import 'admin_sidebar_item.dart';
import 'admin_sidebar_secondary_nav.dart';

/// Renders the scrollable categorized navigation list for the Admin Sidebar.
class AdminSidebarNavItems extends StatelessWidget {
  final AdminRole? currentAdmin;
  final bool isCollapsed;
  final bool isDark;
  final void Function(String route) onNavigate;
  final VoidCallback onLogout;

  const AdminSidebarNavItems({
    super.key,
    required this.currentAdmin,
    required this.isCollapsed,
    required this.isDark,
    required this.onNavigate,
    required this.onLogout,
  });

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

  Widget _buildSectionHeader(String title) {
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
    final isSuper = currentAdmin?.roleType == 'super_admin';
    final currentRoute = Get.currentRoute;

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: isCollapsed ? 6 : 14,
      ),
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
          onTap: () => onNavigate(AppRoutes.adminDashboard),
        ),

        // ── OPERATIONS ───────────────────────────────────────────────
        _buildSectionHeader('OPERATIONS'),
        if (isSuper || (currentAdmin?.permissions['can_manage_customers'] ?? false))
          AdminSidebarItem(
            icon: Icons.people_outline,
            label: "Customers",
            isActive: _isRouteActive(currentRoute, AppRoutes.manageCustomers),
            isCollapsed: isCollapsed,
            onTap: () => onNavigate(AppRoutes.manageCustomers),
          ),
        if (isSuper || (currentAdmin?.permissions['can_manage_leads'] ?? false))
          AdminSidebarItem(
            icon: Icons.contact_phone_outlined,
            label: "Leads",
            isActive: _isRouteActive(currentRoute, AppRoutes.manageLeads),
            isCollapsed: isCollapsed,
            onTap: () => onNavigate(AppRoutes.manageLeads),
          ),
        if (isSuper || (currentAdmin?.permissions['can_manage_quotes'] ?? false))
          AdminSidebarItem(
            icon: Icons.receipt_long_outlined,
            label: "Quotations",
            isActive: _isRouteActive(currentRoute, AppRoutes.manageQuotes),
            isCollapsed: isCollapsed,
            onTap: () => onNavigate(AppRoutes.manageQuotes),
          ),
        AdminSidebarItem(
          icon: Icons.book_online_outlined,
          label: "Bookings",
          isActive: _isRouteActive(currentRoute, AppRoutes.adminBookings),
          isCollapsed: isCollapsed,
          onTap: () => onNavigate(AppRoutes.adminBookings),
        ),
        AdminSidebarItem(
          icon: Icons.calendar_month_outlined,
          label: "Availability",
          isActive: _isRouteActive(currentRoute, AppRoutes.adminAvailability),
          isCollapsed: isCollapsed,
          onTap: () => onNavigate(AppRoutes.adminAvailability),
        ),
        AdminSidebarItem(
          icon: Icons.rate_review_outlined,
          label: "Reviews",
          isActive: _isRouteActive(currentRoute, AppRoutes.manageReviews),
          isCollapsed: isCollapsed,
          onTap: () => onNavigate(AppRoutes.manageReviews),
        ),

        // ── CATALOG ──────────────────────────────────────────────────
        _buildSectionHeader('CATALOG'),
        if (isSuper || (currentAdmin?.permissions['can_manage_categories'] ?? false))
          AdminSidebarItem(
            icon: Icons.category_outlined,
            label: "Categories",
            isActive: _isRouteActive(currentRoute, AppRoutes.manageCategories),
            isCollapsed: isCollapsed,
            onTap: () => onNavigate(AppRoutes.manageCategories),
          ),
        if (isSuper || (currentAdmin?.permissions['can_manage_items'] ?? false))
          AdminSidebarItem(
            icon: Icons.stars_outlined,
            label: "Experiences",
            isActive: _isRouteActive(currentRoute, AppRoutes.manageExperiences),
            isCollapsed: isCollapsed,
            onTap: () => onNavigate(AppRoutes.manageExperiences),
          ),

        // ── SECONDARY SECTIONS (Business, Content, System) ────────────
        AdminSidebarSecondaryNav(
          currentAdmin: currentAdmin,
          isCollapsed: isCollapsed,
          isDark: isDark,
          onNavigate: onNavigate,
          onLogout: onLogout,
          buildSectionHeader: _buildSectionHeader,
          isRouteActive: _isRouteActive,
        ),
      ],
    );
  }
}
