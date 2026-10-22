import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/utils/booking_communication_helper.dart';

class ContactInquirySuccessCard extends StatelessWidget {
  final Color goldColor;
  final bool isMobile;
  final VoidCallback onReset;

  const ContactInquirySuccessCard({
    super.key,
    required this.goldColor,
    required this.isMobile,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 36),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4EBA7A).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: Color(0xFF4EBA7A),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "MESSAGE SUBMITTED",
            style: GoogleFonts.italiana(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Your message has been submitted successfully.\nOur styling team will get back to you shortly.",
            textAlign: TextAlign.center,
            style: AppTheme.sansBody(
              fontSize: 13,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => BookingCommunicationHelper.openWhatsApp(
                message:
                    BookingCommunicationHelper.generateGeneralInquiryMessage(),
              ),
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                "CONTINUE ON WHATSAPP FOR INSTANT REPLY",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onReset,
            child: Text(
              "Send another message",
              style: AppTheme.sansBody(fontSize: 12, color: goldColor),
            ),
          ),
        ],
      ),
    );
  }
}
