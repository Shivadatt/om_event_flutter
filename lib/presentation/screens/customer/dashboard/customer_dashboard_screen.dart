import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../controllers/customer_dashboard_controller.dart';
import '../../../controllers/customer_auth_controller.dart';
import 'views/overview_view.dart';
import 'views/leads_view.dart';
import 'views/quotes_view.dart';
import 'views/gallery_view.dart';
import 'views/wishlist_view.dart';
import 'views/notifications_view.dart';
import 'views/profile_view.dart';
import 'views/support_center_view.dart';
import 'views/maps_agreements_view.dart';
import 'views/preferences_view.dart';
import 'widgets/dashboard_top_bar.dart';
import 'widgets/dashboard_sidebar.dart';
import 'widgets/new_inquiry_dialog.dart';
import 'widgets/revision_request_dialog.dart';

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
      backgroundColor: const Color(0xFF0F0D0B),
      body: Stack(
        children: [
          _buildAmbientBackground(),
          Column(
            children: [
              DashboardTopBar(
                controller: controller,
                onLogout: _showLogoutConfirmation,
                onNavToNotifications: (i) => setState(() => selectedIndex = i),
              ),
              Expanded(
                child: Row(
                  children: [
                    if (isDesktop)
                      DashboardSidebar(
                        controller: controller,
                        selectedIndex: selectedIndex,
                        onIndexChanged: (i) => setState(() => selectedIndex = i),
                      ),
                    Expanded(
                      child: Obx(() {
                        if (controller.rxProfile.value == null) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                        }
                        return _buildActiveView();
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop ? _buildBottomNavBar() : null,
    );
  }

  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 130.0, sigmaY: 130.0),
        child: Stack(
          children: [
            _blurBlob(size: 600, color: AppColors.primaryAccent, top: -200, left: -100),
            _blurBlob(size: 500, color: AppColors.secondaryAccent, top: 250, right: -150),
            _blurBlob(size: 400, color: AppColors.highlight, top: 600, left: 200),
          ],
        ),
      ),
    );
  }

  Widget _blurBlob({required double size, required Color color, required double top, double? left, double? right}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF171411),
      selectedItemColor: const Color(0xFFD4AF37),
      unselectedItemColor: Colors.white54,
      currentIndex: selectedIndex > 3 ? 3 : selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => setState(() => selectedIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Inquiries'),
        BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Quotes'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
      ],
    );
  }

  Widget _buildActiveView() {
    switch (selectedIndex) {
      case 0: return OverviewView(controller: controller);
      case 1: return LeadsView(controller: controller, onNewInquiryPressed: _showNewInquiryDialog);
      case 2: return QuotesView(controller: controller, onRequestRevision: _showRevisionDialog);
      case 5: return GalleryView(controller: controller);
      case 6: return WishlistView(controller: controller);
      case 7: return NotificationsView(controller: controller);
      case 8: return ProfileView(controller: controller);
      case 9: return SupportCenterView(controller: controller);
      case 10: return MapsAgreementsView(controller: controller);
      case 11: return PreferencesView(controller: controller);
      default: return const SizedBox.shrink();
    }
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF171411),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x33D4AF37), width: 1.5),
        ),
        title: const Text('LOG OUT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
        content: const Text('Are you sure you want to exit the customer lounge?', style: TextStyle(color: Colors.white70, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL', style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () { Get.back(); authController.logout(); },
            child: const Text('CONFIRM', style: TextStyle(color: Color(0xFF091210), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showNewInquiryDialog() {
    Get.dialog(NewInquiryDialog(controller: controller));
  }

  void _showRevisionDialog(String quoteId) {
    Get.dialog(RevisionRequestDialog(quoteId: quoteId, controller: controller));
  }
}
