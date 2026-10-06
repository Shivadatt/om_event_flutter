import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/config/app_theme.dart';
import '../../../../../../core/config/constants.dart';
import '../../../../../../core/services/business_details_service.dart';

/// Non-intrusive luxury Contact CTA rendered in collaboration chats after
/// 2 actual messages have been exchanged.
/// IMPORTANT: Tapping these CTA buttons creates 0 Firestore writes.
class ChatContactCtaWidget extends StatelessWidget {
  const ChatContactCtaWidget({super.key});

  static Future<void> launchWhatsApp() async {
    try {
      String rawNumber = '';
      if (Get.isRegistered<BusinessDetailsService>()) {
        final contacts = BusinessDetailsService.to.rxDetails.value.contacts;
        for (final item in contacts.whatsapps) {
          if (item.isActive && item.value.trim().isNotEmpty) {
            rawNumber = item.value.trim();
            break;
          }
        }
      }

      if (rawNumber.isEmpty) {
        rawNumber = AppConstants.businessPhone;
      }

      final clean = rawNumber.replaceAll(RegExp(r'\D'), '');
      final number = clean.length == 10 ? '91$clean' : clean;
      const text = "Hello Om Events, I'd like to discuss my event proposal.";
      final uri = Uri.parse("https://wa.me/$number?text=${Uri.encodeComponent(text)}");

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  static Future<void> launchInstagram() async {
    try {
      String url = '';
      if (Get.isRegistered<BusinessDetailsService>()) {
        final social = BusinessDetailsService.to.rxDetails.value.social;
        if (social.instagram.trim().isNotEmpty) {
          url = social.instagram.trim();
        } else if (social.instagramKadi.trim().isNotEmpty) {
          url = social.instagramKadi.trim();
        } else if (social.instagramThangadh.trim().isNotEmpty) {
          url = social.instagramThangadh.trim();
        }
      }

      if (url.isEmpty) {
        url = 'https://instagram.com/omevents_kadi';
      }

      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1612),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x33D4AF37),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Divider(color: Color(0x22D4AF37), thickness: 0.8),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Need faster help?",
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4AF37),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: Color(0x22D4AF37), thickness: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              // WhatsApp CTA
              InkWell(
                onTap: launchWhatsApp,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x1F25D366),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x5525D366), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 14,
                        color: Color(0xFF25D366),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Contact on WhatsApp",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF25D366),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Instagram CTA
              InkWell(
                onTap: launchInstagram,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x1FE1306C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x55E1306C), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 14,
                        color: Color(0xFFE1306C),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Contact on Instagram",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE1306C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
