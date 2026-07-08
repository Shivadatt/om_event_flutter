import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_routes.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/presentation/controllers/cart_controller.dart';
import 'package:om_event/presentation/controllers/customer_auth_controller.dart';
import '../auth/widgets/customer_auth_box.dart';

class HomeSliverAppBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final CartController cartController;
  final CustomerAuthController authCtrl;
  final bool isDesktop;
  final bool isDark;
  final GlobalKey categoriesKey;
  final GlobalKey catalogKey;
  final GlobalKey storiesKey;
  final GlobalKey contactKey;
  final void Function(GlobalKey) scrollToSection;

  const HomeSliverAppBar({
    super.key,
    required this.scaffoldKey,
    required this.cartController,
    required this.authCtrl,
    required this.isDesktop,
    required this.isDark,
    required this.categoriesKey,
    required this.catalogKey,
    required this.storiesKey,
    required this.contactKey,
    required this.scrollToSection,
  });

  Widget _navLink(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 10,
            color: isDark ? Colors.white70 : const Color(0xFF17201E),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      toolbarHeight: 76,
      backgroundColor: isDark ? const Color(0xFF101C18) : const Color(0xFFFAF8F5),
      leading: isDesktop
          ? null
          : IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark ? Colors.white : const Color(0xFF17201E),
              ),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white : const Color(0xFF17201E),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                "OE",
                style: AppTheme.serifHeader(
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF17201E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "OM EVENTS",
                style: AppTheme.serifHeader(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF17201E),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                "MAKE IT MEMORABLE",
                style: AppTheme.sansBody(
                  fontSize: 6,
                  color: isDark ? Colors.white70 : const Color(0xFF1E2B27),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          if (isDesktop) ...[
            const Spacer(),
            _navLink(
              context,
              "Collections",
              () => scrollToSection(categoriesKey),
            ),
            _navLink(
              context,
              "Experiences",
              () => scrollToSection(catalogKey),
            ),
            _navLink(
              context,
              "Stories",
              () => scrollToSection(storiesKey),
            ),
            _navLink(
              context,
              "Contact",
              () => scrollToSection(contactKey),
            ),
            _navLink(
              context,
              "Developer API",
              () => Get.toNamed(AppRoutes.docs),
            ),
          ],
        ],
      ),
      actions: [
        const SizedBox(width: 8),
        Obx(() {
          final count = cartController.rxCartItems.length;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => scaffoldKey.currentState?.openEndDrawer(),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Selection",
                      style: AppTheme.sansBody(
                        fontSize: 12,
                        color: isDark ? Colors.white : const Color(0xFF17201E),
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : const Color(0xFF1E2B27),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$count',
                        style: AppTheme.sansBody(
                          fontSize: 10,
                          color: isDark ? const Color(0xFF1B2925) : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 14),
        Obx(() {
          final isLoggedIn = authCtrl.rxIsLoggedIn.value;
          if (isDesktop) {
            return TextButton(
              onPressed: () {
                if (isLoggedIn) {
                  Get.toNamed(AppRoutes.customerDashboard);
                } else {
                  Get.dialog(
                    const Dialog(
                      backgroundColor: Colors.transparent,
                      child: CustomerAuthBox(),
                    ),
                  );
                }
              },
              child: Text(
                isLoggedIn ? "CLIENT PORTAL" : "CLIENT LOGIN",
                style: AppTheme.sansBody(
                  fontSize: 10,
                  color: const Color(0xFFD3AD7B),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            );
          } else {
            return IconButton(
              icon: Icon(
                isLoggedIn ? Icons.dashboard_outlined : Icons.person_outline,
                color: isDark ? Colors.white : const Color(0xFF17201E),
              ),
              onPressed: () {
                if (isLoggedIn) {
                  Get.toNamed(AppRoutes.customerDashboard);
                } else {
                  Get.dialog(
                    const Dialog(
                      backgroundColor: Colors.transparent,
                      child: CustomerAuthBox(),
                    ),
                  );
                }
              },
            );
          }
        }),
        const SizedBox(width: 14),
        if (isDesktop)
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.login),
            child: Text(
              "TEAM STUDIO",
              style: AppTheme.sansBody(
                fontSize: 10,
                color: const Color(0xFFD3AD7B),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          )
        else
          IconButton(
            icon: Icon(
              Icons.admin_panel_settings_outlined,
              color: isDark ? Colors.white : const Color(0xFF17201E),
            ),
            onPressed: () => Get.toNamed(AppRoutes.login),
          ),
        const SizedBox(width: 16),
      ],
    );
  }
}
