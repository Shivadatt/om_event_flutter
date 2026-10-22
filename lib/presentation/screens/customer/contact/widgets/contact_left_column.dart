import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/business_details_service.dart';
import '../../../../../core/utils/booking_communication_helper.dart';
import 'contact_comm_section.dart';
import 'contact_studios_section.dart';

class ContactLeftColumn extends StatelessWidget {
  final Color goldColor;
  final bool isDesktop;
  final bool isLaptop;
  final bool isTablet;
  final bool isMobile;
  final GlobalKey whatsAppCardKey;
  final VoidCallback onWhatsAppTap;

  const ContactLeftColumn({
    super.key,
    required this.goldColor,
    required this.isDesktop,
    required this.isLaptop,
    required this.isTablet,
    required this.isMobile,
    required this.whatsAppCardKey,
    required this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    final businessPhone = BookingCommunicationHelper.getBusinessPhoneNumber();
    final businessEmail = BookingCommunicationHelper.getBusinessEmail();

    return Obx(() {
      final details = BusinessDetailsService.to.rxDetails.value;
      final social = details.social;

      final instagramKadiUrl = social.instagramKadi.trim().isNotEmpty
          ? social.instagramKadi.trim()
          : (social.instagram.trim().isNotEmpty
              ? social.instagram.trim()
              : "https://instagram.com/om_events_and_decorators");
      final instagramThangadhUrl = social.instagramThangadh.trim().isNotEmpty
          ? social.instagramThangadh.trim()
          : "https://instagram.com/om_events_decorators";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContactStudiosSection(
            goldColor: goldColor,
            isDesktop: isDesktop,
            isMobile: isMobile,
          ),
          const SizedBox(height: 24),
          ContactCommSection(
            goldColor: goldColor,
            primaryPhone: businessPhone,
            businessEmail: businessEmail,
            instagramKadiUrl: instagramKadiUrl,
            instagramThangadhUrl: instagramThangadhUrl,
            isDesktop: isDesktop,
            isLaptop: isLaptop,
            isTablet: isTablet,
            isMobile: isMobile,
            whatsAppCardKey: whatsAppCardKey,
            onWhatsAppTap: onWhatsAppTap,
          ),
        ],
      );
    });
  }
}
