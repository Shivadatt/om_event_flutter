import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../domain/entities/quotation.dart';

class QuotesTimelineBottomSheet extends StatelessWidget {
  final Quotation quote;

  const QuotesTimelineBottomSheet({
    super.key,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final Color paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;

    return Container(
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
          if (quote.timeline.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  "No timeline events recorded.",
                  style: AppTheme.sansBody(fontSize: 13, color: subtitleColor),
                ),
              ),
            )
          else
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
    );
  }
}
