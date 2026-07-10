import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_collections.dart';
import '../../../../../domain/entities/quotation.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../core/utils/formatters.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../controllers/quotation_collaboration_controller.dart';
import '../../../../../domain/entities/quotation_message.dart';
import '../../../../widgets/reusable/version_comparison_sheet.dart';

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

        // Sort quotations: latest created date on top
        final quotations = List<Quotation>.from(rawQuotations)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Set default selected quote if null
        if (rxSelectedQuoteId.value == null && quotations.isNotEmpty) {
          rxSelectedQuoteId.value = quotations.first.id;
        }

        final activeQuote = quotations.firstWhereOrNull((q) => q.id == rxSelectedQuoteId.value) ?? quotations.first;
        final statusColor = _getStatusColor(activeQuote.status);

        // Automatically trigger viewed status update if opened in client portal
        if (activeQuote.status == QuotationStatus.published || activeQuote.status == QuotationStatus.republished) {
          Future.microtask(() => widget.controller.viewQuotation(activeQuote.id, activeQuote.status.nameStr));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header & Tab Navigation Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SAVED OFFERS",
                        style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Design Proposals",
                        style: GoogleFonts.italiana(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  // Segmented Tabs for proposals selection
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
                            onTap: () {
                              rxSelectedQuoteId.value = quote.id;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                quote.quotationNumber,
                                style: AppTheme.sansBody(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? const Color(0xFF091210) : Colors.white60,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Centered Magazine Curation Booklet Card
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1D1916), // Dark warm bronze
                        Color(0xFF0E0B0A), // Rich ebonized matte black
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0xCC000000), blurRadius: 30, offset: Offset(0, 15)),
                    ],
                  ),
                  padding: EdgeInsets.all(isDesktop ? 40 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document Top Banner
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
                                  Text(
                                    activeQuote.quotationNumber,
                                    style: GoogleFonts.italiana(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "VALUATION PROPOSAL CONTRACT",
                                    style: AppTheme.sansBody(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
                                  ),
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
                              const SizedBox(height: 6),
                              Text(
                                "VALID UNTIL: ${activeQuote.expiryDate.toLocal().toString().split(' ')[0]}",
                                style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0x1AD4AF37), height: 1),
                      const SizedBox(height: 24),

                      // Curation Note
                      Text(
                        "STUDIO DESIGN NOTE",
                        style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activeQuote.notes.isNotEmpty ? activeQuote.notes : _getUniqueProposalNote(activeQuote.quotationNumber),
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
                              Text(
                                "MESSAGE FROM STUDIO",
                                style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                activeQuote.adminMessage!,
                                style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      _buildChatSection(activeQuote),
                      if (activeQuote.timeline.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "PROPOSAL LIFECYCLE",
                              style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
                            ),
                            if (activeQuote.versions.isNotEmpty)
                              TextButton.icon(
                                icon: const Icon(Icons.compare_arrows_rounded, size: 14, color: Color(0xFFD4AF37)),
                                label: Text(
                                  "Compare Revisions",
                                  style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37)),
                                ),
                                onPressed: () => VersionComparisonSheet.show(context, activeQuote),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(activeQuote.timeline.length, (idx) {
                              final event = activeQuote.timeline[idx];
                              final isLast = idx == activeQuote.timeline.length - 1;
                              
                              Color dotColor = const Color(0xFFD4AF37);
                              IconData dotIcon = Icons.radio_button_checked_rounded;

                              if (event.status == QuotationStatus.draft) {
                                dotColor = Colors.white30;
                                dotIcon = Icons.note_add_outlined;
                              } else if (event.status == QuotationStatus.published) {
                                dotColor = const Color(0xFFD4AF37);
                                dotIcon = Icons.send_rounded;
                              } else if (event.status == QuotationStatus.viewed) {
                                dotColor = const Color(0xFFD4AF37);
                                dotIcon = Icons.visibility_outlined;
                              } else if (event.status == QuotationStatus.revisionRequested) {
                                dotColor = const Color(0xFFC95C5C);
                                dotIcon = Icons.edit_note_rounded;
                              } else if (event.status == QuotationStatus.underRevision) {
                                dotColor = const Color(0xFFE6C98D);
                                dotIcon = Icons.build_rounded;
                              } else if (event.status == QuotationStatus.republished) {
                                dotColor = const Color(0xFFD4AF37);
                                dotIcon = Icons.published_with_changes_rounded;
                              } else if (event.status == QuotationStatus.acceptedByClient) {
                                dotColor = const Color(0xFF4CAF50);
                                dotIcon = Icons.check_circle_rounded;
                              } else if (event.status == QuotationStatus.bookingConfirmed) {
                                dotColor = const Color(0xFF4CAF50);
                                dotIcon = Icons.celebration_rounded;
                              } else if (event.status == QuotationStatus.completed) {
                                dotColor = const Color(0xFF4CAF50);
                                dotIcon = Icons.done_all_rounded;
                              } else if (event.status == QuotationStatus.cancelled) {
                                dotColor = const Color(0xFFC95C5C);
                                dotIcon = Icons.cancel_rounded;
                              } else if (event.status == QuotationStatus.expired) {
                                dotColor = const Color(0xFFC95C5C);
                                dotIcon = Icons.timer_off_rounded;
                              } else if (event.status == QuotationStatus.archived) {
                                dotColor = Colors.white38;
                                dotIcon = Icons.archive_rounded;
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: dotColor.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: dotColor.withValues(alpha: 0.8), width: 1.5),
                                        ),
                                        child: Icon(dotIcon, size: 14, color: dotColor),
                                      ),
                                      if (!isLast)
                                        Container(
                                          width: 1.5,
                                          height: 40,
                                          color: Colors.white.withValues(alpha: 0.08),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              event.title,
                                              style: AppTheme.sansBody(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              AppFormatters.formatShortDate(event.timestamp),
                                              style: AppTheme.sansBody(
                                                fontSize: 9,
                                                color: Colors.white38,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          event.description,
                                          style: AppTheme.sansBody(
                                            fontSize: 11,
                                            color: Colors.white60,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Included items list formatted in grid if multiple on desktop
                      Text(
                        "INCLUDED SCENOGRAPHIES & PROPS",
                        style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
                      ),
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

                      // Valuation receipt breakdown
                      Text(
                        "PROPOSAL FINANCIAL BREAKDOWN",
                        style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
                      ),
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
                            _buildReceiptRow("Concepts Subtotal", "₹${activeQuote.amount.toStringAsFixed(0)}"),
                            const SizedBox(height: 12),
                            _buildReceiptRow("Curation & Consultation Fee", "COMPLIMENTARY"),
                            const SizedBox(height: 12),
                            _buildReceiptRow("Design Setup & Execution", "INCLUDED"),
                            const Divider(color: Color(0x1AD4AF37), height: 32),
                            _buildReceiptRow(
                              "Total Proposed Valuation",
                              "₹${activeQuote.amount.toStringAsFixed(0)}",
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      const Divider(color: Color(0x1AD4AF37), height: 1),
                      const SizedBox(height: 32),

                      // Stacked Actions Panel
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (activeQuote.status == QuotationStatus.published ||
                              activeQuote.status == QuotationStatus.republished ||
                              activeQuote.status == QuotationStatus.viewed) ...[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: const Color(0xFF091210),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                textStyle: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                elevation: 4,
                                shadowColor: const Color(0x33D4AF37),
                              ),
                              onPressed: () {
                                _showDigitalConsentDialog(activeQuote);
                              },
                              child: const Text("ACCEPT & BOOK PROPOSAL"),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Wrap(
                                spacing: 16,
                                runSpacing: 12,
                                children: [
                                  if (activeQuote.status == QuotationStatus.published ||
                                      activeQuote.status == QuotationStatus.republished ||
                                      activeQuote.status == QuotationStatus.viewed)
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.edit_note, size: 18, color: Color(0xFFD4AF37)),
                                      label: const Text("REQUEST REVISION"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFD4AF37),
                                        side: const BorderSide(color: Color(0x33D4AF37)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                                        textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                      ),
                                      onPressed: () {
                                        widget.onRequestRevision(activeQuote.id);
                                      },
                                    ),
                                  if (activeQuote.status == QuotationStatus.published ||
                                      activeQuote.status == QuotationStatus.republished ||
                                      activeQuote.status == QuotationStatus.viewed)
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFC95C5C),
                                        side: const BorderSide(color: Color(0x66C95C5C)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                                        textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                      ),
                                      onPressed: () {
                                        _showDeclineConfirmationDialog(activeQuote.id);
                                      },
                                      child: const Text("DECLINE PROPOSAL"),
                                    ),
                                ],
                              ),
                              if (activeQuote.pdfUrl.isNotEmpty)
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.download, size: 18, color: Color(0xFFD4AF37)),
                                  label: const Text("DOWNLOAD CONTRACT PDF"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFD4AF37),
                                    side: const BorderSide(color: Color(0x33D4AF37)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                                    textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                  onPressed: () {
                                    Get.snackbar(
                                      "Download Triggered",
                                      "Accessing secure storage bucket...",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFF171411),
                                      colorText: const Color(0xFFD4AF37),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildReceiptRow(String label, String value, {bool isTotal = false}) {
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
              ? GoogleFonts.italiana(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                )
              : AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: value == "COMPLIMENTARY" || value == "INCLUDED" ? const Color(0xFF7CA68E) : Colors.white70,
                ),
        ),
      ],
    );
  }

  String _getUniqueProposalNote(String quoteNumber) {
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

    return "Exclusive design proposal prepared by Senior Curator $curator. "
        "This bespoke concept has been custom-tailored for your event, featuring $style "
        "All logistics, site curation, and teardown management are fully integrated.";
  }

  void _showDeclineConfirmationDialog(String quoteId) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1D1916),
                Color(0xFF0F0D0C),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFC95C5C).withValues(alpha: 0.35), width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFC95C5C).withValues(alpha: 0.1),
                      border: Border.all(color: const Color(0xFFC95C5C).withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFC95C5C), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    "DECLINE PROPOSAL",
                    style: GoogleFonts.italiana(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Are you sure you want to decline this event curation proposal? This action will archive the design contract and notify your coordinators.",
                style: AppTheme.sansBody(fontSize: 13, color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "KEEP PROPOSAL",
                      style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1.0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC95C5C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
                      elevation: 4,
                    ),
                    onPressed: () {
                      widget.controller.rejectQuotation(quoteId);
                      Get.back();
                    },
                    child: const Text("CONFIRM DECLINE"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(QuotationStatus status) {
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

  Widget _buildChatSection(Quotation activeQuote) {
    final chatController = Get.put(
      QuotationCollaborationController(
        quotationId: activeQuote.id,
        senderId: activeQuote.customerId.isNotEmpty ? activeQuote.customerId : 'client_user',
        senderName: activeQuote.customerName.isNotEmpty ? activeQuote.customerName : 'Client',
        senderRole: 'client',
      ),
      tag: activeQuote.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          "COLLABORATION & DISCUSSIONS",
          style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  final messages = chatController.rxMessages;
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white24, size: 36),
                          const SizedBox(height: 12),
                          Text(
                            "Start a discussion with our design coordinators.",
                            style: AppTheme.sansBody(fontSize: 11, color: Colors.white30),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: chatController.scrollController,
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, idx) {
                      final msg = messages[idx];
                      final isMe = msg.senderRole == 'client';
                      return _buildMessageBubble(msg, isMe);
                    },
                  );
                }),
              ),
              Obx(() {
                if (chatController.isUploading.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.black26,
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFD4AF37)),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Uploading attachment...",
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file_rounded, color: Color(0xFFD4AF37), size: 20),
                      onPressed: () => chatController.pickAndUploadAttachment(),
                      tooltip: "Upload Attachment",
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: chatController.textController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Ask a question, request modifications...",
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                          filled: true,
                          fillColor: Colors.black12,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => chatController.sendTextMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(() {
                      return chatController.isSending.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFD4AF37)),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send_rounded, color: Color(0xFFD4AF37), size: 20),
                              onPressed: () => chatController.sendTextMessage(),
                            );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(QuotationMessage msg, bool isMe) {
    if (msg.type == 'system' || msg.type == 'priceChange' || msg.type == 'revision') {
      Color bannerColor = const Color(0xFFD4AF37).withValues(alpha: 0.1);
      Color textColor = const Color(0xFFD4AF37);
      IconData icon = Icons.info_outline_rounded;

      if (msg.type == 'priceChange') {
        bannerColor = const Color(0xFF4CAF50).withValues(alpha: 0.1);
        textColor = const Color(0xFF81C784);
        icon = Icons.monetization_on_outlined;
      } else if (msg.type == 'revision') {
        bannerColor = const Color(0xFFE57373).withValues(alpha: 0.1);
        textColor = const Color(0xFFEF9A9A);
        icon = Icons.published_with_changes_rounded;
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bannerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg.content,
                style: TextStyle(color: textColor.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    final aligns = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe 
        ? const Color(0xFFD4AF37).withValues(alpha: 0.15) 
        : Colors.white.withValues(alpha: 0.05);
    final borderColor = isMe 
        ? const Color(0xFFD4AF37).withValues(alpha: 0.3) 
        : Colors.white.withValues(alpha: 0.1);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: aligns,
        children: [
          GestureDetector(
            onTap: (msg.type == 'image' || msg.type == 'pdf' || msg.type == 'document')
                ? () async {
                    try {
                      final uri = Uri.parse(msg.content);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    } catch (_) {}
                  }
                : null,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      msg.senderName.toUpperCase(),
                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  if (!isMe) const SizedBox(height: 4),
                  if (msg.type == 'text')
                    Text(msg.content, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                  if (msg.type == 'image')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(msg.content, fit: BoxFit.cover),
                    ),
                  if (msg.type == 'pdf' || msg.type == 'document')
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          msg.type == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
                          color: const Color(0xFFD4AF37),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            msg.attachments.isNotEmpty ? msg.attachments.first.fileName : "View Attachment",
                            style: const TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.white24, fontSize: 9),
                ),
                if (isMe) const SizedBox(width: 4),
                if (isMe)
                  Icon(
                    msg.isReadByAdmin ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 11,
                    color: msg.isReadByAdmin ? const Color(0xFFD4AF37) : Colors.white24,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDigitalConsentDialog(Quotation activeQuote) {
    bool isAgreed = false;
    final nameCtrl = TextEditingController(text: activeQuote.customerName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF171411),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0x33D4AF37)),
              ),
              title: Row(
                children: [
                  const Icon(Icons.gavel_outlined, color: Color(0xFFD4AF37), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "Digital Consent & Confirmation",
                    style: AppTheme.serifHeader(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Please review and sign the legal confirmation for this proposal.",
                        style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildConsentDetailRow("Quotation No", activeQuote.publicId),
                            _buildConsentDetailRow("Version", "v${activeQuote.version}"),
                            _buildConsentDetailRow("Grand Total", AppFormatters.formatCurrency(activeQuote.grandTotal)),
                            _buildConsentDetailRow("Validity Until", AppFormatters.formatShortDate(activeQuote.createdAt.add(const Duration(days: 7)))),
                            _buildConsentDetailRow("Customer Name", activeQuote.customerName),
                            _buildConsentDetailRow("Event Date", AppFormatters.formatShortDate(activeQuote.eventDate)),
                            _buildConsentDetailRow("Event Location", activeQuote.location),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "LEGAL AGREEMENT",
                        style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\"I confirm that I have reviewed this quotation and agree with the pricing, services and terms.\"",
                        style: AppTheme.sansBody(fontSize: 12, color: Colors.white).copyWith(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: "SIGNATORY FULL NAME",
                          labelStyle: AppTheme.sansBody(fontSize: 11, color: const Color(0xFFD4AF37)),
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Full name signature is required.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: isAgreed,
                              activeColor: const Color(0xFFD4AF37),
                              checkColor: Colors.black,
                              side: const BorderSide(color: Colors.white54),
                              onChanged: (val) {
                                setDialogState(() {
                                  isAgreed = val ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "I explicitly agree to sign this contract with legal digital consent.",
                              style: AppTheme.sansBody(fontSize: 11, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.white54, fontSize: 12)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF091210),
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: Colors.white30,
                  ),
                  onPressed: !isAgreed
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() == true) {
                            Navigator.pop(dialogCtx);
                            
                            // Detect Device Info
                            String devInfo = _getDeviceInfo();

                            await widget.controller.acceptQuotationWithConsent(
                              activeQuote.id,
                              acceptedBy: nameCtrl.text.trim(),
                              acceptedDevice: devInfo,
                              acceptedIp: "127.0.0.1",
                              consentTextVersion: "v1",
                              acceptedAmount: activeQuote.grandTotal,
                              acceptedVersion: activeQuote.version,
                            );
                          }
                        },
                  child: const Text("ACCEPT & SIGN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getDeviceInfo() {
    if (GetPlatform.isWeb) return 'Web Browser';
    if (GetPlatform.isAndroid) return 'Android Device';
    if (GetPlatform.isIOS) return 'iOS Device';
    if (GetPlatform.isWindows) return 'Windows PC';
    if (GetPlatform.isMacOS) return 'macOS PC';
    if (GetPlatform.isLinux) return 'Linux PC';
    return 'Unknown Device';
  }

  Widget _buildConsentDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.sansBody(fontSize: 11, color: Colors.white54)),
          Text(value, style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}

/// A premium list card representing a quotation decoration item.
class QuotationItemCard extends StatelessWidget {
  final QuotationItem item;

  const QuotationItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: db.collection(AppCollections.items).doc(item.experienceId).get(),
      builder: (context, snapshot) {
        String imageUrl = '';
        String category = 'Decoration';
        double duration = 3.0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data()!;
          imageUrl = data['imageUrl'] ?? data['image_url'] ?? '';
          category = data['categoryName'] ?? data['category_name'] ?? 'Decoration';
          duration = (data['durationHours'] ?? data['duration_hours'] as num?)?.toDouble() ?? 3.0;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0D0B), // Matte Black base
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AD4AF37)),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x1AD4AF37)),
                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                      ? AppImage(
                          url: imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.white10,
                          child: const Icon(Icons.image, color: Colors.white24, size: 20),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${category.toUpperCase()} · ${duration.toStringAsFixed(0)} HRS",
                          style: const TextStyle(
                            fontSize: 8,
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          "₹${item.unitPrice.toStringAsFixed(0)}",
                          style: GoogleFonts.italiana(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.italiana(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Selected Customizations badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.color.isNotEmpty)
                          _buildBadge("Color: ${item.color}"),
                        if (item.theme.isNotEmpty)
                          _buildBadge("Theme: ${item.theme}"),
                        _buildBadge("Qty: ${item.quantity}"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x0AD4AF37),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x1AD4AF37)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          color: Color(0xFFE6C98D),
        ),
      ),
    );
  }

}
