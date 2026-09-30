import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/domain/entities/quotation.dart';

/// Renders the financial breakdown card and primary Accept & Book action button
/// matching Option 2 Modern Card Style.
class ProposalFinancialCard extends StatelessWidget {
  final Quotation activeQuote;
  final VoidCallback onAccept;

  const ProposalFinancialCard({
    super.key,
    required this.activeQuote,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final subtotalStr = currencyFmt.format(
      activeQuote.subtotal > 0 ? activeQuote.subtotal : activeQuote.amount,
    );
    final totalStr = currencyFmt.format(activeQuote.amount);
    final status = activeQuote.status;
    final isConfirmed = status == QuotationStatus.acceptedByClient ||
        status == QuotationStatus.bookingConfirmed ||
        status == QuotationStatus.completed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111713),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x22D4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "FINANCIAL BREAKDOWN",
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 18),

          _buildRow("Concepts Subtotal", subtotalStr),
          const SizedBox(height: 10),
          _buildRow("Curation & Consultation Fee", "Complimentary", isComplimentary: true),
          const SizedBox(height: 10),
          _buildRow("Design Setup & Execution", "Included", isComplimentary: true),
          if (activeQuote.discount > 0) ...[
            const SizedBox(height: 10),
            _buildRow("Promotional Discount", "-₹${activeQuote.discount.toStringAsFixed(0)}", isDiscount: true),
          ],
          const SizedBox(height: 14),
          const Divider(color: Color(0x1AD4AF37), height: 1),
          const SizedBox(height: 14),

          // Total Proposed Valuation Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Proposed Valuation",
                style: AppTheme.sansBody(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                totalStr,
                style: GoogleFonts.italiana(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Primary Accept & Book Proposal Button
          if (!isConfirmed)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5C378),
                foregroundColor: const Color(0xFF091210),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shadowColor: const Color(0x33D4AF37),
              ),
              onPressed: onAccept,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ACCEPT & BOOK PROPOSAL",
                    style: AppTheme.sansBody(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: const Color(0xFF091210),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF091210)),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF132219),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7CA68E).withValues(alpha: 0.6)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF7CA68E), size: 18),
                  SizedBox(width: 8),
                  Text(
                    "PROPOSAL ACCEPTED & CONFIRMED",
                    style: TextStyle(
                      color: Color(0xFF7CA68E),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isComplimentary = false, bool isDiscount = false}) {
    Color valueColor = Colors.white70;
    if (isComplimentary) valueColor = const Color(0xFF7CA68E);
    if (isDiscount) valueColor = const Color(0xFFC95C5C);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: Colors.white60),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isComplimentary ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
