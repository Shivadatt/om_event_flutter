import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InquiryEmptyState extends StatelessWidget {
  final VoidCallback onResetFilters;
  static const Color goldColor = Color(0xFFECC24A);

  const InquiryEmptyState({
    super.key,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1914),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldColor.withValues(alpha: 0.20), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: goldColor.withValues(alpha: 0.35)),
                ),
                child: const Icon(Icons.search_off_rounded, color: goldColor, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                "No Inquiries Found",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "No inquiries match your current status filter or search keyword.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onResetFilters,
                icon: const Icon(Icons.refresh_rounded, size: 14, color: goldColor),
                label: const Text(
                  "Reset Filters",
                  style: TextStyle(color: goldColor, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: goldColor.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
