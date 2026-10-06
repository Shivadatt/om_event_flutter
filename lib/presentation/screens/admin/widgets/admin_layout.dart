import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../controllers/auth_controller.dart';
import 'admin_sidebar.dart';
import 'admin_drawer.dart';

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
    final isDesktop = context.screenWidth >= 1024;
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

    Widget buildMobileHeader(BuildContext context) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkForest : AppColors.lightForest,
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkLine : AppColors.lightLine,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.primaryAccent),
                tooltip: "Open Menu",
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkForestSecondary : AppColors.lightForestSecondary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.primaryAccent.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: const Text(
                "OE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryAccent,
                  fontFamily: 'serif',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "OM EVENTS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.darkInk : AppColors.lightInk,
                  ),
                ),
                Text(
                  "STUDIO ADMIN",
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

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

              // Main Layout Content: Full screen pinned
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isDesktop)
                      Container(
                        width: 230,
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
                          isCollapsed: false,
                        ),
                      ),
                    // Main Content Screen (Fills remaining width and height)
                    Expanded(
                      child: !isDesktop
                          ? Column(
                              children: [
                                buildMobileHeader(context),
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
