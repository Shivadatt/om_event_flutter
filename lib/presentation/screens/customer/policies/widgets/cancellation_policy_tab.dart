import 'package:flutter/material.dart';
import '../../../../../core/config/app_theme.dart';
import 'policy_rule_card.dart';

class CancellationPolicyTab extends StatelessWidget {
  final dynamic bizDetails;
  final dynamic bookingSettings;
  final Color goldColor;

  const CancellationPolicyTab({
    super.key,
    required this.bizDetails,
    required this.bookingSettings,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    final customCancelPolicy = bizDetails.legal.cancellationPolicy as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PolicySectionHeader(
          subtitle: "CANCELLATIONS & REFUNDS",
          title: "Transparent Terms & Protocols",
          goldColor: goldColor,
        ),
        const SizedBox(height: 24),

        if (customCancelPolicy.trim().isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF152621),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: goldColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              customCancelPolicy,
              style: AppTheme.sansBody(
                fontSize: 13,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],

        const PolicyRuleCard(
          title: "1. Notice Period: 15+ Days Prior",
          description:
              "Cancellations submitted 15 days or more before the scheduled celebration are eligible for date rescheduling with full 100% deposit transfer, or cancellation subject to a standard 10% administrative processing deduction.",
          icon: Icons.event_available_outlined,
          accentColor: Color(0xFF4EBA7A),
        ),
        const SizedBox(height: 16),

        PolicyRuleCard(
          title: "2. Notice Period: 7 to 14 Days Prior",
          description:
              "Cancellations submitted between 7 and 14 days prior to the event are subject to a 50% retention of the advance deposit to cover pre-fabricated signage, custom fabrication, and committed artisan schedules.",
          icon: Icons.change_circle_outlined,
          accentColor: goldColor,
        ),
        const SizedBox(height: 16),

        const PolicyRuleCard(
          title: "3. Notice Period: Under 7 Days Prior",
          description:
              "Due to strict date locking and perishable fresh flower procurement, cancellations requested within 7 days of the celebration date are non-refundable. Clients may request prop credits for future celebrations.",
          icon: Icons.event_busy_outlined,
          accentColor: Color(0xFFE57373),
        ),
        const SizedBox(height: 16),

        const PolicyRuleCard(
          title: "4. Force Majeure & Weather Adaptation",
          description:
              "In the unforeseen event of extreme weather, municipal restrictions, or emergency lockdowns, OM Events will provide complimentary date rescheduling within 6 months, subject to calendar availability.",
          icon: Icons.wb_twilight_outlined,
          accentColor: Color(0xFF64B5F6),
        ),
        const SizedBox(height: 16),

        PolicyRuleCard(
          title: "5. Refund Disbursement Timeline",
          description:
              "All eligible refunds are disbursed back to the original source bank account or UPI handle within 5 to 7 business days following formal confirmation of the cancellation request.",
          icon: Icons.payments_outlined,
          accentColor: goldColor,
        ),
      ],
    );
  }
}
