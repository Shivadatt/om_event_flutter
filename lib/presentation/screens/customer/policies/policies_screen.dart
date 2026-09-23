import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/services/app_config_service.dart';
import '../../../../../core/services/business_details_service.dart';
import '../widgets/booking_tracker_dialog.dart';

class PoliciesScreen extends StatefulWidget {
  final int initialTabIndex;

  const PoliciesScreen({super.key, this.initialTabIndex = 0});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final goldColor = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFF091210),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF0F1B18).withValues(alpha: 0.95),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white70),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Get.offAllNamed(AppRoutes.home);
                }
              },
            ),
            title: Text(
              "POLICIES & GUIDELINES",
              style: GoogleFonts.italiana(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
            ),
            actions: [
              TextButton.icon(
                icon: Icon(Icons.photo_library_outlined, size: 16, color: goldColor),
                label: Text("GALLERY", style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.bold)),
                onPressed: () => Get.toNamed(AppRoutes.gallery),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.track_changes_rounded, size: 16, color: Colors.white70),
                label: Text("TRACK BOOKING", style: AppTheme.sansBody(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                onPressed: () => showBookingTrackerDialog(context),
              ),
              const SizedBox(width: 16),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: const Color(0xFF152621),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: goldColor,
                  indicatorWeight: 3,
                  labelColor: goldColor,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  unselectedLabelStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.normal),
                  tabs: const [
                    Tab(text: "BOOKING POLICY"),
                    Tab(text: "CANCELLATION & REFUNDS"),
                  ],
                ),
              ),
            ),
          ),

          // Content Box
          SliverToBoxAdapter(
            child: Obx(() {
              final bizDetails = BusinessDetailsService.to.rxDetails.value;
              final bookingSettings = AppConfigService.to.rxBookingSettings.value;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 80 : 20,
                  vertical: 36,
                ),
                child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    if (_tabController.index == 0) {
                      return _buildBookingPolicyContent(bizDetails, bookingSettings, goldColor);
                    } else {
                      return _buildCancellationPolicyContent(bizDetails, bookingSettings, goldColor);
                    }
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingPolicyContent(dynamic bizDetails, dynamic bookingSettings, Color goldColor) {
    final leadDays = bookingSettings.advanceDays > 0 ? bookingSettings.advanceDays : 7;
    final customTerms = bizDetails.legal.termsAndConditions as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("RESERVATION & CONFIRMATION", "Client Booking Agreement", goldColor),
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
              style: AppTheme.sansBody(fontSize: 13, color: Colors.white70, height: 1.6),
            ),
          ),
          const SizedBox(height: 28),
        ],

        _buildPolicyRuleCard(
          "1. Exclusive Date Reservation",
          "OM Events & Decorators maintains a strict 'One Master Celebration Per Day' guarantee. Once your booking deposit is received, your event date is locked exclusively for your family, ensuring 100% focused artisan supervision.",
          Icons.verified_outlined,
          goldColor,
        ),
        const SizedBox(height: 16),

        _buildPolicyRuleCard(
          "2. Advance Notice & Lead Time",
          "All curated celebrations require a minimum of $leadDays days advance confirmation. Major luxury wedding curations and multi-day ceremonies are recommended to be scheduled 30 to 60 days in advance.",
          Icons.calendar_month_outlined,
          goldColor,
        ),
        const SizedBox(height: 16),

        _buildPolicyRuleCard(
          "3. Advance Confirmation Token",
          "A non-refundable 25% reservation advance is required upon proposal approval to lock event slots, secure structural props, and place early orders with floral cultivators.",
          Icons.account_balance_wallet_outlined,
          goldColor,
        ),
        const SizedBox(height: 16),

        _buildPolicyRuleCard(
          "4. Design & Material Revisions",
          "Custom decor moodboards, flower colorways, and structural layouts can be revised until 7 days prior to the event date. Minor day-of embellishments will be accommodated at the supervisor's discretion.",
          Icons.auto_fix_high_outlined,
          goldColor,
        ),
        const SizedBox(height: 16),

        _buildPolicyRuleCard(
          "5. Venue Logistics & Technical Provisions",
          "Clients are requested to ensure timely venue handover (minimum 4-6 hours prior to event start), active power points (3-phase power for lighting rigs), and necessary local society/banquet permissions.",
          Icons.power_outlined,
          goldColor,
        ),
      ],
    );
  }

  Widget _buildCancellationPolicyContent(dynamic bizDetails, dynamic bookingSettings, Color goldColor) {
    final customCancelPolicy = bizDetails.legal.cancellationPolicy as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("CANCELLATIONS & REFUNDS", "Transparent Terms & Protocols", goldColor),
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
              style: AppTheme.sansBody(fontSize: 13, color: Colors.white70, height: 1.6),
            ),
          ),
          const SizedBox(height: 28),
        ],

        _buildPolicyRuleCard(
          "1. Notice Period: 15+ Days Prior",
          "Cancellations submitted 15 days or more before the scheduled celebration are eligible for date rescheduling with full 100% deposit transfer, or cancellation subject to a standard 10% administrative processing deduction.",
          Icons.event_available_outlined,
          const Color(0xFF4EBA7A),
        ),
        const SizedBox(height: 16),

        _buildPolicyRuleCard(
          "2. Notice Period: 7 to 14 Days Prior",
          "Cancellations submitted between 7 and 14 days prior to the event are subject to a 50% retention of the advance deposit to cover pre-fabricated signage, custom fabrication, and committed artisan schedules.",
          Icons.change_circle_outlined,
          goldColor,
        ),
        const SizedBox(height: 16),

        _buildPolicyRuleCard(
          "3. Notice Period: Under 7 Days Prior",
          "Due to strict date locking and perishable fresh flower procurement, cancellations requested within 7 days of the celebration date are non-refundable. Clients may request prop credits for future celebrations.",
          Icons.event_busy_outlined,
          const Color(0xFFE57373),
        ),
        const SizedBox(height: 16),

        _buildPolicyRuleCard(
          "4. Force Majeure & Weather Adaptation",
          "In the unforeseen event of extreme weather, municipal restrictions, or emergency lockdowns, OM Events will provide complimentary date rescheduling within 6 months, subject to calendar availability.",
          Icons.wb_twilight_outlined,
          const Color(0xFF64B5F6),
        ),
        const SizedBox(height: 16),

        _buildPolicyRuleCard(
          "5. Refund Disbursement Timeline",
          "All eligible refunds are disbursed back to the original source bank account or UPI handle within 5 to 7 business days following formal confirmation of the cancellation request.",
          Icons.payments_outlined,
          goldColor,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String subtitle, String title, Color goldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle, style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: goldColor, letterSpacing: 2.5)),
        const SizedBox(height: 6),
        Text(title, style: GoogleFonts.italiana(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildPolicyRuleCard(String title, String description, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF152621),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: accentColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.italiana(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(description, style: AppTheme.sansBody(fontSize: 13, color: Colors.white70, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
