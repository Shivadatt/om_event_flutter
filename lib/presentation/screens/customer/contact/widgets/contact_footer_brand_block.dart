import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/utils/booking_communication_helper.dart';
import '../../helpers/customer_dialog_helper.dart';

class ContactFooterBrandBlock extends StatelessWidget {
  final Color goldColor;

  const ContactFooterBrandBlock({
    super.key,
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

  Widget _buildSmallSocialIcon(
    IconData icon,
    Color goldColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: goldColor.withValues(alpha: 0.4),
            width: 1,
          ),
          color: const Color(0xFF0C1914),
        ),
        child: Icon(icon, size: 12, color: goldColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "LET'S CREATE SOMETHING EXTRAORDINARY",
          style: AppTheme.sansBody(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.2,
            color: goldColor,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Moments pass.\n",
                style: GoogleFonts.italiana(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: "Beautiful ones echo.",
                style: GoogleFonts.italiana(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "From intimate gatherings to grand celebrations, we turn your vision into unforgettable experiences.",
          style: AppTheme.sansBody(
            fontSize: 10,
            color: Colors.white60,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => CustomerDialogHelper.openLeadDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: goldColor,
            foregroundColor: const Color(0xFF091210),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "START A CONVERSATION",
                style: AppTheme.sansBody(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 12),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSmallSocialIcon(
              Icons.camera_alt_outlined,
              goldColor,
              () => _safeLaunchUrl(
                "https://instagram.com/om_events_and_decorators",
              ),
            ),
            const SizedBox(width: 8),
            _buildSmallSocialIcon(
              Icons.facebook_outlined,
              goldColor,
              () => _safeLaunchUrl("https://facebook.com"),
            ),
            const SizedBox(width: 8),
            _buildSmallSocialIcon(
              Icons.play_circle_outline_rounded,
              goldColor,
              () => _safeLaunchUrl("https://youtube.com"),
            ),
            const SizedBox(width: 8),
            _buildSmallSocialIcon(
              Icons.chat_bubble_outline_rounded,
              goldColor,
              () => BookingCommunicationHelper.openWhatsApp(
                message: "Hello OM Events",
              ),
            ),
          ],
        ),
      ],
    );
  }
}
