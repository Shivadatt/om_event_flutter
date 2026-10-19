import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/config/feature_flags.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../domain/entities/quotation.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../widgets/reusable/version_comparison_sheet.dart';
import 'quotes/digital_consent_dialog.dart';
import 'quotes/proposal_financial_card.dart';
import 'quotes/proposal_summary_cards.dart';
import 'quotes/quotation_item_card.dart';
import 'quotes/quotes_chat_section.dart';
import 'quotes/quotes_timeline_section.dart';
import 'quotes/quotes_view_helpers.dart';

/// Redesigned Design Proposal (Quotations) page matching Option 2 Modern Card Style.
/// Expands flexibly across the Client Lounge viewport on desktop, tablet, and mobile.
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

  void _handleAccept(BuildContext context, Quotation activeQuote) {
    showDialog(
      context: context,
      builder: (dialogCtx) => DigitalConsentDialog(
        activeQuote: activeQuote,
        onAccept: (signature) {
          widget.controller.acceptQuotation(activeQuote.id);
        },
      ),
    );
  }

  void _handleDecline(BuildContext context, Quotation activeQuote) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF171411),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x33D4AF37)),
        ),
        title: const Text("Decline Proposal", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to decline this curation proposal?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC95C5C)),
            onPressed: () {
              widget.controller.rejectQuotation(activeQuote.id);
              Get.back();
            },
            child: const Text("CONFIRM DECLINE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleDownloadPdf(Quotation quote) {
    if (quote.pdfUrl.isNotEmpty) {
      Get.snackbar(
        "Contract PDF",
        "Accessing contract ${quote.quotationNumber}...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF14201A),
        colorText: const Color(0xFFD4AF37),
      );
    } else {
      Get.snackbar(
        "Contract PDF",
        "Contract PDF is currently being finalized by studio manager.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF14201A),
        colorText: const Color(0xFFD4AF37),
      );
    }
  }

  void _handleShare(Quotation quote) {
    Clipboard.setData(
      ClipboardData(text: "https://omevents.com/proposals/${quote.quotationNumber}"),
    );
    Get.snackbar(
      "Proposal Link Copied",
      "Share link for proposal ${quote.quotationNumber} copied to clipboard.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF14201A),
      colorText: const Color(0xFFD4AF37),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final bool isDesktop = availableWidth >= 1024;
        final bool isTablet = availableWidth >= 600 && availableWidth < 1024;
        final bool isMobile = availableWidth < 600;

        // Content padding adapts smoothly from desktop to narrow mobile
        final double horizontalPadding = isDesktop ? 32.0 : (isTablet ? 20.0 : 12.0);
        final double verticalPadding = isDesktop ? 24.0 : 16.0;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Obx(() {
            final rawQuotations = widget.controller.rxQuotations;
            if (rawQuotations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.description_outlined, color: Colors.white24, size: 52),
                    const SizedBox(height: 16),
                    Text(
                      "No design proposals received yet.",
                      style: GoogleFonts.italiana(fontSize: 22, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Once our curation coordinators prepare your event concept, it will appear here.",
                      style: AppTheme.sansBody(fontSize: 12, color: Colors.white38),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final quotations = List<Quotation>.from(rawQuotations)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (rxSelectedQuoteId.value == null && quotations.isNotEmpty) {
              rxSelectedQuoteId.value = quotations.first.id;
            }

            final activeQuote = quotations.firstWhereOrNull((q) => q.id == rxSelectedQuoteId.value) ??
                quotations.first;

            if (activeQuote.status == QuotationStatus.published ||
                activeQuote.status == QuotationStatus.republished) {
              Future.microtask(() =>
                  widget.controller.viewQuotation(activeQuote.id, activeQuote.status.nameStr));
            }

            return SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Top Header Section ─────────────────────────────────────
                    _buildHeader(
                      context,
                      activeQuote,
                      quotations,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: 16),

                    // ── 2. Proposal Metadata Summary Cards ─────────────────────────
                    ProposalSummaryCards(
                      activeQuote: activeQuote,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 20),

                    // ── 3. Direct Contact & Coordination (Proposal Assistance) ───
                    QuotesChatSection(activeQuote: activeQuote),
                    const SizedBox(height: 20),

                    // ── 4. Lower Workspace (Proposal Lifecycle & Scenographies) ────
                    // Side-by-side on desktop, laptop, and tablet (>=640px)
                    // Vertically stacked on mobile (<640px)
                    if (availableWidth >= 640)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column (Proposal Lifecycle + Decline)
                          Expanded(
                            flex: 9,
                            child: QuotesTimelineSection(
                              activeQuote: activeQuote,
                              onDecline: () => _handleDecline(context, activeQuote),
                            ),
                          ),
                          const SizedBox(width: 18),

                          // Right Column (Included Sceneries + Financial Breakdown)
                          Expanded(
                            flex: 11,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildIncludedItemsSection(activeQuote),
                                const SizedBox(height: 18),
                                ProposalFinancialCard(
                                  activeQuote: activeQuote,
                                  onAccept: () => _handleAccept(context, activeQuote),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QuotesTimelineSection(
                            activeQuote: activeQuote,
                            onDecline: () => _handleDecline(context, activeQuote),
                          ),
                          const SizedBox(height: 16),
                          _buildIncludedItemsSection(activeQuote),
                          const SizedBox(height: 16),
                          ProposalFinancialCard(
                            activeQuote: activeQuote,
                            onAccept: () => _handleAccept(context, activeQuote),
                          ),
                        ],
                      ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ── 1. Header Builder ───────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    Quotation activeQuote,
    List<Quotation> quotations, {
    required bool isDesktop,
    required bool isTablet,
    required bool isMobile,
  }) {
    final statusColor = QuotesViewHelpers.getStatusColor(activeQuote.status);
    final expiryDateStr = DateFormat('d MMM yyyy').format(activeQuote.expiryDate).toUpperCase();

    // Render action buttons (Download PDF, Share, More)
    Widget buildActionButtons({bool isCompact = false}) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Download PDF Button
          OutlinedButton.icon(
            icon: Icon(Icons.download_rounded, size: isCompact ? 14 : 16, color: const Color(0xFFE5C378)),
            label: Text(
              "Download PDF",
              style: TextStyle(
                fontSize: isCompact ? 10.5 : 11.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE5C378),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0x44D4AF37)),
              backgroundColor: const Color(0x0DD4AF37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 12 : 16,
                vertical: isCompact ? 10 : 12,
              ),
            ),
            onPressed: () => _handleDownloadPdf(activeQuote),
          ),

          // Share Button
          OutlinedButton.icon(
            icon: Icon(Icons.share_outlined, size: isCompact ? 13 : 15, color: const Color(0xFFE5C378)),
            label: Text(
              "Share",
              style: TextStyle(
                fontSize: isCompact ? 10.5 : 11.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE5C378),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0x44D4AF37)),
              backgroundColor: const Color(0x0DD4AF37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 12 : 16,
                vertical: isCompact ? 10 : 12,
              ),
            ),
            onPressed: () => _handleShare(activeQuote),
          ),

          // Overflow Options
          _buildOverflowMenu(context, activeQuote, isCompact: isCompact),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back to Proposals link
        InkWell(
          onTap: () {
            Get.snackbar(
              "Design Proposals",
              "Viewing active proposal ${activeQuote.quotationNumber}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF14201A),
              colorText: const Color(0xFFD4AF37),
            );
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back, size: 14, color: Color(0xFFD4AF37)),
                const SizedBox(width: 6),
                Text(
                  "Back to Proposals",
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Title and Actions Row (Side-by-side on Desktop/Tablet, Actions below on Mobile)
        if (!isMobile)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: Title + Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Design Proposal",
                      style: GoogleFonts.italiana(
                        fontSize: isDesktop ? 28 : 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Proposal Number Badge
                        Text(
                          activeQuote.quotationNumber,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                            letterSpacing: 0.5,
                          ),
                        ),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            activeQuote.status.nameStr.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // Last Valid Info
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131A15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0x22D4AF37)),
                          ),
                          child: Text(
                            "LAST VALID $expiryDateStr",
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Colors.white54,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Right: Action buttons
              buildActionButtons(isCompact: isTablet),
            ],
          )
        else
          // Mobile Layout: Title + Badges stacked cleanly, then actions below switcher
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Design Proposal",
                style: GoogleFonts.italiana(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    activeQuote.quotationNumber,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      activeQuote.status.nameStr.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131A15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0x22D4AF37)),
                    ),
                    child: Text(
                      "LAST VALID $expiryDateStr",
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

        // Quotations switcher pills (matches reference image tabs)
        if (quotations.isNotEmpty) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quotations.map((quote) {
                final isSelected = quote.id == activeQuote.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => rxSelectedQuoteId.value = quote.id,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE5C378) : const Color(0xFF131A15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFE5C378) : const Color(0x22D4AF37),
                        ),
                      ),
                      child: Text(
                        quote.quotationNumber,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF091210) : Colors.white60,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // On mobile, render action buttons directly below switcher pills as shown in reference
        if (isMobile) ...[
          const SizedBox(height: 12),
          buildActionButtons(isCompact: true),
        ],
      ],
    );
  }

  Widget _buildOverflowMenu(BuildContext context, Quotation activeQuote, {bool isCompact = false}) {
    return PopupMenuButton<String>(
      icon: Container(
        width: isCompact ? 34 : 38,
        height: isCompact ? 34 : 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0x0DD4AF37),
          border: Border.all(color: const Color(0x33D4AF37)),
        ),
        child: Center(
          child: Icon(Icons.more_horiz, color: Colors.white70, size: isCompact ? 16 : 18),
        ),
      ),
      color: const Color(0xFF131A15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x33D4AF37)),
      ),
      onSelected: (val) {
        if (val == 'compare' && activeQuote.versions.isNotEmpty) {
          // TEMP DISABLED - OM EVENTS ADVANCED FEATURE
          // REASON: Not required for current business flow.
          // DO NOT DELETE - Keep for future reactivation.
          if (FeatureFlags.quotationNegotiation) {
            VersionComparisonSheet.show(context, activeQuote);
          }
        } else if (val == 'revision') {
          // TEMP DISABLED - OM EVENTS ADVANCED FEATURE
          // REASON: Not required for current business flow.
          // DO NOT DELETE - Keep for future reactivation.
          if (FeatureFlags.quotationRevisions) {
            widget.onRequestRevision(activeQuote.id);
          }
        } else if (val == 'share') {
          _handleShare(activeQuote);
        }
      },
      itemBuilder: (context) => [
        // TEMP DISABLED - OM EVENTS ADVANCED FEATURE
        // REASON: Not required for current business flow.
        // DO NOT DELETE - Keep for future reactivation.
        if (FeatureFlags.quotationNegotiation && activeQuote.versions.isNotEmpty)
          const PopupMenuItem(
            value: 'compare',
            child: Row(
              children: [
                Icon(Icons.compare_arrows_rounded, color: Color(0xFFD4AF37), size: 16),
                SizedBox(width: 10),
                Text("Compare Revisions", style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        // TEMP DISABLED - OM EVENTS ADVANCED FEATURE
        // REASON: Not required for current business flow.
        // DO NOT DELETE - Keep for future reactivation.
        if (FeatureFlags.quotationRevisions)
          const PopupMenuItem(
            value: 'revision',
            child: Row(
              children: [
                Icon(Icons.edit_note_rounded, color: Color(0xFFD4AF37), size: 16),
                SizedBox(width: 10),
                Text("Request Modification", style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share_outlined, color: Color(0xFFD4AF37), size: 16),
              SizedBox(width: 10),
              Text("Copy Proposal Link", style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ── 2. Included Sceneries & Props Container (Desktop) ────────────────────────
  Widget _buildIncludedItemsSection(Quotation activeQuote) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "INCLUDED SCENOGRAPHIES & PROPS",
                style: AppTheme.sansBody(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "${activeQuote.items.length} ${activeQuote.items.length == 1 ? 'Item' : 'Items'}",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE5C378),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: activeQuote.items.map((it) => QuotationItemCard(item: it)).toList(),
          ),
        ],
      ),
    );
  }
}
