import 'package:flutter/material.dart';
import '../../../../../core/services/app_config_service.dart';
import '../../../../../core/services/business_details_service.dart';
import 'contact_footer_desktop_view.dart';
import 'contact_footer_mobile_view.dart';

class ContactPremiumFooter extends StatelessWidget {
  final Color goldColor;
  final bool isDesktop;
  final bool isLaptop;
  final bool isTablet;
  final bool isMobile;

  const ContactPremiumFooter({
    super.key,
    required this.goldColor,
    required this.isDesktop,
    required this.isLaptop,
    required this.isTablet,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final originalDetails = BusinessDetailsService.to.rxDetails.value;
    final businessProfile = AppConfigService.to.rxBusinessProfile.value;

    final List<String> branchLines = [];
    if (originalDetails.branches.isNotEmpty) {
      for (final b in originalDetails.branches) {
        if (b.branchName.isNotEmpty) {
          final addr = b.fullAddress.isNotEmpty
              ? b.fullAddress.split(',').first.trim()
              : '';
          branchLines.add(
            addr.isNotEmpty ? "${b.branchName} – $addr" : b.branchName,
          );
        }
      }
    } else if (businessProfile.officeBranches.isNotEmpty) {
      for (final b in businessProfile.officeBranches) {
        if (b.branchName.isNotEmpty) {
          final addr =
              b.address.isNotEmpty ? b.address.split(',').first.trim() : '';
          branchLines.add(
            addr.isNotEmpty ? "${b.branchName} – $addr" : b.branchName,
          );
        }
      }
    }
    if (branchLines.isEmpty) {
      branchLines.add("Kadi (Medha) – Medha (kadi-kalyanpura road)");
      branchLines.add("Thangadh – Thangadh (Surendranagar)");
      branchLines.add("Gujarat, India 382715");
    } else if (branchLines.length == 2) {
      branchLines.add("Gujarat, India 382715");
    }

    const primaryPhone = "+91 93135 13156";
    const secondaryPhone = "+91 95121 49944";
    const primaryEmail = "omeventsanddecorators@gmail.com";

    final String instagramKadi =
        originalDetails.social.instagramKadi.trim().isNotEmpty
            ? originalDetails.social.instagramKadi.trim()
            : "https://instagram.com/om_events_and_decorators";
    final String instagramThangadh =
        originalDetails.social.instagramThangadh.trim().isNotEmpty
            ? originalDetails.social.instagramThangadh.trim()
            : "https://instagram.com/om_events_decorators";

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF060907),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: (isDesktop || isLaptop)
          ? ContactFooterDesktopView(
              goldColor: goldColor,
              isDesktop: isDesktop,
              branchLines: branchLines,
              primaryPhone: primaryPhone,
              secondaryPhone: secondaryPhone,
              primaryEmail: primaryEmail,
              instagramKadi: instagramKadi,
              instagramThangadh: instagramThangadh,
            )
          : ContactFooterMobileView(
              goldColor: goldColor,
              isTablet: isTablet,
              branchLines: branchLines,
              primaryPhone: primaryPhone,
              secondaryPhone: secondaryPhone,
              primaryEmail: primaryEmail,
              instagramKadi: instagramKadi,
              instagramThangadh: instagramThangadh,
            ),
    );
  }
}
