import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_booking_controller.dart';
import '../../../controllers/admin_controller.dart';
import 'dashboard_kpi_card.dart';

/// Responsive 4-card summary/KPI section for the Admin Dashboard.
/// Renders 4 cards in 1 row on Desktop/Tablet, and in a 2x2 grid on Mobile.
class DashboardSummaryCards extends StatelessWidget {
  final AdminController controller;
  final bool isMobile;
  final bool isTablet;

  const DashboardSummaryCards({
    super.key,
    required this.controller,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bookingCtrl = Get.isRegistered<AdminBookingController>()
          ? Get.find<AdminBookingController>()
          : null;

      final card1 = DashboardKpiCard(
        label: "TOTAL BOOKINGS",
        value: (bookingCtrl?.totalCount.value ?? controller.quoteCount.value).toString(),
        trend: "▲ +12%",
        desc: "vs last month",
        icon: Icons.calendar_today_outlined,
        isCompact: isTablet,
      );

      final card2 = DashboardKpiCard(
        label: "PENDING ACTION",
        value: (bookingCtrl?.pendingCount.value ?? 0).toString(),
        trend: "▲ -1%",
        desc: "Requires your attention",
        icon: Icons.access_time_rounded,
        isCompact: isTablet,
      );

      final card3 = DashboardKpiCard(
        label: "CONFIRMED EVENTS",
        value: (bookingCtrl?.confirmedCount.value ?? 0).toString(),
        trend: null,
        desc: "This month",
        icon: Icons.check_circle_outline_rounded,
        isCompact: isTablet,
      );

      final card4 = DashboardKpiCard(
        label: "UPCOMING EVENTS",
        value: (bookingCtrl?.upcomingEventsCount.value ?? 0).toString(),
        trend: null,
        desc: "Next 30 days",
        icon: Icons.event_note_outlined,
        isCompact: isTablet,
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (width > 620) {
            // Desktop, Laptop, and Tablet: 4 cards in 1 row
            return Row(
              children: [
                Expanded(child: card1),
                SizedBox(width: width > 900 ? 14 : 8),
                Expanded(child: card2),
                SizedBox(width: width > 900 ? 14 : 8),
                Expanded(child: card3),
                SizedBox(width: width > 900 ? 14 : 8),
                Expanded(child: card4),
              ],
            );
          } else {
            // Mobile: 2x2 Grid
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 104,
              children: [card1, card2, card3, card4],
            );
          }
        },
      );
    });
  }
}
