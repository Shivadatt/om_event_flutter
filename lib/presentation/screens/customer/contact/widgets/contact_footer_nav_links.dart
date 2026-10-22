import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../widgets/booking_tracker_dialog.dart';

class ContactFooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool allowWrap;

  const ContactFooterLink({
    super.key,
    required this.label,
    required this.onTap,
    this.allowWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          label,
          softWrap: allowWrap,
          style: AppTheme.sansBody(fontSize: 10, color: Colors.white60),
        ),
      ),
    );
  }
}

class ContactFooterExploreColumn extends StatelessWidget {
  final Color goldColor;

  const ContactFooterExploreColumn({super.key, required this.goldColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "EXPLORE",
          style: AppTheme.sansBody(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: goldColor,
          ),
        ),
        const SizedBox(height: 8),
        ContactFooterLink(
          label: "Collections",
          onTap: () => Get.offAllNamed(AppRoutes.home),
        ),
        ContactFooterLink(
          label: "Experiences",
          onTap: () => Get.offAllNamed(AppRoutes.home),
        ),
        ContactFooterLink(
          label: "Event Gallery",
          onTap: () => Get.toNamed(AppRoutes.gallery),
        ),
        ContactFooterLink(
          label: "Service Areas",
          onTap: () => Get.toNamed(AppRoutes.serviceArea),
        ),
        ContactFooterLink(
          label: "Booking Policy",
          onTap: () => Get.toNamed(AppRoutes.bookingPolicy),
        ),
      ],
    );
  }
}

class ContactFooterHelpColumn extends StatelessWidget {
  final Color goldColor;

  const ContactFooterHelpColumn({super.key, required this.goldColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "HELP",
          style: AppTheme.sansBody(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: goldColor,
          ),
        ),
        const SizedBox(height: 8),
        ContactFooterLink(
          label: "Cancellation Policy",
          onTap: () => Get.toNamed(AppRoutes.cancellationPolicy),
        ),
        ContactFooterLink(label: "Contact & Studios", onTap: () {}),
        ContactFooterLink(
          label: "Stories",
          onTap: () => Get.offAllNamed(AppRoutes.home),
        ),
        ContactFooterLink(
          label: "Track Booking",
          onTap: () => showBookingTrackerDialog(context),
        ),
        ContactFooterLink(
          label: "FAQ",
          onTap: () => Get.offAllNamed(AppRoutes.home),
        ),
      ],
    );
  }
}
