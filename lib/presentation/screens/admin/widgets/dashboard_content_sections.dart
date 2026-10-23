import 'package:flutter/material.dart';
import '../../../controllers/admin_controller.dart';
import 'dashboard_recent_bookings.dart';
import 'dashboard_upcoming_events.dart';
import 'inquiries_trend_chart.dart';
import 'recent_inquiries_widget.dart';

/// Middle dashboard section containing Booking Trend and Latest Inquiries.
/// Renders 7:3 side-by-side on wide screens (>950px), and stacks on tablet/mobile.
class DashboardAnalyticsSection extends StatelessWidget {
  final AdminController controller;

  const DashboardAnalyticsSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 950) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 7,
                child: InquiriesTrendChart(),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 3,
                child: RecentInquiriesWidget(controller: controller),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              const InquiriesTrendChart(),
              const SizedBox(height: 18),
              RecentInquiriesWidget(controller: controller),
            ],
          );
        }
      },
    );
  }
}

/// Lower dashboard section containing Upcoming Celebrations and Recent Bookings.
/// Renders 1:1 side-by-side on tablet/desktop (>620px), and stacks on mobile.
class DashboardEventsAndBookingsSection extends StatelessWidget {
  const DashboardEventsAndBookingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 620) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: DashboardUpcomingEvents()),
              SizedBox(width: 18),
              Expanded(child: DashboardRecentBookings()),
            ],
          );
        } else {
          return const Column(
            children: [
              DashboardUpcomingEvents(),
              SizedBox(height: 18),
              DashboardRecentBookings(),
            ],
          );
        }
      },
    );
  }
}
