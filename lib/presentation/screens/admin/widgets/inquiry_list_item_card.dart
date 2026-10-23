import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/lead.dart';
import 'inquiry_card_status_pill.dart';

class InquiryListItemCard extends StatelessWidget {
  final Lead lead;
  final String coverUrl;
  final String cleanType;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onOpenDetails;
  static const Color goldColor = Color(0xFFECC24A);

  const InquiryListItemCard({
    super.key,
    required this.lead,
    required this.coverUrl,
    required this.cleanType,
    required this.onStatusChanged,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpenDetails,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1914),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: goldColor.withValues(alpha: 0.16), width: 0.8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                coverUrl,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 42,
                  height: 42,
                  color: const Color(0xFF081410),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lead.phone,
                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                cleanType,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                lead.eventDate != null ? AppFormatters.formatShortDate(lead.eventDate!) : "TBD",
                style: const TextStyle(fontSize: 11.5, color: Colors.white70),
              ),
            ),
            Text(
              lead.budget != null ? AppFormatters.formatCurrency(lead.budget!) : "₹0",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF5C84C)),
            ),
            const SizedBox(width: 14),
            InquiryCardStatusPill(
              lead: lead,
              onStatusChanged: onStatusChanged,
            ),
            const SizedBox(width: 10),
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFF5C84C), Color(0xFFD4AF37)],
                ),
              ),
              child: const Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF0A1512)),
            ),
          ],
        ),
      ),
    );
  }
}
