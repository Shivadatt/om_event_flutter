import 'package:flutter/material.dart';
import 'package:om_event/domain/entities/quotation.dart';
import 'package:om_event/presentation/controllers/customer_dashboard_controller.dart';
import 'proposal_summary_cards.dart';
import 'quotes_chat_section.dart';
import 'quotation_item_card.dart';
import 'proposal_financial_card.dart';
import 'quotes_timeline_section.dart';

/// Renders the mobile accordion sections matching the reference design.
class ProposalMobileAccordion extends StatefulWidget {
  final Quotation activeQuote;
  final CustomerDashboardController controller;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ProposalMobileAccordion({
    super.key,
    required this.activeQuote,
    required this.controller,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<ProposalMobileAccordion> createState() => _ProposalMobileAccordionState();
}

class _ProposalMobileAccordionState extends State<ProposalMobileAccordion> {
  // Expansion states for each section
  bool _eventDetailsExpanded = true;
  bool _discussionExpanded = false;
  bool _itemsExpanded = true;
  bool _financialExpanded = true;
  bool _lifecycleExpanded = false;

  @override
  Widget build(BuildContext context) {
    final activeQuote = widget.activeQuote;
    final itemsCount = activeQuote.items.length;
    final status = activeQuote.status;
    final isConfirmed = status == QuotationStatus.acceptedByClient ||
        status == QuotationStatus.bookingConfirmed ||
        status == QuotationStatus.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Event Details Accordion
        _buildAccordionItem(
          title: "Event Details",
          icon: Icons.calendar_month_outlined,
          isExpanded: _eventDetailsExpanded,
          onToggle: () => setState(() => _eventDetailsExpanded = !_eventDetailsExpanded),
          child: ProposalSummaryCards(activeQuote: activeQuote, isMobile: true),
        ),
        const SizedBox(height: 12),

        // 2. Discussion Accordion
        _buildAccordionItem(
          title: "Discussion",
          icon: Icons.chat_bubble_outline_rounded,
          isExpanded: _discussionExpanded,
          onToggle: () => setState(() => _discussionExpanded = !_discussionExpanded),
          child: QuotesChatSection(activeQuote: activeQuote),
        ),
        const SizedBox(height: 12),

        // 3. Included Items Accordion
        _buildAccordionItem(
          title: "Included Items ($itemsCount)",
          icon: Icons.inventory_2_outlined,
          isExpanded: _itemsExpanded,
          onToggle: () => setState(() => _itemsExpanded = !_itemsExpanded),
          child: Column(
            children: activeQuote.items.map((item) => QuotationItemCard(item: item)).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // 4. Financial Breakdown Accordion
        _buildAccordionItem(
          title: "Financial Breakdown",
          icon: Icons.receipt_long_outlined,
          isExpanded: _financialExpanded,
          onToggle: () => setState(() => _financialExpanded = !_financialExpanded),
          child: ProposalFinancialCard(
            activeQuote: activeQuote,
            onAccept: widget.onAccept,
          ),
        ),
        const SizedBox(height: 12),

        // 5. Proposal Lifecycle Accordion
        _buildAccordionItem(
          title: "Proposal Lifecycle",
          icon: Icons.timeline_outlined,
          isExpanded: _lifecycleExpanded,
          onToggle: () => setState(() => _lifecycleExpanded = !_lifecycleExpanded),
          child: QuotesTimelineSection(
            activeQuote: activeQuote,
            onDecline: widget.onDecline,
          ),
        ),
        const SizedBox(height: 20),

        // Mobile Sticky Actions
        if (!isConfirmed) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5C378),
              foregroundColor: const Color(0xFF091210),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: widget.onAccept,
            child: const Text(
              "Accept & Book",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC95C5C),
              side: const BorderSide(color: Color(0x44C95C5C)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: widget.onDecline,
            child: const Text(
              "Decline",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccordionItem({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111713),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22D4AF37), width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFFD4AF37), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFD4AF37),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: child,
            ),
        ],
      ),
    );
  }
}
