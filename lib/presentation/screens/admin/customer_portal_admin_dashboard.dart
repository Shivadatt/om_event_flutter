import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_customer_portal_controller.dart';
import '../../controllers/admin_controller.dart';
import 'customer_portal_admin_dashboard/views/quotes_admin_view.dart';
import 'customer_portal_admin_dashboard/views/payments_admin_view.dart';
import 'customer_portal_admin_dashboard/views/timelines_admin_view.dart';
import 'customer_portal_admin_dashboard/views/notifications_admin_view.dart';
import 'customer_portal_admin_dashboard/views/rebooks_admin_view.dart';
import 'customer_portal_admin_dashboard/views/offers_admin_view.dart';
import 'customer_portal_admin_dashboard/views/search_logs_admin_view.dart';
import 'customer_portal_admin_dashboard/views/homepage_builder_admin_view.dart';
import 'customer_portal_admin_dashboard/views/coordinators_admin_view.dart';
import 'customer_portal_admin_dashboard/views/reschedules_admin_view.dart';
import 'customer_portal_admin_dashboard/views/inventory_cms_view.dart';
import 'customer_portal_admin_dashboard/views/staff_finance_view.dart';

/// Unified control panel orchestrator for portal administration.
class CustomerPortalAdminDashboard extends StatefulWidget {
  const CustomerPortalAdminDashboard({super.key});

  @override
  State<CustomerPortalAdminDashboard> createState() => _CustomerPortalAdminDashboardState();
}

class _CustomerPortalAdminDashboardState extends State<CustomerPortalAdminDashboard> with SingleTickerProviderStateMixin {
  late TabController tabController;
  final portalController = Get.find<AdminCustomerPortalController>();
  final adminController = Get.find<AdminController>();

  final enabledSections = {
    'Hero Banner': true,
    'About Us': true,
    'Services List': true,
    'Decoration Categories': true,
    'Event Gallery': true,
    'Testimonials / Reviews': true,
    'FAQ': true,
    'Contact Form': true,
  }.obs;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 12, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091210),
      appBar: AppBar(
        title: Text("Client Portal Administration", style: AppTheme.serifHeader(fontSize: 20)),
        backgroundColor: const Color(0xFF12271F),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: const Color(0xFFC9A77E),
          unselectedLabelColor: Colors.white60,
          indicatorColor: const Color(0xFFC9A77E),
          tabs: const [
            Tab(text: "Quotes Management"),
            Tab(text: "Payments Verification"),
            Tab(text: "Booking Timelines"),
            Tab(text: "Notification Broadcasts"),
            Tab(text: "Rebook Requests"),
            Tab(text: "Offers CMS"),
            Tab(text: "Global Search & Logs"),
            Tab(text: "Homepage Builder"),
            Tab(text: "Coordinator CMS"),
            Tab(text: "Reschedule Requests"),
            Tab(text: "Inventory CMS"),
            Tab(text: "Staff & Finances"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          QuotesAdminView(portalController: portalController),
          PaymentsAdminView(portalController: portalController),
          TimelinesAdminView(portalController: portalController),
          NotificationsAdminView(portalController: portalController),
          RebooksAdminView(portalController: portalController),
          OffersAdminView(portalController: portalController),
          SearchLogsAdminView(portalController: portalController),
          HomepageBuilderAdminView(enabledSections: enabledSections),
          CoordinatorsAdminView(portalController: portalController),
          ReschedulesAdminView(portalController: portalController),
          InventoryCmsView(portalController: portalController),
          StaffFinanceView(portalController: portalController),
        ],
      ),
    );
  }
}
