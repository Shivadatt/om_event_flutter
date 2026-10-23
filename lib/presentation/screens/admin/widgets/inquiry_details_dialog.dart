import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/lead.dart';
import 'inquiry_details_contact_box.dart';
import 'inquiry_details_meta_section.dart';

class InquiryDetailsDialog extends StatelessWidget {
  final Lead lead;
  final String coverUrl;
  final String cleanType;
  final ValueChanged<String> onStatusChanged;
  static const Color goldColor = Color(0xFFECC24A);

  const InquiryDetailsDialog({
    super.key,
    required this.lead,
    required this.coverUrl,
    required this.cleanType,
    required this.onStatusChanged,
  });

  static void show(
    BuildContext context, {
    required Lead lead,
    required String coverUrl,
    required String cleanType,
    required ValueChanged<String> onStatusChanged,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (ctx) => InquiryDetailsDialog(
        lead: lead,
        coverUrl: coverUrl,
        cleanType: cleanType,
        onStatusChanged: onStatusChanged,
      ),
    );
  }

  Widget _buildStatusPicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "UPDATE STATUS:",
          style: TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF142B20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E6B4A)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: lead.status,
              dropdownColor: const Color(0xFF0C1914),
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 22),
              items: const [
                DropdownMenuItem(value: 'new', child: Text("New", style: TextStyle(color: Color(0xFF6EDC98), fontSize: 12, fontWeight: FontWeight.bold))),
                DropdownMenuItem(value: 'contacted', child: Text("Contacted", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                DropdownMenuItem(value: 'qualified', child: Text("Qualified", style: TextStyle(color: goldColor, fontSize: 12, fontWeight: FontWeight.bold))),
                DropdownMenuItem(value: 'won', child: Text("Won", style: TextStyle(color: Color(0xFF4EBA7A), fontSize: 12, fontWeight: FontWeight.bold))),
                DropdownMenuItem(value: 'closed', child: Text("Closed", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold))),
              ],
              onChanged: (val) {
                if (val != null) {
                  onStatusChanged(val);
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0C1914),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: goldColor.withValues(alpha: 0.28), width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      cleanType.toUpperCase(),
                      style: const TextStyle(color: Color(0xFF091410), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                    ),
                  ),
                  const Spacer(),
                  if (lead.budget != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                      child: Text(
                        AppFormatters.formatCurrency(lead.budget!),
                        style: const TextStyle(color: goldColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                lead.name,
                style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 14),
              InquiryDetailsContactBox(lead: lead, cleanType: cleanType),
              const SizedBox(height: 14),
              InquiryDetailsMetaSection(lead: lead, cleanType: cleanType),
              const SizedBox(height: 18),
              _buildStatusPicker(context),
            ],
          ),
        ),
      ),
    );
  }
}
