import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../controllers/customer_dashboard_controller.dart';
import '../../../controllers/customer_auth_controller.dart';
import 'views/overview_view.dart';
import 'views/leads_view.dart';
import 'views/quotes_view.dart';
import 'views/bookings_view.dart';
import 'views/payments_view.dart';
import 'views/gallery_view.dart';
import 'views/wishlist_view.dart';
import 'views/notifications_view.dart';
import 'views/profile_view.dart';
import 'views/support_center_view.dart';
import 'views/maps_agreements_view.dart';
import 'views/preferences_view.dart';

/// Desktop/Mobile layout orchestrator for the Client Portal.
class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final controller = Get.find<CustomerDashboardController>();
  final authController = Get.find<CustomerAuthController>();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1000;

    return Scaffold(
      backgroundColor: const Color(0xFF091210),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC9A77E)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAllNamed(AppRoutes.home);
            }
          },
        ),
        title: Text("Client Portal", style: AppTheme.serifHeader(fontSize: 20)),
        backgroundColor: const Color(0xFF12271F),
        actions: [
          Obx(() {
            final unread = controller.rxNotifications.where((n) => !n.isRead).length;
            return IconButton(
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text(unread.toString()),
                child: const Icon(Icons.notifications_none, color: Color(0xFFC9A77E)),
              ),
              onPressed: () => setState(() => selectedIndex = 7),
            );
          }),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFC9A77E)),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Obx(() {
              if (controller.rxProfile.value == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFC9A77E)),
                );
              }
              return _buildActiveView();
            }),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop ? _buildBottomNavBar() : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFF12271F),
      child: ListView(
        children: [
          const SizedBox(height: 24),
          Obx(() {
            final profile = controller.rxProfile.value;
            return Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFC9A77E).withValues(alpha: 0.2),
                  backgroundImage: profile?.profileImageUrl.isNotEmpty == true
                      ? NetworkImage(profile!.profileImageUrl)
                      : null,
                  child: profile?.profileImageUrl.isEmpty == true
                      ? const Icon(Icons.person, size: 36, color: Color(0xFFC9A77E))
                      : null,
                ),
                const SizedBox(height: 8),
                Text(profile?.fullName ?? "Client", style: AppTheme.serifHeader(fontSize: 15)),
                Text(profile?.email ?? "", style: AppTheme.sansBody(fontSize: 11, color: Colors.white54)),
              ],
            );
          }),
          const SizedBox(height: 24),
          _SidebarTile(title: "Overview", icon: Icons.dashboard_outlined, isActive: selectedIndex == 0, onTap: () => setState(() => selectedIndex = 0)),
          _SidebarTile(title: "Inquiries", icon: Icons.assignment_outlined, isActive: selectedIndex == 1, onTap: () => setState(() => selectedIndex = 1)),
          _SidebarTile(title: "Quotations", icon: Icons.description_outlined, isActive: selectedIndex == 2, onTap: () => setState(() => selectedIndex = 2)),
          _SidebarTile(title: "Bookings", icon: Icons.event_available, isActive: selectedIndex == 3, onTap: () => setState(() => selectedIndex = 3)),
          _SidebarTile(title: "Payments", icon: Icons.payment_outlined, isActive: selectedIndex == 4, onTap: () => setState(() => selectedIndex = 4)),
          _SidebarTile(title: "Event Gallery", icon: Icons.photo_library_outlined, isActive: selectedIndex == 5, onTap: () => setState(() => selectedIndex = 5)),
          _SidebarTile(title: "Wishlist", icon: Icons.favorite_border, isActive: selectedIndex == 6, onTap: () => setState(() => selectedIndex = 6)),
          _SidebarTile(title: "Notifications", icon: Icons.notifications_none, isActive: selectedIndex == 7, onTap: () => setState(() => selectedIndex = 7)),
          _SidebarTile(title: "Profile Settings", icon: Icons.person_outline, isActive: selectedIndex == 8, onTap: () => setState(() => selectedIndex = 8)),
          _SidebarTile(title: "Support Desk", icon: Icons.contact_support_outlined, isActive: selectedIndex == 9, onTap: () => setState(() => selectedIndex = 9)),
          _SidebarTile(title: "Maps & Legal Agreements", icon: Icons.gavel_outlined, isActive: selectedIndex == 10, onTap: () => setState(() => selectedIndex = 10)),
          _SidebarTile(title: "Notification Preferences", icon: Icons.settings_outlined, isActive: selectedIndex == 11, onTap: () => setState(() => selectedIndex = 11)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF12271F),
      selectedItemColor: const Color(0xFFC9A77E),
      unselectedItemColor: Colors.white54,
      currentIndex: selectedIndex > 4 ? 4 : selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => setState(() => selectedIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Overview"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Inquiries"),
        BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: "Quotes"),
        BottomNavigationBarItem(icon: Icon(Icons.event_available), label: "Bookings"),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: "More"),
      ],
    );
  }

  Widget _buildActiveView() {
    switch (selectedIndex) {
      case 0:
        return OverviewView(controller: controller);
      case 1:
        return LeadsView(controller: controller, onNewInquiryPressed: _showNewInquiryDialog);
      case 2:
        return QuotesView(controller: controller, onRequestRevision: _showRevisionDialog);
      case 3:
        return BookingsView(controller: controller, onRebookPressed: _showRebookDialog, onWriteReviewPressed: _showReviewDialog);
      case 4:
        return PaymentsView(controller: controller);
      case 5:
        return GalleryView(controller: controller);
      case 6:
        return WishlistView(controller: controller);
      case 7:
        return NotificationsView(controller: controller);
      case 8:
        return ProfileView(controller: controller);
      case 9:
        return SupportCenterView(controller: controller);
      case 10:
        return MapsAgreementsView(controller: controller);
      case 11:
        return PreferencesView(controller: controller);
      default:
        return const SizedBox.shrink();
    }
  }

  void _showNewInquiryDialog() {
    final serviceCtrl = TextEditingController();
    final branchCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    DateTime eventDate = DateTime.now().add(const Duration(days: 7));

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF12271F),
        title: Text("New Event Inquiry", style: AppTheme.serifHeader(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: serviceCtrl,
              decoration: const InputDecoration(labelText: "Service Required", labelStyle: TextStyle(color: Color(0xFFC9A77E))),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: branchCtrl,
              decoration: const InputDecoration(labelText: "Branch Location", labelStyle: TextStyle(color: Color(0xFFC9A77E))),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: budgetCtrl,
              decoration: const InputDecoration(labelText: "Budget (INR)", labelStyle: TextStyle(color: Color(0xFFC9A77E))),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
            onPressed: () {
              final budget = double.tryParse(budgetCtrl.text) ?? 0.0;
              controller.submitLead(service: serviceCtrl.text, branch: branchCtrl.text, budget: budget, eventDate: eventDate);
              Get.back();
            },
            child: const Text("Submit", style: TextStyle(color: Color(0xFF091210))),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(String bookingId) {
    final reviewCtrl = TextEditingController();
    double rating = 5.0;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF12271F),
        title: Text("Submit Event Review", style: AppTheme.serifHeader(fontSize: 20)),
        content: TextField(
          controller: reviewCtrl,
          decoration: const InputDecoration(labelText: "Your Experience", labelStyle: TextStyle(color: Color(0xFFC9A77E))),
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
            onPressed: () {
              controller.submitReview(bookingId: bookingId, reviewText: reviewCtrl.text, rating: rating);
              Get.back();
            },
            child: const Text("Submit", style: TextStyle(color: Color(0xFF091210))),
          ),
        ],
      ),
    );
  }

  void _showRevisionDialog(String quoteId) {
    final revisionCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF12271F),
        title: Text("Request Quotation Revision", style: AppTheme.serifHeader(fontSize: 20)),
        content: TextField(
          controller: revisionCtrl,
          decoration: const InputDecoration(labelText: "Revision Notes / Details", labelStyle: TextStyle(color: Color(0xFFC9A77E))),
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
            onPressed: () {
              controller.requestRevision(quoteId, revisionCtrl.text);
              Get.back();
            },
            child: const Text("Submit", style: TextStyle(color: Color(0xFF091210))),
          ),
        ],
      ),
    );
  }

  void _showRebookDialog(String bookingId) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF12271F),
        title: Text("Rebook Previous Event", style: AppTheme.serifHeader(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Reuse decoration setups and configs for a new date.", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            Text("Date: ${selectedDate.toLocal().toString().split(' ')[0]}", style: const TextStyle(color: Color(0xFFC9A77E), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
            onPressed: () {
              controller.requestRebook(bookingId, selectedDate);
              Get.back();
            },
            child: const Text("Submit Request", style: TextStyle(color: Color(0xFF091210))),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isActive ? const Color(0xFFC9A77E) : Colors.white70),
      title: Text(
        title,
        style: AppTheme.sansBody(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? const Color(0xFFC9A77E) : Colors.white70,
        ),
      ),
      selected: isActive,
      selectedTileColor: Colors.black12,
      onTap: onTap,
    );
  }
}
