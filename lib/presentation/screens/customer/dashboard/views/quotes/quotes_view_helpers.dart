import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/domain/entities/quotation.dart';

/// Helper utilities for styling and content generation inside customer quotes view.
class QuotesViewHelpers {
  /// Generates a curator text based on the quote number hash.
  static String getUniqueProposalNote(String quoteNumber) {
    final hash = quoteNumber.hashCode;
    final curators = ["Anya Mehta", "Vikram Shah", "Rahul Sharma", "Pooja Patel"];
    final curator = curators[hash.abs() % curators.length];
    final styles = [
      "bespoke candlelight styling, warm amber lighting layers, and premium satin drapes.",
      "delicate floral runner accents, cascading crystal installations, and velvet seating overlays.",
      "grand entrance floral arches, custom ebonized stage setups, and ambient gold spotlighting.",
      "modern minimalist geometric backdrops, pampas grass installations, and warm fairy light backdrops."
    ];
    final style = styles[hash.abs() % styles.length];
    return "Exclusive design proposal prepared by Senior Curator $curator. This bespoke concept has been custom-tailored for your event, featuring $style All logistics, site curation, and teardown management are fully integrated.";
  }

  /// Maps QuotationStatus to corresponding design colors.
  static Color getStatusColor(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.acceptedByClient:
      case QuotationStatus.bookingConfirmed:
      case QuotationStatus.completed:
        return const Color(0xFF7CA68E);
      case QuotationStatus.published:
      case QuotationStatus.republished:
      case QuotationStatus.viewed:
      case QuotationStatus.revisionRequested:
      case QuotationStatus.underRevision:
        return const Color(0xFFE6C98D);
      case QuotationStatus.rejectedByClient:
      case QuotationStatus.cancelled:
      case QuotationStatus.expired:
        return const Color(0xFFC95C5C);
      case QuotationStatus.inProgress:
        return const Color(0xFF7CB6D6);
      case QuotationStatus.draft:
        return Colors.white54;
      case QuotationStatus.archived:
        return Colors.white24;
    }
  }

  /// Renders a receipt billing line item row.
  static Widget buildReceiptRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: isTotal ? 13 : 11,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.white : Colors.white54,
          ),
        ),
        Text(
          value,
          style: isTotal
              ? GoogleFonts.italiana(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37))
              : AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: value == "COMPLIMENTARY" || value == "INCLUDED" ? const Color(0xFF7CA68E) : Colors.white70,
                ),
        ),
      ],
    );
  }
}
