import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../../core/config/app_theme.dart';
import 'contact_direct_comm_grid.dart';

class ContactInstagramPill extends StatelessWidget {
  final String label;
  final String url;
  final Color goldColor;

  const ContactInstagramPill({
    super.key,
    required this.label,
    required this.url,
    required this.goldColor,
  });

  void _safeLaunchUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final target =
          (url.startsWith('http://') ||
                  url.startsWith('https://') ||
                  url.startsWith('tel:') ||
                  url.startsWith('mailto:'))
              ? url
              : 'https://$url';
      await launchUrlString(target, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _safeLaunchUrl(url),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 14, color: goldColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sansBody(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_outward_rounded, size: 11, color: goldColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContactCommSection extends StatelessWidget {
  final Color goldColor;
  final String primaryPhone;
  final String businessEmail;
  final String instagramKadiUrl;
  final String instagramThangadhUrl;
  final bool isDesktop;
  final bool isLaptop;
  final bool isTablet;
  final bool isMobile;
  final GlobalKey whatsAppCardKey;
  final VoidCallback onWhatsAppTap;

  const ContactCommSection({
    super.key,
    required this.goldColor,
    required this.primaryPhone,
    required this.businessEmail,
    required this.instagramKadiUrl,
    required this.instagramThangadhUrl,
    required this.isDesktop,
    required this.isLaptop,
    required this.isTablet,
    required this.isMobile,
    required this.whatsAppCardKey,
    required this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: goldColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.headset_mic_outlined, size: 16, color: goldColor),
            ),
            const SizedBox(width: 8),
            Text(
              "DIRECT COMMUNICATION",
              style: GoogleFonts.italiana(
                fontSize: isMobile ? 17 : 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Get in touch with us directly through your preferred channel.",
          style: AppTheme.sansBody(
            fontSize: isMobile ? 11 : 11.5,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 14),

        ContactDirectCommunicationGrid(
          goldColor: goldColor,
          primaryPhone: primaryPhone,
          businessEmail: businessEmail,
          isDesktop: isDesktop,
          isLaptop: isLaptop,
          isTablet: isTablet,
          isMobile: isMobile,
          whatsAppCardKey: whatsAppCardKey,
          onWhatsAppTap: onWhatsAppTap,
        ),
        const SizedBox(height: 24),

        Text(
          "FOLLOW OUR CELEBRATIONS",
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.2,
            color: goldColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ContactInstagramPill(
                label: "Instagram – Kadi",
                url: instagramKadiUrl,
                goldColor: goldColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ContactInstagramPill(
                label: "Instagram – Thangadh",
                url: instagramThangadhUrl,
                goldColor: goldColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
