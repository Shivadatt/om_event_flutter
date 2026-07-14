import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../domain/entities/quotation.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../widgets/reusable/version_comparison_sheet.dart';
import 'quotes/quotation_item_card.dart';
import 'quotes/quotes_chat_section.dart';
import 'quotes/quotes_timeline_section.dart';
import 'quotes/quotes_actions_panel.dart';
import 'quotes/quotes_view_helpers.dart';

/// Quotations management tab view for customers.
class QuotesView extends StatefulWidget {
  final CustomerDashboardController controller;
  final Function(String) onRequestRevision;

  const QuotesView({
    super.key,
    required this.controller,
    required this.onRequestRevision,
  });

  @override
  State<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends State<QuotesView> {
  final rxSelectedQuoteId = RxnString();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 800;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Obx(() {
        final rawQuotations = widget.controller.rxQuotations;
        if (rawQuotations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description_outlined, color: Colors.white24, size: 48),
                const SizedBox(height: 16),
                Text("No quotations received yet.", style: AppTheme.sansBody(fontSize: 14, color: Colors.white54)),
              ],
            ),
          );
        }

        final quotations = List<Quotation>.from(rawQuotations)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (rxSelectedQuoteId.value == null && quotations.isNotEmpty) {
          rxSelectedQuoteId.value = quotations.first.id;
        }

        final activeQuote = quotations.firstWhereOrNull((q) => q.id == rxSelectedQuoteId.value) ?? quotations.first;
        final statusColor = QuotesViewHelpers.getStatusColor(activeQuote.status);

        if (activeQuote.status == QuotationStatus.published || activeQuote.status == QuotationStatus.republished) {
          Future.microtask(() => widget.controller.viewQuotation(activeQuote.id, activeQuote.status.nameStr));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SAVED OFFERS", style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5)),
                      const SizedBox(height: 6),
                      Text("Design Proposals", style: GoogleFonts.italiana(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
                    ],
                  ),
                  if (quotations.length > 1)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x1AD4AF37)),
                      ),
                      child: Row(
                        children: quotations.map((quote) {
                          final isSelected = quote.id == activeQuote.id;
                          return GestureDetector(
                            onTap: () => rxSelectedQuoteId.value = quote.id,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                quote.quotationNumber,
                                style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF091210) : Colors.white60),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1D1916), Color(0xFF0E0B0A)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35), width: 1.5),
                    boxShadow: const [BoxShadow(color: Color(0xCC000000), blurRadius: 30, offset: Offset(0, 15))],
                  ),
                  padding: EdgeInsets.all(isDesktop ? 40 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0x1AD4AF37),
                                  border: Border.all(color: const Color(0x22D4AF37)),
                                ),
                                child: const Icon(Icons.spa_outlined, color: Color(0xFFD4AF37), size: 22),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(activeQuote.quotationNumber, style: GoogleFonts.italiana(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                  const SizedBox(height: 3),
                                  Text("VALUATION PROPOSAL CONTRACT", style: AppTheme.sansBody(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5)),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(activeQuote.status.nameStr.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              ),
                              const SizedBox(height: 6),
                              Text("VALID UNTIL: ${activeQuote.expiryDate.toLocal().toString().split(' ')[0]}", style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 0.5)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0x1AD4AF37), height: 1),
                      const SizedBox(height: 24),
                      Text("STUDIO DESIGN NOTE", style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Text(
                        activeQuote.notes.isNotEmpty ? activeQuote.notes : QuotesViewHelpers.getUniqueProposalNote(activeQuote.quotationNumber),
                        style: AppTheme.sansBody(fontSize: 14, color: Colors.white70, height: 1.5),
                      ),
                      if (activeQuote.adminMessage != null && activeQuote.adminMessage!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0x1AD4AF37),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x33D4AF37)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("MESSAGE FROM STUDIO", style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0)),
                              const SizedBox(height: 8),
                              Text(activeQuote.adminMessage!, style: AppTheme.sansBody(fontSize: 13, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                      QuotesChatSection(activeQuote: activeQuote),
                      if (activeQuote.timeline.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("PROPOSAL LIFECYCLE", style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5)),
                            if (activeQuote.versions.isNotEmpty)
                              TextButton.icon(
                                icon: const Icon(Icons.compare_arrows_rounded, size: 14, color: Color(0xFFD4AF37)),
                                label: Text("Compare Revisions", style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37))),
                                onPressed: () => VersionComparisonSheet.show(context, activeQuote),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        QuotesTimelineSection(activeQuote: activeQuote),
                      ],
                      const SizedBox(height: 32),
                      Text("INCLUDED SCENOGRAPHIES & PROPS", style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0)),
                      const SizedBox(height: 16),
                      if (isDesktop && activeQuote.items.length > 1)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: activeQuote.items.length,
                          itemBuilder: (context, idx) => QuotationItemCard(item: activeQuote.items[idx]),
                        )
                      else
                        Column(
                          children: activeQuote.items.map((item) => QuotationItemCard(item: item)).toList(),
                        ),
                      const SizedBox(height: 32),
                      Text("PROPOSAL FINANCIAL BREAKDOWN", style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x0AD4AF37)),
                        ),
                        child: Column(
                          children: [
                            QuotesViewHelpers.buildReceiptRow("Concepts Subtotal", "₹${activeQuote.amount.toStringAsFixed(0)}"),
                            const SizedBox(height: 12),
                            QuotesViewHelpers.buildReceiptRow("Curation & Consultation Fee", "COMPLIMENTARY"),
                            const SizedBox(height: 12),
                            QuotesViewHelpers.buildReceiptRow("Design Setup & Execution", "INCLUDED"),
                            const Divider(color: Color(0x1AD4AF37), height: 32),
                            QuotesViewHelpers.buildReceiptRow("Total Proposed Valuation", "₹${activeQuote.amount.toStringAsFixed(0)}", isTotal: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      const Divider(color: Color(0x1AD4AF37), height: 1),
                      const SizedBox(height: 32),
                      QuotesActionsPanel(activeQuote: activeQuote, controller: widget.controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
