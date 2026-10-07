import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/feature_flags.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../controllers/admin_controller.dart';
import '../../../core/utils/pdf_helper.dart';
import '../../controllers/quotation_controller.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import '../../../domain/entities/quotation.dart';
import 'widgets/quotation_editor_dialog.dart';
import '../../widgets/reusable/version_comparison_sheet.dart';

import 'widgets/quotes/quotes_timeline_bottom_sheet.dart';
import 'widgets/quotes/quotes_discussion_bottom_sheet.dart';

class ManageQuotesScreen extends GetView<AdminController> {
  const ManageQuotesScreen({super.key});

  int _getCrossAxisCount(double width) {
    if (width >= 900) return 3; // Desktop matches reference
    if (width >= 620) return 2;  // Tablet
    return 1;                   // Mobile
  }

  Color _getStatusColor(QuotationStatus status) {
    const goldColor = Color(0xFFECC24A);
    const greenColor = Color(0xFF4EBA7A);
    const redColor = Color(0xFFE55353);
    const mutedColor = Colors.white54;

    switch (status) {
      case QuotationStatus.viewed:
      case QuotationStatus.published:
      case QuotationStatus.republished:
      case QuotationStatus.underRevision:
      case QuotationStatus.inProgress:
        return goldColor;
      case QuotationStatus.acceptedByClient:
      case QuotationStatus.bookingConfirmed:
      case QuotationStatus.completed:
        return greenColor;
      case QuotationStatus.expired:
      case QuotationStatus.rejectedByClient:
        return redColor;
      case QuotationStatus.draft:
      case QuotationStatus.archived:
      default:
        return mutedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isInsideDrawer = AdminLayoutScope.of(context);
    const goldColor = Color(0xFFECC24A);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text(
          "SAVED QUOTATIONS",
          style: AppTheme.sansBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white70,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isInsideDrawer ? 0 : kToolbarHeight,
      ),
      backgroundColor: Colors.transparent,
      body: Obx(() {
        final rawQuotes = controller.rxQuotes;
        if (rawQuotes.isEmpty) {
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
                      child: const Icon(Icons.description_outlined, color: goldColor, size: 26),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No Quotations Found",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "No quotations have been generated yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Sort quotes: latest created date on top
        final quotes = List<Quotation>.from(rawQuotes)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final bool isMobile = maxWidth < 650;
            final int crossAxisCount = _getCrossAxisCount(maxWidth);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 14 : 20,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page Title Header
                      Text(
                        "SAVED QUOTATIONS",
                        style: GoogleFonts.montserrat(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quotation Cards Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: isMobile ? 12 : 16,
                          mainAxisSpacing: isMobile ? 12 : 16,
                          mainAxisExtent: isMobile ? 192 : 196,
                        ),
                        itemCount: quotes.length,
                        itemBuilder: (context, index) {
                          final quote = quotes[index];
                          return _buildQuotationCard(context, quote);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildQuotationCard(BuildContext context, Quotation quote) {
    final statusColor = _getStatusColor(quote.status);
    const goldColor = Color(0xFFECC24A);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1D18), Color(0xFF0C1914)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.18),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Top Row: Status Badge (Left) + Compact Status Dropdown (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 0.9),
                ),
                child: Text(
                  quote.status.nameStr.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              // Compact Status Dropdown Pill
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF091410),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.28), width: 0.8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: quote.status.nameStr,
                    dropdownColor: const Color(0xFF0C1914),
                    icon: Icon(Icons.arrow_drop_down_rounded, size: 16, color: statusColor),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                    isDense: true,
                    items: QuotationStatus.values
                        .where((s) => s == quote.status || (s != QuotationStatus.acceptedByClient && s != QuotationStatus.rejectedByClient))
                        .map((s) => DropdownMenuItem(
                      value: s.nameStr,
                      child: Text(
                        s.nameStr.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(s),
                        ),
                      ),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.updateQuotation(quote.id, val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          // 2. Quotation Details Section (ID + Customer + Date)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quotation ID
              Text(
                quote.publicId.toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 10.5,
                  color: goldColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 3),

              // Customer Name
              Text(
                quote.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),

              // Event Date & Time
              Text(
                "Date: ${AppFormatters.formatShortDate(quote.eventDate)} at ${quote.eventTime}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.0,
                  color: Colors.white60,
                ),
              ),
            ],
          ),

          // 3. Subtle Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),

          // 4. Bottom Total & Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Grand Total Amount
              Text(
                AppFormatters.formatCurrency(quote.grandTotal),
                style: GoogleFonts.montserrat(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                ),
              ),

              // Action Icons (Edit, PDF, More)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Icon
                  InkWell(
                    onTap: () => QuotationEditorDialog.show(context, quote, controller),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.edit_outlined, color: goldColor, size: 16),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // PDF Icon
                  InkWell(
                    onTap: () async {
                      try {
                        final quoteCtrl = Get.find<QuotationController>();
                        final pdfBytes = await quoteCtrl.generateInvoicePdf(quote);
                        await PdfHelper.saveAndLaunchPdf(
                          pdfBytes,
                          'quotation_${quote.publicId}.pdf',
                        );
                      } catch (e) {
                        Get.snackbar(
                          "Error Generating PDF",
                          e.toString(),
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.picture_as_pdf_outlined, color: goldColor, size: 16),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // More Menu Popup
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.more_vert_rounded, color: goldColor, size: 16),
                    color: const Color(0xFF0C1914),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: goldColor.withValues(alpha: 0.2)),
                    ),
                    onSelected: (value) {
                      if (value == 'archive') {
                        controller.archiveQuotation(quote.id);
                      } else if (value == 'expire') {
                        controller.expireQuotation(quote.id);
                      } else if (value == 'booking') {
                        controller.convertQuotationToBooking(quote.id);
                      } else if (value == 'timeline') {
                        if (FeatureFlags.quotationNegotiation) {
                          _showTimelineBottomSheet(context, quote);
                        }
                      } else if (value == 'discussion') {
                        if (FeatureFlags.realtimeQuotationChat) {
                          _showDiscussionBottomSheet(context, quote);
                        }
                      } else if (value == 'compare') {
                        if (FeatureFlags.quotationNegotiation) {
                          _showComparisonBottomSheet(context, quote);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      if (FeatureFlags.quotationNegotiation)
                        PopupMenuItem(
                          value: 'timeline',
                          child: const Row(
                            children: [
                              Icon(Icons.timeline_rounded, size: 16, color: Colors.white70),
                              SizedBox(width: 8),
                              Text("Negotiation Timeline", style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      if (FeatureFlags.realtimeQuotationChat)
                        PopupMenuItem(
                          value: 'discussion',
                          child: const Row(
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.white70),
                              SizedBox(width: 8),
                              Text("Proposal Discussion", style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      if (FeatureFlags.quotationNegotiation)
                        PopupMenuItem(
                          value: 'compare',
                          child: const Row(
                            children: [
                              Icon(Icons.compare_arrows_rounded, size: 16, color: Colors.white70),
                              SizedBox(width: 8),
                              Text("Compare Revisions", style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      if (quote.status != QuotationStatus.archived && quote.status != QuotationStatus.completed)
                        PopupMenuItem(
                          value: 'archive',
                          child: const Row(
                            children: [
                              Icon(Icons.archive_outlined, size: 16, color: Colors.white70),
                              SizedBox(width: 8),
                              Text("Archive Proposal", style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      if (quote.status != QuotationStatus.expired && quote.status != QuotationStatus.bookingConfirmed && quote.status != QuotationStatus.completed)
                        PopupMenuItem(
                          value: 'expire',
                          child: const Row(
                            children: [
                              Icon(Icons.hourglass_empty_rounded, size: 16, color: Colors.white70),
                              SizedBox(width: 8),
                              Text("Mark as Expired", style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      if (quote.status == QuotationStatus.acceptedByClient)
                        PopupMenuItem(
                          value: 'booking',
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white70),
                              SizedBox(width: 8),
                              Text("Convert to Booking", style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimelineBottomSheet(BuildContext context, Quotation quote) {
    if (!FeatureFlags.quotationNegotiation) {
      Get.snackbar("Notice", "Negotiation timeline is temporarily disabled.");
      return;
    }
    Get.bottomSheet(
      QuotesTimelineBottomSheet(quote: quote),
      isScrollControlled: true,
    );
  }

  void _showDiscussionBottomSheet(BuildContext context, Quotation quote) {
    if (!FeatureFlags.realtimeQuotationChat) {
      Get.snackbar("Notice", "Proposal chat is temporarily disabled.");
      return;
    }
    Get.bottomSheet(
      QuotesDiscussionBottomSheet(quote: quote),
      isScrollControlled: true,
    );
  }

  void _showComparisonBottomSheet(BuildContext context, Quotation quote) {
    if (!FeatureFlags.quotationNegotiation) {
      Get.snackbar("Notice", "Version comparison is temporarily disabled.");
      return;
    }
    VersionComparisonSheet.show(context, quote);
  }
}
