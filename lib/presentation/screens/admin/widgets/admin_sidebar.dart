import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/admin_role.dart';
import '../../../controllers/auth_controller.dart';
import 'admin_logout_dialog.dart';
import 'admin_sidebar_header.dart';
import 'admin_sidebar_nav_items.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Column(
      children: [
        AdminSidebarHeader(
          isCollapsed: isCollapsed,
          isDark: isDark,
        ),
        Expanded(
          child: AdminSidebarNavItems(
            currentAdmin: currentAdmin,
            isCollapsed: isCollapsed,
            isDark: isDark,
            onNavigate: _navigate,
            onLogout: () => showAdminLogoutDialog(context, authController),
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
}
