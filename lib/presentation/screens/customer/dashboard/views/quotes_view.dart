import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_collections.dart';
import '../../../../../domain/entities/quotation.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../../core/widgets/app_image.dart';

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
        final quotations = widget.controller.rxQuotations;

        if (quotations.isEmpty) {
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
                      if (activeQuote.versionHistory.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: Text(
                              "REVISION HISTORY (v${activeQuote.version})",
                              style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
                            ),
                            iconColor: const Color(0xFFD4AF37),
                            collapsedIconColor: const Color(0xFFD4AF37),
                            children: activeQuote.versionHistory.map((histStr) {
                              try {
                                final hist = jsonDecode(histStr) as Map<String, dynamic>;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Version ${hist['version'] ?? '?'}", style: const TextStyle(color: Color(0xFFC9A77E), fontWeight: FontWeight.bold, fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Text("Reason: ${hist['reason'] ?? 'Revision'}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                        ],
                                      ),
                                      Text("₹${(hist['grand_total'] ?? 0).toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                );
                              } catch (_) {
                                return const SizedBox.shrink();
                              }
                            }).toList(),
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
                                widget.controller.acceptQuotation(activeQuote.id);
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
        return const Color(0xFFE6C98D);
      case QuotationStatus.rejectedByClient:
      case QuotationStatus.cancelled:
      case QuotationStatus.expired:
        return const Color(0xFFC95C5C);
      case QuotationStatus.inProgress:
        return const Color(0xFF7CB6D6);
      case QuotationStatus.draft:
        return Colors.white54;
    }
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
