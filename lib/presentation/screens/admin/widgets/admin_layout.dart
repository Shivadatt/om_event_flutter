import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../controllers/auth_controller.dart';
import 'admin_sidebar.dart';

class AdminLayoutScope extends InheritedWidget {
  const AdminLayoutScope({
    super.key,
    required super.child,
  });

  @override
  bool updateShouldNotify(AdminLayoutScope oldWidget) => false;

  static bool of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdminLayoutScope>() != null;
  }
}

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDesktop = context.isDesktop;
    final isCollapsed = !isDesktop;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildBlurBlob({
      required double size,
      required Color color,
      required double top,
      double? left,
      double? right,
    }) {
      return Positioned(
        top: top,
        left: left,
        right: right,
        width: size,
        height: size,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      );
    }

    return AdminLayoutScope(
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkCream : AppColors.lightCream,
        body: Stack(
          children: [
            // Ambient Luxury Lighting Background (Vignette)
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 130.0, sigmaY: 130.0),
                child: Stack(
                  children: [
                    if (isDark) ...[
                      buildBlurBlob(size: 600, color: AppColors.primaryAccent, top: -200, left: -100), // Primary Gold
                      buildBlurBlob(size: 500, color: AppColors.secondaryAccent, top: 250, right: -150), // Champagne Gold
                      buildBlurBlob(size: 400, color: AppColors.highlight, top: 600, left: 200),   // Soft Bronze
                    ] else ...[
                      buildBlurBlob(size: 600, color: AppColors.primaryAccent.withValues(alpha: 0.2), top: -200, left: -100),
                      buildBlurBlob(size: 500, color: AppColors.secondaryAccent.withValues(alpha: 0.15), top: 250, right: -150),
                    ],
                  ],
                ),
              ),
            ),

            // Main Layout Content
            Obx(() {
              final currentAdmin = authController.rxAdminRole.value;
              return Row(
                children: [
                  // Sidebar Wrapper
                  Container(
                    width: isCollapsed ? 76 : 260,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkForest : AppColors.lightForest,
                      border: Border(
                        right: BorderSide(
                          color: isDark ? AppColors.darkLine : AppColors.lightLine,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: AdminSidebar(
                      currentAdmin: currentAdmin,
                      isCollapsed: isCollapsed,
                    ),
                  ),
                  // Main Content Screen
                  Expanded(
                    child: child,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
