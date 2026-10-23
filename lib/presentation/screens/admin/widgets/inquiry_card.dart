import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/lead.dart';
import 'inquiry_card_image.dart';
import 'inquiry_card_status_pill.dart';

class InquiryCard extends StatelessWidget {
  final Lead lead;
  final String coverUrl;
  final String cleanType;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onOpenDetails;
  final bool isMobile;
  static const Color goldColor = Color(0xFFECC24A);

  const InquiryCard({
    super.key,
    required this.lead,
    required this.coverUrl,
    required this.cleanType,
    required this.onStatusChanged,
    required this.onOpenDetails,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: goldColor.withValues(alpha: 0.18), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InquiryCardImage(
            lead: lead,
            coverUrl: coverUrl,
            cleanType: cleanType,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.phone_rounded, color: Color(0xFFE5C378), size: 11),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              lead.phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.mail_outline_rounded, color: Color(0xFFE5C378), size: 11),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              lead.email.isNotEmpty ? lead.email : "No email registered",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.diamond_outlined, color: Color(0xFFE5C378), size: 11),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              cleanType,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: goldColor.withValues(alpha: 0.9),
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lead.eventDate != null ? AppFormatters.formatShortDate(lead.eventDate!) : "TBD",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      InquiryCardStatusPill(
                        lead: lead,
                        onStatusChanged: onStatusChanged,
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: onOpenDetails,
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF5C84C), Color(0xFFD4AF37)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: goldColor.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Color(0xFF0A1512),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
