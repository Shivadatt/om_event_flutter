import 'package:flutter/material.dart';
import '../../../../../core/config/app_theme.dart';
import 'policy_rule_card.dart';

class BookingPolicyTab extends StatelessWidget {
  final dynamic bizDetails;
  final dynamic bookingSettings;
  final Color goldColor;

  const BookingPolicyTab({
    super.key,
    required this.bizDetails,
    required this.bookingSettings,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    final leadDays =
        bookingSettings.advanceDays > 0 ? bookingSettings.advanceDays : 7;
    final customTerms = bizDetails.legal.termsAndConditions as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PolicySectionHeader(
          subtitle: "RESERVATION & CONFIRMATION",
          title: "Client Booking Agreement",
          goldColor: goldColor,
        ),
        const SizedBox(height: 24),

        if (customTerms.trim().isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF152621),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: goldColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              customTerms,
              style: AppTheme.sansBody(
                fontSize: 13,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],

        PolicyRuleCard(
          title: "1. Exclusive Date Reservation",
          description:
              "OM Events & Decorators maintains a strict 'One Master Celebration Per Day' guarantee. Once your booking deposit is received, your event date is locked exclusively for your family, ensuring 100% focused artisan supervision.",
          icon: Icons.verified_outlined,
          accentColor: goldColor,
        ),
        const SizedBox(height: 16),

        PolicyRuleCard(
          title: "2. Advance Notice & Lead Time",
          description:
              "All curated celebrations require a minimum of $leadDays days advance confirmation. Major luxury wedding curations and multi-day ceremonies are recommended to be scheduled 30 to 60 days in advance.",
          icon: Icons.calendar_month_outlined,
          accentColor: goldColor,
        ),
        const SizedBox(height: 16),

        PolicyRuleCard(
          title: "3. Advance Confirmation Token",
          description:
              "A non-refundable 25% reservation advance is required upon proposal approval to lock event slots, secure structural props, and place early orders with floral cultivators.",
          icon: Icons.account_balance_wallet_outlined,
          accentColor: goldColor,
        ),
        const SizedBox(height: 16),

        PolicyRuleCard(
          title: "4. Design & Material Revisions",
          description:
              "Custom decor moodboards, flower colorways, and structural layouts can be revised until 7 days prior to the event date. Minor day-of embellishments will be accommodated at the supervisor's discretion.",
          icon: Icons.auto_fix_high_outlined,
          accentColor: goldColor,
        ),
        const SizedBox(height: 16),

        PolicyRuleCard(
          title: "5. Venue Logistics & Technical Provisions",
          description:
              "Clients are requested to ensure timely venue handover (minimum 4-6 hours prior to event start), active power points (3-phase power for lighting rigs), and necessary local society/banquet permissions.",
          icon: Icons.power_outlined,
          accentColor: goldColor,
        ),
      ],
    );
  }
}
