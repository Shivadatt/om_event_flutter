import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import 'widgets/booking_tab_widget.dart';
import 'widgets/payment_tab_widget.dart';
import 'widgets/admin_back_button.dart';

class ManageBookingsScreen extends GetView<AdminController> {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const AdminBackButton(),
          title: Text(
            "BOOKINGS & PAYMENTS",
            style: AppTheme.sansBody(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
          bottom: const TabBar(
            tabs: [Tab(text: "BOOKINGS"), Tab(text: "PAYMENTS")],
            indicatorColor: Color(0xFFC8A26A),
            labelColor: Color(0xFFC8A26A),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            BookingTabWidget(controller: controller, isDark: isDark),
            PaymentTabWidget(controller: controller, isDark: isDark),
          ],
        ),
      ),
    );
  }
}
