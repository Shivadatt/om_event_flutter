import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../widgets/booking_tracker_dialog.dart';

class ServiceAreaHeader extends StatelessWidget {
  final bool isDesktop;
  final bool isMobile;
  final double screenWidth;

  const ServiceAreaHeader({
    super.key,
    required this.isDesktop,
    required this.isMobile,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF08120E).withValues(alpha: 0.98),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: Colors.white70,
        ),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Get.offAllNamed(AppRoutes.home);
          }
        },
      ),
      title: Text(
        "SERVICE AREA & COVERAGE",
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.italiana(
          fontSize: isDesktop ? 17 : (isMobile ? 13 : 15),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: isMobile ? 1.2 : 2.0,
        ),
      ),
      actions: [
        if (screenWidth > 380)
          TextButton.icon(
            icon: const Icon(
              Icons.track_changes_rounded,
              size: 15,
              color: Colors.white70,
            ),
            label: Text(
              "TRACK BOOKING",
              style: AppTheme.sansBody(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => showBookingTrackerDialog(context),
          )
        else
          IconButton(
            icon: const Icon(
              Icons.track_changes_rounded,
              size: 18,
              color: Colors.white70,
            ),
            tooltip: "Track Booking",
            onPressed: () => showBookingTrackerDialog(context),
          ),
        SizedBox(width: isMobile ? 8 : 16),
      ],
    );
  }
}
