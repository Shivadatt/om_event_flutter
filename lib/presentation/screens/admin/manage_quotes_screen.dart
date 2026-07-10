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
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/quotation_collaboration_controller.dart';
import '../../../domain/entities/quotation_message.dart';
import '../../widgets/reusable/version_comparison_sheet.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final Color paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: paperColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: isDark ? AppColors.darkLine : AppColors.lightLine, width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PROPOSAL LIFECYCLE",
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Negotiation Timeline",
                      style: AppTheme.serifHeader(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Quotation ID: ${quote.publicId.toUpperCase()}",
              style: AppTheme.sansBody(fontSize: 12, color: subtitleColor),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                  child: Column(
                    children: List.generate(quote.timeline.length, (idx) {
                      final event = quote.timeline[idx];
                      final isLast = idx == quote.timeline.length - 1;
                      
                      Color dotColor = AppColors.primaryAccent;
                      IconData dotIcon = Icons.radio_button_checked_rounded;

                      if (event.status == QuotationStatus.draft) {
                        dotColor = AppColors.muted;
                        dotIcon = Icons.note_add_outlined;
                      } else if (event.status == QuotationStatus.published) {
                        dotColor = AppColors.warning;
                        dotIcon = Icons.send_rounded;
                      } else if (event.status == QuotationStatus.viewed) {
                        dotColor = AppColors.warning;
                        dotIcon = Icons.visibility_outlined;
                      } else if (event.status == QuotationStatus.revisionRequested) {
                        dotColor = AppColors.error;
                        dotIcon = Icons.edit_note_rounded;
                      } else if (event.status == QuotationStatus.underRevision) {
                        dotColor = AppColors.warning;
                        dotIcon = Icons.build_rounded;
                      } else if (event.status == QuotationStatus.republished) {
                        dotColor = AppColors.warning;
                        dotIcon = Icons.published_with_changes_rounded;
                      } else if (event.status == QuotationStatus.acceptedByClient) {
                        dotColor = AppColors.success;
                        dotIcon = Icons.check_circle_rounded;
                      } else if (event.status == QuotationStatus.bookingConfirmed) {
                        dotColor = AppColors.success;
                        dotIcon = Icons.celebration_rounded;
                      } else if (event.status == QuotationStatus.completed) {
                        dotColor = AppColors.success;
                        dotIcon = Icons.done_all_rounded;
                      } else if (event.status == QuotationStatus.cancelled) {
                        dotColor = AppColors.error;
                        dotIcon = Icons.cancel_rounded;
                      } else if (event.status == QuotationStatus.expired) {
                        dotColor = AppColors.error;
                        dotIcon = Icons.timer_off_rounded;
                      } else if (event.status == QuotationStatus.archived) {
                        dotColor = AppColors.muted;
                        dotIcon = Icons.archive_rounded;
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: dotColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: dotColor, width: 1.5),
                                ),
                                child: Icon(dotIcon, size: 16, color: dotColor),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 48,
                                  color: isDark ? AppColors.darkLine : AppColors.lightLine,
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
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      AppFormatters.formatShortDate(event.timestamp),
                                      style: AppTheme.sansBody(
                                        fontSize: 10,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  event.description,
                                  style: AppTheme.sansBody(
                                    fontSize: 11,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDiscussionBottomSheet(BuildContext context, Quotation quote) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final Color paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;

    final chatController = Get.put(
      QuotationCollaborationController(
        quotationId: quote.id,
        senderId: 'admin_user',
        senderName: 'Admin Coordinators',
        senderRole: 'admin',
      ),
      tag: quote.id,
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: paperColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: isDark ? AppColors.darkLine : AppColors.lightLine, width: 1.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PROPOSAL DISCUSSIONS",
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Client Portal Chat",
                      style: AppTheme.serifHeader(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Quotation ID: ${quote.publicId.toUpperCase()} (Client: ${quote.customerName})",
              style: AppTheme.sansBody(fontSize: 12, color: subtitleColor),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkLine : AppColors.lightLine),
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
                                Icon(Icons.chat_bubble_outline_rounded, color: subtitleColor.withValues(alpha: 0.5), size: 36),
                                const SizedBox(height: 12),
                                Text(
                                  "No messages yet. Send a message to coordinate with the customer.",
                                  style: AppTheme.sansBody(fontSize: 11, color: subtitleColor),
                                  textAlign: TextAlign.center,
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
                            final isMe = msg.senderRole == 'admin';
                            return _buildAdminMessageBubble(msg, isMe, isDark, textColor, subtitleColor);
                          },
                        );
                      }),
                    ),
                    Obx(() {
                      if (chatController.isUploading.value) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: isDark ? Colors.black26 : Colors.grey.shade200,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primaryAccent),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Uploading attachment...",
                                style: TextStyle(color: subtitleColor, fontSize: 11),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey.shade100,
                        border: Border(top: BorderSide(color: isDark ? AppColors.darkLine : AppColors.lightLine)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.attach_file_rounded, color: AppColors.primaryAccent, size: 20),
                            onPressed: () => chatController.pickAndUploadAttachment(),
                            tooltip: "Upload Attachment",
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: chatController.textController,
                              style: TextStyle(color: textColor, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: "Send a message to the customer...",
                                hintStyle: TextStyle(color: subtitleColor, fontSize: 13),
                                filled: true,
                                fillColor: isDark ? Colors.black12 : Colors.white,
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
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primaryAccent),
                                  )
                                : IconButton(
                                    icon: Icon(Icons.send_rounded, color: AppColors.primaryAccent, size: 20),
                                    onPressed: () => chatController.sendTextMessage(),
                                  );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildAdminMessageBubble(
    QuotationMessage msg,
    bool isMe,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    if (msg.type == 'system' || msg.type == 'priceChange' || msg.type == 'revision') {
      Color bannerColor = AppColors.primaryAccent.withValues(alpha: 0.1);
      Color labelColor = AppColors.primaryAccent;
      IconData icon = Icons.info_outline_rounded;

      if (msg.type == 'priceChange') {
        bannerColor = AppColors.success.withValues(alpha: 0.1);
        labelColor = AppColors.success;
        icon = Icons.monetization_on_outlined;
      } else if (msg.type == 'revision') {
        bannerColor = AppColors.error.withValues(alpha: 0.1);
        labelColor = AppColors.error;
        icon = Icons.published_with_changes_rounded;
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bannerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: labelColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: labelColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg.content,
                style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    final aligns = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe 
        ? AppColors.primaryAccent.withValues(alpha: 0.15) 
        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200);
    final borderColor = isMe 
        ? AppColors.primaryAccent.withValues(alpha: 0.3) 
        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300);

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
                      style: TextStyle(color: AppColors.primaryAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  if (!isMe) const SizedBox(height: 4),
                  if (msg.type == 'text')
                    Text(msg.content, style: TextStyle(color: textColor, fontSize: 12.5)),
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
                          color: AppColors.primaryAccent,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            msg.attachments.isNotEmpty ? msg.attachments.first.fileName : "View Attachment",
                            style: TextStyle(color: textColor, fontSize: 12, decoration: TextDecoration.underline),
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
                  style: TextStyle(color: subtitleColor, fontSize: 9),
                ),
                if (isMe) const SizedBox(width: 4),
                if (isMe)
                  Icon(
                    msg.isReadByClient ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 11,
                    color: msg.isReadByClient ? AppColors.primaryAccent : subtitleColor,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComparisonBottomSheet(BuildContext context, Quotation quote) {
    VersionComparisonSheet.show(context, quote);
  }
}
