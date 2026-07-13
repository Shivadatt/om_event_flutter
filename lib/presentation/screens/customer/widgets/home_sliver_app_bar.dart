import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_routes.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
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

  final ValueNotifier<bool> isScrolled;

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
    required this.isScrolled,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isScrolled,
      builder: (context, scrolled, child) {
        return SliverAppBar(
          floating: true,
          pinned: true,
          toolbarHeight: 84,
          backgroundColor: scrolled
              ? Colors.black
              : const Color(0xFF0F1B18).withValues(alpha: 0.45),
          elevation: 0,
          scrolledUnderElevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.5),
        child: Container(
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryAccent.withValues(alpha: 0.0),
                AppColors.primaryAccent.withValues(alpha: 0.35),
                AppColors.secondaryAccent.withValues(alpha: 0.35),
                AppColors.primaryAccent.withValues(alpha: 0.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      leading: isDesktop
          ? null
          : IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryAccent,
                width: 1.2,
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryAccent.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withValues(alpha: 0.1),
                  blurRadius: 8,
                )
              ]
            ),
            child: Center(
              child: Text(
                "OE",
                style: GoogleFonts.italiana(
                  fontSize: 14,
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "OM EVENTS",
                style: GoogleFonts.italiana(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "CELEBRATIONS, THOUGHTFULLY COMPOSED",
                style: AppTheme.sansBody(
                  fontSize: 6.8,
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          if (isDesktop) ...[
            const Spacer(),
            _NavHoverLink(
              label: "Collections",
              onTap: () => scrollToSection(categoriesKey),
            ),
            _NavHoverLink(
              label: "Experiences",
              onTap: () => scrollToSection(catalogKey),
            ),
            _NavHoverLink(
              label: "Stories",
              onTap: () => scrollToSection(storiesKey),
            ),
            _NavHoverLink(
              label: "Contact",
              onTap: () => scrollToSection(contactKey),
            ),
            // _NavHoverLink(
            //   label: "Developer API",
            //   onTap: () => Get.toNamed(AppRoutes.docs),
            // ),
          ],
        ],
      ),
      actions: [
        const SizedBox(width: 8),
        Obx(() {
          final count = cartController.rxCartItems.length;
          return _SelectionPill(
            count: count,
            onTap: () => scaffoldKey.currentState?.openEndDrawer(),
          );
        }),
        const SizedBox(width: 16),
        Obx(() {
          final isLoggedIn = authCtrl.rxIsLoggedIn.value;
          if (isDesktop) {
            return _TextHoverButton(
              label: isLoggedIn ? "CLIENT PORTAL" : "CLIENT LOGIN",
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
          } else {
            return IconButton(
              icon: Icon(
                isLoggedIn ? Icons.dashboard_outlined : Icons.person_outline,
                color: AppColors.primaryAccent,
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
        const SizedBox(width: 12),
        if (isDesktop)
          _TextHoverButton(
            label: "TEAM STUDIO",
            onPressed: () => Get.toNamed(AppRoutes.login),
          )
        else
          IconButton(
            icon: const Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.primaryAccent,
            ),
            onPressed: () => Get.toNamed(AppRoutes.login),
          ),
        const SizedBox(width: 24),
      ],
    );
  },
);
  }
}

class _NavHoverLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavHoverLink({required this.label, required this.onTap});

  @override
  State<_NavHoverLink> createState() => _NavHoverLinkState();
}

class _NavHoverLinkState extends State<_NavHoverLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: AppTheme.sansBody(
                  fontSize: 10,
                  color: _isHovered ? AppColors.primaryAccent : Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ).copyWith(
                  shadows: _isHovered
                      ? [
                          Shadow(
                            color: AppColors.primaryAccent.withValues(alpha: 0.5),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 1.5,
                width: _isHovered ? 28 : 0,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAccent.withValues(alpha: 0.8),
                      blurRadius: 4,
                    )
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionPill extends StatefulWidget {
  final int count;
  final VoidCallback onTap;
  const _SelectionPill({required this.count, required this.onTap});

  @override
  State<_SelectionPill> createState() => _SelectionPillState();
}

class _SelectionPillState extends State<_SelectionPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: _isHovered ? AppColors.primaryAccent.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.02),
            border: Border.all(
              color: _isHovered ? AppColors.primaryAccent : AppColors.primaryAccent.withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primaryAccent.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: -1,
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "SELECTION",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primaryAccent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.count}',
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    color: const Color(0xFF0F1B18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextHoverButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _TextHoverButton({required this.label, required this.onPressed});

  @override
  State<_TextHoverButton> createState() => _TextHoverButtonState();
}

class _TextHoverButtonState extends State<_TextHoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TextButton(
        onPressed: widget.onPressed,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTheme.sansBody(
            fontSize: 10,
            color: _isHovered ? Colors.white : AppColors.primaryAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ).copyWith(
            shadows: _isHovered
                ? [
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.4),
                      blurRadius: 6,
                    )
                  ]
                : null,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
