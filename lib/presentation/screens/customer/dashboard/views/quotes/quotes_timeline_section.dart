import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/domain/entities/quotation.dart';

/// Renders the sequential Proposal Lifecycle timeline matching Option 2 Modern Card Style.
class QuotesTimelineSection extends StatelessWidget {
  final Quotation activeQuote;
  final VoidCallback? onDecline;

  const QuotesTimelineSection({
    super.key,
    required this.activeQuote,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final status = activeQuote.status;
    final isConfirmed = status == QuotationStatus.acceptedByClient ||
        status == QuotationStatus.bookingConfirmed ||
        status == QuotationStatus.completed;
    final isFinalProposal = isConfirmed ||
        status == QuotationStatus.published ||
        status == QuotationStatus.republished ||
        status == QuotationStatus.viewed;
    final isDiscussion = isFinalProposal ||
        status == QuotationStatus.revisionRequested ||
        status == QuotationStatus.underRevision;
    const isInitiated = true;

    final createdDateStr = DateFormat('d MMM yyyy').format(activeQuote.createdAt);

    final steps = [
      _LifecycleStep(
        title: "Proposal Initiated",
        subtitle: "Initial quotation draft created in system",
        date: createdDateStr,
        isCompleted: isInitiated,
        isActive: status == QuotationStatus.draft,
      ),
      _LifecycleStep(
        title: "In Review",
        subtitle: "Curator evaluating requirements & theme assets",
        date: isDiscussion ? DateFormat('d MMM yyyy').format(activeQuote.updatedAt) : '',
        isCompleted: isDiscussion,
        isActive: status == QuotationStatus.underRevision,
      ),
      _LifecycleStep(
        title: "Discussion",
        subtitle: "Client consultations & customization notes",
        date: isFinalProposal ? DateFormat('d MMM yyyy').format(activeQuote.updatedAt) : '',
        isCompleted: isFinalProposal,
        isActive: status == QuotationStatus.revisionRequested,
      ),
      _LifecycleStep(
        title: "Final Proposal",
        subtitle: "Approved design ready for contract consent",
        date: isConfirmed ? DateFormat('d MMM yyyy').format(activeQuote.updatedAt) : '',
        isCompleted: isConfirmed,
        isActive: status == QuotationStatus.published ||
            status == QuotationStatus.republished ||
            status == QuotationStatus.viewed,
      ),
      _LifecycleStep(
        title: "Confirmed",
        subtitle: "Digital consent granted & booking finalized",
        date: isConfirmed && activeQuote.acceptedAt != null
            ? DateFormat('d MMM yyyy').format(activeQuote.acceptedAt!)
            : '',
        isCompleted: isConfirmed,
        isActive: isConfirmed,
      ),
    ];

    final bool canDecline = status == QuotationStatus.published ||
        status == QuotationStatus.republished ||
        status == QuotationStatus.viewed;

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
                "PROPOSAL LIFECYCLE",
                style: AppTheme.sansBody(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 1.5,
                ),
              ),
              if (activeQuote.versions.isNotEmpty)
                Text(
                  "v${activeQuote.version}",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE5C378),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Lifecycle Step List
          ...List.generate(steps.length, (idx) {
            final step = steps[idx];
            final isLast = idx == steps.length - 1;

            Color dotBg = const Color(0xFF16201A);
            Color dotBorder = const Color(0x33D4AF37);
            Color iconColor = Colors.white24;
            IconData icon = Icons.circle_outlined;

            if (step.isCompleted) {
              dotBg = const Color(0xFFD4AF37);
              dotBorder = const Color(0xFFD4AF37);
              iconColor = const Color(0xFF091210);
              icon = Icons.check_rounded;
            } else if (step.isActive) {
              dotBg = const Color(0xFF1E2C23);
              dotBorder = const Color(0xFFE5C378);
              iconColor = const Color(0xFFE5C378);
              icon = Icons.radio_button_checked_rounded;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: dotBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: dotBorder, width: 1.5),
                        boxShadow: step.isCompleted || step.isActive
                            ? const [BoxShadow(color: Color(0x33D4AF37), blurRadius: 6)]
                            : null,
                      ),
                      child: Icon(icon, size: 13, color: iconColor),
                    ),
                    if (!isLast)
                      Container(
                        width: 1.5,
                        height: 38,
                        color: step.isCompleted
                            ? const Color(0x44D4AF37)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              step.title,
                              style: AppTheme.sansBody(
                                fontSize: 12.5,
                                fontWeight: step.isCompleted || step.isActive
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: step.isCompleted || step.isActive
                                    ? Colors.white
                                    : Colors.white38,
                              ),
                            ),
                            if (step.date.isNotEmpty)
                              Text(
                                step.date,
                                style: const TextStyle(fontSize: 9.5, color: Colors.white38),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.subtitle,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: step.isCompleted || step.isActive
                                ? Colors.white60
                                : Colors.white24,
                          ),
                        ),
                        if (!isLast) const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          // Decline Action at the bottom of the Lifecycle card
          if (onDecline != null && canDecline) ...[
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC95C5C),
                  side: const BorderSide(color: Color(0x44C95C5C)),
                  backgroundColor: const Color(0x0DC95C5C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onDecline,
                child: const Text(
                  "Decline Proposal",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LifecycleStep {
  final String title;
  final String subtitle;
  final String date;
  final bool isCompleted;
  final bool isActive;

  const _LifecycleStep({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.isCompleted,
    required this.isActive,
  });
}
