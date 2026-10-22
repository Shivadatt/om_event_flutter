import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/utils/booking_communication_helper.dart';

class ContactVoiceCallingCard extends StatelessWidget {
  final Color goldColor;
  final bool isMobile;
  final String phone1;
  final String phone2;

  const ContactVoiceCallingCard({
    super.key,
    required this.goldColor,
    required this.isMobile,
    this.phone1 = "+91 93135 13156",
    this.phone2 = "+91 95121 49944",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 10,
          vertical: isMobile ? 10 : 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header (Primary Call on Tap)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () => BookingCommunicationHelper.openCall(phone1),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: goldColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(Icons.phone_outlined, size: 13, color: goldColor),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Card Title (Primary Call on Tap)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => BookingCommunicationHelper.openCall(phone1),
                child: Text(
                  "Voice Calling",
                  style: GoogleFonts.montserrat(
                    fontSize: isMobile ? 10.5 : 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),

            // Phone 1 Independent Click-To-Call Action
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                hoverColor: goldColor.withValues(alpha: 0.14),
                onTap: () => BookingCommunicationHelper.openCall(phone1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2.0,
                    horizontal: 1.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          phone1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.sansBody(
                            fontSize: isMobile ? 9 : 9.5,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Phone 2 Independent Click-To-Call Action
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                hoverColor: goldColor.withValues(alpha: 0.14),
                onTap: () => BookingCommunicationHelper.openCall(phone2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2.0,
                    horizontal: 1.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          phone2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.sansBody(
                            fontSize: isMobile ? 9 : 9.5,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
