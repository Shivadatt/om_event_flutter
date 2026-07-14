import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/constants/app_colors.dart';
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
    if (width > 1100) return 3; // Desktop
    if (width > 700) return 2;  // Laptop/Tablet
    return 1;                   // Mobile
  }

  double _getChildAspectRatio(int crossAxisCount, double width) {
    final double cardWidth = (width - 64 - (crossAxisCount - 1) * 24) / crossAxisCount;
    return cardWidth / 260; // Aspect ratio for quotation cards
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryAccent = AppColors.primaryAccent;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text(
          "SAVED QUOTATIONS",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Obx(() {
        final rawQuotes = controller.rxQuotes;
        if (rawQuotes.isEmpty) {
          return const Center(child: Text("No quotations generated yet."));
        }

        // Sort quotes: latest created date on top
        final quotes = List<Quotation>.from(rawQuotes)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
            final aspect = _getChildAspectRatio(crossAxisCount, constraints.maxWidth);

            return GridView.builder(
              padding: const EdgeInsets.all(32),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: aspect > 0 ? aspect : 1.2,
              ),
              itemCount: quotes.length,
              itemBuilder: (context, index) {
                final quote = quotes[index];
                
                // Set status color
                Color statusColor = primaryAccent;
                if (quote.status == QuotationStatus.draft) statusColor = AppColors.muted;
                if (quote.status == QuotationStatus.published || quote.status == QuotationStatus.republished) statusColor = AppColors.warning;
                if (quote.status == QuotationStatus.viewed) statusColor = AppColors.warning;
                if (quote.status == QuotationStatus.underRevision) statusColor = AppColors.warning;
                if (quote.status == QuotationStatus.acceptedByClient) statusColor = AppColors.success;
                if (quote.status == QuotationStatus.expired) statusColor = AppColors.error;
                if (quote.status == QuotationStatus.rejectedByClient) statusColor = AppColors.error;
                if (quote.status == QuotationStatus.bookingConfirmed || quote.status == QuotationStatus.completed) statusColor = AppColors.success;
                if (quote.status == QuotationStatus.inProgress) statusColor = primaryAccent;
                if (quote.status == QuotationStatus.archived) statusColor = AppColors.muted;

                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: borderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1),
                              ),
                              child: Text(
                                quote.status.nameStr.toUpperCase(),
                                style: AppTheme.sansBody(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            // Glass dropdown selector
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkForestSecondary : AppColors.lightForestSecondary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: quote.status.nameStr,
                                  icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
                                  items: QuotationStatus.values
                                      .where((s) => s == quote.status || (s != QuotationStatus.acceptedByClient && s != QuotationStatus.rejectedByClient))
                                      .map((s) => DropdownMenuItem(
                                    value: s.nameStr,
                                    child: Text(s.nameStr.toUpperCase()),
                                  )).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.updateQuotation(quote.id, val);
                                    }
                                  },
                                  style: AppTheme.sansBody(fontSize: 12, color: textColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                           quote.publicId.toUpperCase(),
                          style: AppTheme.sansBody(
                            fontSize: 9,
                            color: primaryAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quote.customerName,
                          style: AppTheme.serifHeader(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Date: ${AppFormatters.formatShortDate(quote.eventDate)} at ${quote.eventTime}",
                          style: AppTheme.sansBody(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                        const Divider(height: 20),
                        // Total / Action Area
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppFormatters.formatCurrency(quote.grandTotal),
                              style: AppTheme.serifHeader(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryAccent,
                              ),
                            ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: primaryAccent,
                                      size: 20,
                                    ),
                                    onPressed: () => QuotationEditorDialog.show(context, quote, controller),
                                    tooltip: "Edit Proposal Details",
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.picture_as_pdf_outlined,
                                      color: primaryAccent,
                                      size: 20,
                                    ),
                                    onPressed: () async {
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
                                    tooltip: "Download PDF Proposal",
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert_rounded, color: primaryAccent, size: 20),
                                    onSelected: (value) {
                                      if (value == 'archive') {
                                        controller.archiveQuotation(quote.id);
                                      } else if (value == 'expire') {
                                        controller.expireQuotation(quote.id);
                                      } else if (value == 'booking') {
                                        controller.convertQuotationToBooking(quote.id);
                                      } else if (value == 'timeline') {
                                        _showTimelineBottomSheet(context, quote);
                                      } else if (value == 'discussion') {
                                        _showDiscussionBottomSheet(context, quote);
                                      } else if (value == 'compare') {
                                        _showComparisonBottomSheet(context, quote);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'timeline',
                                        child: Row(
                                          children: [
                                            Icon(Icons.timeline_rounded, size: 18, color: textColor),
                                            const SizedBox(width: 8),
                                            const Text("Negotiation Timeline"),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'discussion',
                                        child: Row(
                                          children: [
                                            Icon(Icons.chat_bubble_outline_rounded, size: 18, color: textColor),
                                            const SizedBox(width: 8),
                                            const Text("Proposal Discussion"),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'compare',
                                        child: Row(
                                          children: [
                                            Icon(Icons.compare_arrows_rounded, size: 18, color: textColor),
                                            const SizedBox(width: 8),
                                            const Text("Compare Revisions"),
                                          ],
                                        ),
                                      ),
                                      if (quote.status != QuotationStatus.archived && quote.status != QuotationStatus.completed)
                                        PopupMenuItem(
                                          value: 'archive',
                                          child: Row(
                                            children: [
                                              Icon(Icons.archive_outlined, size: 18, color: textColor),
                                              const SizedBox(width: 8),
                                              const Text("Archive Proposal"),
                                            ],
                                          ),
                                        ),
                                      if (quote.status != QuotationStatus.expired && quote.status != QuotationStatus.bookingConfirmed && quote.status != QuotationStatus.completed)
                                        PopupMenuItem(
                                          value: 'expire',
                                          child: Row(
                                            children: [
                                              Icon(Icons.hourglass_empty_rounded, size: 18, color: textColor),
                                              const SizedBox(width: 8),
                                              const Text("Mark as Expired"),
                                            ],
                                          ),
                                        ),
                                      if (quote.status == QuotationStatus.acceptedByClient)
                                        PopupMenuItem(
                                          value: 'booking',
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle_outline_rounded, size: 18, color: textColor),
                                              const SizedBox(width: 8),
                                              const Text("Convert to Booking"),
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
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  void _showTimelineBottomSheet(BuildContext context, Quotation quote) {
    Get.bottomSheet(
      QuotesTimelineBottomSheet(quote: quote),
      isScrollControlled: true,
    );
  }

  void _showDiscussionBottomSheet(BuildContext context, Quotation quote) {
    Get.bottomSheet(
      QuotesDiscussionBottomSheet(quote: quote),
      isScrollControlled: true,
    );
  }

  void _showComparisonBottomSheet(BuildContext context, Quotation quote) {
    VersionComparisonSheet.show(context, quote);
  }
}
