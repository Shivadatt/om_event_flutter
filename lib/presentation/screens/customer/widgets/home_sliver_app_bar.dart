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
import 'booking_tracker_dialog.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactDesktop = screenWidth >= 1024 && screenWidth < 1220;
    final isIntermediate = screenWidth >= 1024 && screenWidth < 1180;
    final isNarrowMobile = screenWidth <= 370;
    final isUltraNarrow = screenWidth < 340;

    final brandColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "OM EVENTS",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.italiana(
            fontSize: isDesktop
                ? (isCompactDesktop ? 14.0 : 17)
                : (isUltraNarrow ? 13.0 : (isNarrowMobile ? 14.5 : 17)),
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: isDesktop
                ? (isCompactDesktop ? 2.0 : 4)
                : (isUltraNarrow ? 1.5 : (isNarrowMobile ? 2.2 : 4)),
          ),
        ),
        SizedBox(height: isNarrowMobile ? 1.5 : 3),
        Text(
          "CELEBRATIONS, THOUGHTFULLY COMPOSED",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.sansBody(
            fontSize: isDesktop
                ? (isCompactDesktop ? 5.4 : 6.8)
                : (isUltraNarrow ? 5.0 : (isNarrowMobile ? 5.6 : 6.8)),
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: isDesktop
                ? (isCompactDesktop ? 0.8 : 2.0)
                : (isUltraNarrow ? 0.4 : (isNarrowMobile ? 0.8 : 2.0)),
          ),
        ),
      ],
    );

    return ValueListenableBuilder<bool>(
      valueListenable: isScrolled,
      builder: (context, scrolled, child) {
        return SliverAppBar(
          floating: true,
          pinned: true,
          toolbarHeight: isNarrowMobile ? 76 : 84,
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
      automaticallyImplyLeading: false,
      leading: null,
      titleSpacing: isDesktop
          ? (isIntermediate ? 10 : (isCompactDesktop ? 16 : 24))
          : (isNarrowMobile ? (isUltraNarrow ? 8.0 : 10.0) : 16.0),
      title: Row(
        children: [
          Container(
            width: isDesktop
                ? (isIntermediate ? 34 : 40)
                : (isUltraNarrow ? 30 : (isNarrowMobile ? 34 : 40)),
            height: isDesktop
                ? (isIntermediate ? 34 : 40)
                : (isUltraNarrow ? 30 : (isNarrowMobile ? 34 : 40)),
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
                  fontSize: isDesktop
                      ? (isIntermediate ? 12 : 14)
                      : (isUltraNarrow ? 10.5 : (isNarrowMobile ? 12.0 : 14.0)),
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          SizedBox(
            width: isDesktop
                ? (isCompactDesktop ? 8 : 14)
                : (isUltraNarrow ? 6 : (isNarrowMobile ? 8 : 14)),
          ),
          if (isDesktop)
            brandColumn
          else
            Expanded(child: brandColumn),
          if (isDesktop) ...[
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavHoverLink(
                  label: "Collections",
                  onTap: () => scrollToSection(categoriesKey),
                ),
                _NavHoverLink(
                  label: "Experiences",
                  onTap: () => scrollToSection(catalogKey),
                ),
                _NavHoverLink(
                  label: "Coverage",
                  onTap: () => Get.toNamed(AppRoutes.serviceArea),
                ),
                _NavHoverLink(
                  label: "Stories",
                  onTap: () => scrollToSection(storiesKey),
                ),
                _NavHoverLink(
                  label: "Contact",
                  onTap: () => Get.toNamed(AppRoutes.contact),
                ),
                _NavHoverLink(
                  label: "Track Booking",
                  onTap: () => showBookingTrackerDialog(context),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        if (isDesktop) ...[
          SizedBox(width: isIntermediate ? 8 : 16),
          Obx(() {
            final count = cartController.rxCartItems.length;
            return _SelectionPill(
              count: count,
              isIntermediate: isIntermediate,
              onTap: () => scaffoldKey.currentState?.openEndDrawer(),
            );
          }),
          SizedBox(width: isIntermediate ? 6 : 12),
          _TextHoverButton(
            label: "CLIENT PORTAL",
            isIntermediate: isIntermediate,
            onPressed: () {
              if (authCtrl.isAuthenticatedCustomer) {
                Get.toNamed(AppRoutes.customerDashboard);
              } else {
                Get.dialog(
                  const Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: CustomerAuthBox(),
                  ),
                );
              }
            },
          ),
          SizedBox(width: isIntermediate ? 10 : (isCompactDesktop ? 16 : 24)),
        ] else ...[
          Obx(() {
            final count = cartController.rxCartItems.length;
            if (count > 0) {
              return Padding(
                padding: EdgeInsets.only(right: isNarrowMobile ? 4 : 8),
                child: _SelectionPill(
                  count: count,
                  isIntermediate: isNarrowMobile,
                  onTap: () => scaffoldKey.currentState?.openEndDrawer(),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: isNarrowMobile ? 36 : 40,
              minHeight: isNarrowMobile ? 36 : 40,
            ),
            icon: Icon(
              Icons.menu,
              color: Colors.white,
              size: isNarrowMobile ? 24 : 26,
            ),
            tooltip: "Navigation Menu",
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          SizedBox(width: isUltraNarrow ? 6 : (isNarrowMobile ? 10 : 14)),
        ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isIntermediate = screenWidth >= 1024 && screenWidth < 1180;
    final isCompact = screenWidth < 1280;
    final double hPad;
    final double fSize;
    final double lSpacing;
    if (screenWidth < 1100) {
      hPad = 3.0;
      fSize = 8.0;
      lSpacing = 0.5;
    } else if (screenWidth < 1180) {
      hPad = 4.0;
      fSize = 8.5;
      lSpacing = 0.8;
    } else if (isCompact) {
      hPad = 7.0;
      fSize = 9.2;
      lSpacing = 1.2;
    } else {
      hPad = 13.0;
      fSize = 10.0;
      lSpacing = 2.0;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: AppTheme.sansBody(
                  fontSize: fSize,
                  color: _isHovered ? AppColors.primaryAccent : Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.bold,
                  letterSpacing: lSpacing,
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
                width: _isHovered ? (isIntermediate ? 18 : (isCompact ? 20 : 28)) : 0,
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
  final bool isIntermediate;
  const _SelectionPill({
    required this.count,
    required this.onTap,
    this.isIntermediate = false,
  });

  @override
  State<_SelectionPill> createState() => _SelectionPillState();
}

class _SelectionPillState extends State<_SelectionPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isIntermediate = widget.isIntermediate || (screenWidth >= 1024 && screenWidth < 1180);
    final isCompact = screenWidth < 1280;
    final double pillHeight = isIntermediate ? 32 : (isCompact ? 36 : 42);
    final double pillHPad = isIntermediate ? 8 : (isCompact ? 11 : 18);
    final double fontSize = isIntermediate ? 8.8 : (isCompact ? 9.6 : 11);
    final double letterSpacing = isIntermediate ? 0.8 : (isCompact ? 1.2 : 1.8);
    final double badgeSize = isIntermediate ? 18 : 22;
    final double badgeFont = isIntermediate ? 8.5 : 10.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: pillHeight,
          padding: EdgeInsets.symmetric(horizontal: pillHPad),
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
                  fontSize: fontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: letterSpacing,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: badgeSize,
                height: badgeSize,
                decoration: const BoxDecoration(
                  color: AppColors.primaryAccent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.count}',
                  style: AppTheme.sansBody(
                    fontSize: badgeFont,
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
  final bool isIntermediate;
  const _TextHoverButton({
    required this.label,
    required this.onPressed,
    this.isIntermediate = false,
  });

  @override
  State<_TextHoverButton> createState() => _TextHoverButtonState();
}

class _TextHoverButtonState extends State<_TextHoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isIntermediate = widget.isIntermediate || (screenWidth >= 1024 && screenWidth < 1180);
    final double fontSize = isIntermediate ? 8.4 : 10.0;
    final double letterSpacing = isIntermediate ? 0.8 : 2.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TextButton(
        style: isIntermediate
            ? TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            : null,
        onPressed: widget.onPressed,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTheme.sansBody(
            fontSize: fontSize,
            color: _isHovered ? Colors.white : AppColors.primaryAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: letterSpacing,
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
