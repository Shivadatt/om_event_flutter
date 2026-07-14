import 'package:flutter/material.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/utils/formatters.dart';
import 'package:om_event/domain/entities/quotation.dart';

/// Renders the sequential timeline/lifecycle events of a quotation.
class QuotesTimelineSection extends StatelessWidget {
  final Quotation activeQuote;

  const QuotesTimelineSection({super.key, required this.activeQuote});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  if (!isLast) Container(width: 1.5, height: 40, color: Colors.white.withValues(alpha: 0.08)),
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
                        Text(event.title, style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(AppFormatters.formatShortDate(event.timestamp), style: AppTheme.sansBody(fontSize: 9, color: Colors.white38)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(event.description, style: AppTheme.sansBody(fontSize: 11, color: Colors.white60)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
