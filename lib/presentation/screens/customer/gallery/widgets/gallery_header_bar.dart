import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../widgets/app_page_container.dart';
import '../../widgets/booking_tracker_dialog.dart';

class GalleryHeaderBar extends StatelessWidget {
  final double hPad;
  final bool isDesktop;
  final double screenWidth;
  final Color goldColor;
  final Color headerBgColor;

  const GalleryHeaderBar({
    super.key,
    required this.hPad,
    required this.isDesktop,
    required this.screenWidth,
    required this.goldColor,
    required this.headerBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: headerBgColor,
      elevation: 0,
      toolbarHeight: 64,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: goldColor.withValues(alpha: 0.12)),
      ),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: headerBgColor,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppPageContainer.maxContentWidth,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: "Back",
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Get.offAllNamed(AppRoutes.home);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: goldColor, width: 1.2),
                          gradient: RadialGradient(
                            colors: [
                              goldColor.withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "OE",
                            style: GoogleFonts.italiana(
                              fontSize: 12,
                              color: goldColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PORTFOLIO GALLERY",
                            style: GoogleFonts.italiana(
                              fontSize: isDesktop ? 17 : 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "EXPERIENCES CRAFTED WITH PASSION",
                            style: AppTheme.sansBody(
                              fontSize: isDesktop ? 8.5 : 7.5,
                              fontWeight: FontWeight.w600,
                              color: goldColor.withValues(alpha: 0.85),
                              letterSpacing: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (screenWidth >= 560) ...[
                        TextButton.icon(
                          icon: Icon(
                            Icons.travel_explore_outlined,
                            size: 15,
                            color: goldColor,
                          ),
                          label: Text(
                            "SERVICE AREA",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color: goldColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          onPressed: () => Get.toNamed(AppRoutes.serviceArea),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.track_changes_rounded,
                            size: 15,
                            color: Colors.white70,
                          ),
                          label: Text(
                            "TRACK BOOKING",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          onPressed: () => showBookingTrackerDialog(context),
                        ),
                      ] else ...[
                        IconButton(
                          icon: Icon(
                            Icons.travel_explore_outlined,
                            size: 18,
                            color: goldColor,
                          ),
                          tooltip: "Service Area",
                          onPressed: () => Get.toNamed(AppRoutes.serviceArea),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.track_changes_rounded,
                            size: 18,
                            color: Colors.white70,
                          ),
                          tooltip: "Track Booking",
                          onPressed: () => showBookingTrackerDialog(context),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
