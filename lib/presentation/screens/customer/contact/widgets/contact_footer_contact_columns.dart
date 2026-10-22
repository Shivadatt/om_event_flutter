import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/utils/booking_communication_helper.dart';

class ContactFooterVisitUsColumn extends StatelessWidget {
  final List<String> branches;
  final Color goldColor;

  const ContactFooterVisitUsColumn({
    super.key,
    required this.branches,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "VISIT US",
          style: AppTheme.sansBody(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: goldColor,
          ),
        ),
        const SizedBox(height: 8),
        for (final b in branches)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    b,
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      color: Colors.white70,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ContactFooterGetInTouchColumn extends StatelessWidget {
  final String p1;
  final String p2;
  final String email;
  final String instaKadi;
  final String instaThangadh;
  final Color goldColor;

  const ContactFooterGetInTouchColumn({
    super.key,
    required this.p1,
    required this.p2,
    required this.email,
    required this.instaKadi,
    required this.instaThangadh,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "GET IN TOUCH",
          style: AppTheme.sansBody(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: goldColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => BookingCommunicationHelper.openCall(p1),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Icon(Icons.phone_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Text(
                  p1,
                  style: AppTheme.sansBody(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => BookingCommunicationHelper.openCall(p2),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Icon(Icons.phone_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Text(
                  p2,
                  style: AppTheme.sansBody(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => BookingCommunicationHelper.openEmail(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Icon(Icons.email_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTheme.sansBody(fontSize: 10, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => _safeLaunchUrl(instaKadi),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Icon(Icons.camera_alt_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Text(
                  "Instagram – Kadi ↗",
                  style:
                      AppTheme.sansBody(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => _safeLaunchUrl(instaThangadh),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Icon(Icons.camera_alt_outlined, size: 12, color: goldColor),
                const SizedBox(width: 5),
                Text(
                  "Instagram – Thangadh ↗",
                  style:
                      AppTheme.sansBody(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
