import 'package:flutter/material.dart';
import '../../../../core/utils/booking_communication_helper.dart';
import '../../../../domain/entities/lead.dart';

class InquiryDetailsContactBox extends StatelessWidget {
  final Lead lead;
  final String cleanType;
  static const Color goldColor = Color(0xFFECC24A);

  const InquiryDetailsContactBox({
    super.key,
    required this.lead,
    required this.cleanType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF081410),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.phone_rounded, color: goldColor, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lead.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              InkWell(
                onTap: () => BookingCommunicationHelper.openCall(lead.phone),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call_outlined, color: Colors.white70, size: 13),
                      SizedBox(width: 4),
                      Text("Call", style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => BookingCommunicationHelper.openWhatsApp(
                  message: "Hello ${lead.name}, regarding your $cleanType inquiry with OM Events:",
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4EBA7A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF4EBA7A), size: 13),
                      SizedBox(width: 4),
                      Text("WhatsApp", style: TextStyle(color: Color(0xFF4EBA7A), fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (lead.email.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 16),
            Row(
              children: [
                const Icon(Icons.mail_outline_rounded, color: goldColor, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lead.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
