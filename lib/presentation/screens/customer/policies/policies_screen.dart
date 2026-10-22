import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/services/app_config_service.dart';
import '../../../../../core/services/business_details_service.dart';
import '../widgets/booking_tracker_dialog.dart';
import 'widgets/booking_policy_tab.dart';
import 'widgets/cancellation_policy_tab.dart';

class PoliciesScreen extends StatefulWidget {
  final int initialTabIndex;

  const PoliciesScreen({super.key, this.initialTabIndex = 0});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    const goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFF091210),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF0F1B18).withValues(alpha: 0.95),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.white70,
              ),
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
              style: GoogleFonts.italiana(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(
                  Icons.track_changes_rounded,
                  size: 16,
                  color: Colors.white70,
                ),
                label: Text(
                  "TRACK BOOKING",
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                  labelStyle: AppTheme.sansBody(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  unselectedLabelStyle: AppTheme.sansBody(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: const [
                    Tab(text: "BOOKING POLICY"),
                    Tab(text: "CANCELLATION & REFUNDS"),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              final bizDetails = BusinessDetailsService.to.rxDetails.value;
              final bookingSettings =
                  AppConfigService.to.rxBookingSettings.value;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 80 : 20,
                  vertical: 36,
                ),
                child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    if (_tabController.index == 0) {
                      return BookingPolicyTab(
                        bizDetails: bizDetails,
                        bookingSettings: bookingSettings,
                        goldColor: goldColor,
                      );
                    } else {
                      return CancellationPolicyTab(
                        bizDetails: bizDetails,
                        bookingSettings: bookingSettings,
                        goldColor: goldColor,
                      );
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
}
