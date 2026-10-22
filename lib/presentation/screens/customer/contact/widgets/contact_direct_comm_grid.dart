import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/utils/booking_communication_helper.dart';
import 'contact_comm_card.dart';
import 'contact_voice_calling_card.dart';

class ContactDirectCommunicationGrid extends StatelessWidget {
  final Color goldColor;
  final String primaryPhone;
  final String businessEmail;
  final bool isDesktop;
  final bool isLaptop;
  final bool isTablet;
  final bool isMobile;
  final GlobalKey whatsAppCardKey;
  final VoidCallback onWhatsAppTap;

  const ContactDirectCommunicationGrid({
    super.key,
    required this.goldColor,
    required this.primaryPhone,
    required this.businessEmail,
    required this.isDesktop,
    required this.isLaptop,
    required this.isTablet,
    required this.isMobile,
    required this.whatsAppCardKey,
    required this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      ContactVoiceCallingCard(
        goldColor: goldColor,
        isMobile: isMobile,
        phone1: primaryPhone.isNotEmpty && primaryPhone.contains('93135')
            ? primaryPhone
            : "+91 93135 13156",
        phone2: "+91 95121 49944",
      ),
      KeyedSubtree(
        key: whatsAppCardKey,
        child: ContactCommCard(
          icon: Icons.chat_bubble_outline_rounded,
          title: "WhatsApp Chat",
          line1: "Chat with our team for",
          line2: "instant assistance.",
          goldColor: const Color(0xFF4EBA7A),
          isMobile: isMobile,
          onTap: onWhatsAppTap,
        ),
      ),
      ContactCommCard(
        icon: Icons.mail_outline_rounded,
        title: "Email Inquiries",
        line1: "omeventsanddecorators",
        line2: "@gmail.com",
        goldColor: goldColor,
        isMobile: isMobile,
        onTap: () => BookingCommunicationHelper.openEmail(),
      ),
      ContactCommCard(
        icon: Icons.map_outlined,
        title: "Service Area & Policy",
        line1: "Check delivery zones &",
        line2: "pin codes across Gujarat.",
        goldColor: goldColor,
        isMobile: isMobile,
        onTap: () => Get.toNamed(AppRoutes.serviceArea),
      ),
    ];

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cards
            .map(
              (c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: c,
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 10),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 10),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    }
  }
}
