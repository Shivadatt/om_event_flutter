import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../controllers/auth_controller.dart';
import 'admin_drawer.dart';
import 'admin_mobile_header.dart';
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

  Widget _buildBlurBlob({
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

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final screenWidth = context.screenWidth;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 700 && screenWidth < 1024;
    final hasSidebar = isDesktop || isTablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdminLayoutScope(
      child: Obx(() {
        final currentAdmin = authController.rxAdminRole.value;
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkCream : AppColors.lightCream,
          drawer: !isDesktop ? AdminDrawer(currentAdmin: currentAdmin) : null,
          body: Stack(
            children: [
              // Ambient Luxury Lighting Background (Vignette)
              Positioned.fill(
                child: Stack(
                  children: [
                    if (isDark) ...[
                      _buildBlurBlob(size: 600, color: AppColors.primaryAccent, top: -200, left: -100),
                      _buildBlurBlob(size: 500, color: AppColors.secondaryAccent, top: 250, right: -150),
                      _buildBlurBlob(size: 400, color: AppColors.highlight, top: 600, left: 200),
                    ] else ...[
                      _buildBlurBlob(size: 600, color: AppColors.primaryAccent.withValues(alpha: 0.2), top: -200, left: -100),
                      _buildBlurBlob(size: 500, color: AppColors.secondaryAccent.withValues(alpha: 0.15), top: 250, right: -150),
                    ],
                  ],
                ),
              ),

              // Main Layout Content: Full screen pinned
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasSidebar)
                      Container(
                        width: isDesktop ? 230 : 68,
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
                          isCollapsed: isTablet,
                        ),
                      ),
                    // Main Content Screen (Fills remaining width and height)
                    Expanded(
                      child: !hasSidebar
                          ? Column(
                              children: [
                                AdminMobileHeader(
                                  currentAdmin: currentAdmin,
                                  isDark: isDark,
                                ),
                                Expanded(child: child),
                              ],
                            )
                          : child,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
