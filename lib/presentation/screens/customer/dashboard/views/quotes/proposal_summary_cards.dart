import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/domain/entities/quotation.dart';

/// Renders the compact summary cards row matching Option 2 Modern Card Style.
class ProposalSummaryCards extends StatelessWidget {
  final Quotation activeQuote;
  final bool isMobile;

  const ProposalSummaryCards({
    super.key,
    required this.activeQuote,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final budgetStr = currencyFmt.format(activeQuote.amount);
    final eventDateStr = DateFormat('d MMM yyyy').format(activeQuote.eventDate);
    final branchStr = activeQuote.location.isNotEmpty ? activeQuote.location : "Kadi";
    final designNote = activeQuote.notes.isNotEmpty
        ? activeQuote.notes
        : "Package: Luxury Grande (LUXURY)";
    final coordinator = (activeQuote.publishedBy?.isNotEmpty == true)
        ? activeQuote.publishedBy!
        : "Senior Event Curation Designer";

    if (isMobile) {
      return Column(
        children: [
          _buildCompactStat(Icons.payments_outlined, "Budget Valuation", budgetStr),
          const SizedBox(height: 10),
          _buildCompactStat(Icons.calendar_today_outlined, "Target Event Date", eventDateStr),
          const SizedBox(height: 10),
          _buildCompactStat(Icons.business_outlined, "Studio Branch", branchStr),
          const SizedBox(height: 10),
          _buildNoteCard(designNote),
          const SizedBox(height: 10),
          _buildCoordinatorCard(coordinator),
        ],
      );
    }

    return Column(
      children: [
        // Row 1: 3 Stat Cards
        Row(
          children: [
            Expanded(child: _buildCompactStat(Icons.collections_outlined, "Budget Valuation", budgetStr)),
            const SizedBox(width: 14),
            Expanded(child: _buildCompactStat(Icons.calendar_today_outlined, "Target Event Date", eventDateStr)),
            const SizedBox(width: 14),
            Expanded(child: _buildCompactStat(Icons.storefront_outlined, "Studio Branch", branchStr)),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Design Note & Coordinator Cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _buildNoteCard(designNote)),
            const SizedBox(width: 14),
            Expanded(flex: 4, child: _buildCoordinatorCard(coordinator)),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactStat(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131A15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22D4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF18231C),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x33D4AF37)),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Colors.white38,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: AppTheme.sansBody(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String note) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131A15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22D4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF18231C),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x33D4AF37)),
            ),
            child: const Icon(Icons.description_outlined, color: Color(0xFFD4AF37), size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Studio Design Note",
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Colors.white38,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  note,
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE5C378),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatorCard(String coordinatorName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131A15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22D4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF18231C),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
            ),
            child: const Center(
              child: Icon(Icons.person_outline_rounded, color: Color(0xFFD4AF37), size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Coordinator",
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Colors.white38,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  coordinatorName,
                  style: AppTheme.sansBody(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
