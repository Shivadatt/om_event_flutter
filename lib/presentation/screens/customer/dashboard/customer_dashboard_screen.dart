import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/feature_flags.dart';
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

import '../../../../core/config/app_routes.dart';
import '../../../../core/utils/auth_route_helper.dart';

/// Desktop/Mobile layout orchestrator for the Client Portal.
class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final controller = Get.find<CustomerDashboardController>();
  final authController = Get.find<CustomerAuthController>();
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (AuthRouteHelper.isCurrentAdminOrStaff()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.adminDashboard);
      });
      return;
    }
    if (authController.rxCustomerBootstrapped.value &&
        authController.isSessionExpired()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authController.handleSessionExpired();
      });
      return;
    }
    _checkInitialTab();
    controller.ensureProfileLoaded();
  }

  void _checkInitialTab() {
    try {
      final currentRoute = Get.currentRoute.toLowerCase();
      if (currentRoute.contains('notifications')) {
        if (FeatureFlags.notifications) {
          selectedIndex = 7;
          return;
        } else {
          selectedIndex = 0;
          return;
        }
      }
      final tabParam = Get.parameters['tab']?.toLowerCase() ?? Get.parameters['view']?.toLowerCase();
      if (tabParam != null) {
        if (tabParam == 'notifications' || tabParam == '7') {
          if (FeatureFlags.notifications) {
            selectedIndex = 7;
          } else {
            selectedIndex = 0;
          }
        } else if (tabParam == 'inquiries' || tabParam == '1') {
          selectedIndex = 1;
        } else if (tabParam == 'quotes' || tabParam == '2') {
          selectedIndex = 2;
        } else if (tabParam == 'gallery' || tabParam == '5') {
          selectedIndex = 5;
        } else if (tabParam == 'wishlist' || tabParam == '6') {
          selectedIndex = 6;
        } else if (tabParam == 'profile' || tabParam == '8') {
          selectedIndex = 8;
        } else if (tabParam == 'support' || tabParam == '9') {
          selectedIndex = 9;
        } else if (tabParam == 'legal' || tabParam == '10') {
          selectedIndex = 10;
        } else if (tabParam == 'preferences' || tabParam == '11') {
          selectedIndex = 11;
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (AuthRouteHelper.isCurrentAdminOrStaff()) {
      return const Scaffold(
        backgroundColor: Color(0xFF070C0A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1024;
    final bool isTablet = width >= 600 && width < 1024;
    final bool isMobile = width < 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF070C0A),
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xFF09120E),
              child: SafeArea(
                child: DashboardSidebar(
                  controller: controller,
                  selectedIndex: selectedIndex,
                  isDrawer: true,
                  onIndexChanged: (i) {
                    Navigator.of(context).pop();
                    final targetIndex = (!FeatureFlags.notifications && i == 7) ? 0 : i;
                    if (mounted) setState(() => selectedIndex = targetIndex);
                  },
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          _buildAmbientBackground(),
          Row(
            children: [
              // Desktop & Laptop: Full-height sidebar (195px desktop, 180px laptop)
              if (isDesktop)
                DashboardSidebar(
                  controller: controller,
                  selectedIndex: selectedIndex,
                  width: width >= 1200 ? 195 : 180,
                  onIndexChanged: (i) {
                    final targetIndex = (!FeatureFlags.notifications && i == 7) ? 0 : i;
                    if (mounted) setState(() => selectedIndex = targetIndex);
                  },
                )
              // Tablet: Compact 64px icon rail with OE monogram & tooltips
              else if (isTablet)
                DashboardSidebar(
                  controller: controller,
                  selectedIndex: selectedIndex,
                  isCompactRail: true,
                  onIndexChanged: (i) {
                    final targetIndex = (!FeatureFlags.notifications && i == 7) ? 0 : i;
                    if (mounted) setState(() => selectedIndex = targetIndex);
                  },
                ),
              // Mobile: Navigation accessed via hamburger menu & off-canvas drawer

              // Main application content occupying remaining viewport width
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardTopBar(
                      controller: controller,
                      onLogout: _showLogoutConfirmation,
                      onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                      isMobile: isMobile,
                      isTablet: isTablet,
                      onNavToNotifications: (i) {
                        if (!FeatureFlags.notifications && i == 7) {
                          if (mounted) setState(() => selectedIndex = 0);
                          return;
                        }
                        if (mounted) setState(() => selectedIndex = i);
                      },
                    ),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value && controller.rxProfile.value == null) {
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                          );
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
    );
  }

  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          _blurBlob(size: 600, color: AppColors.primaryAccent, top: -200, left: -100),
          _blurBlob(size: 500, color: AppColors.secondaryAccent, top: 250, right: -150),
          _blurBlob(size: 400, color: AppColors.highlight, top: 600, left: 200),
        ],
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
            colors: [
              color.withValues(alpha: 0.08),
              color.withValues(alpha: 0.03),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveView() {
    switch (selectedIndex) {
      case 0: return OverviewView(controller: controller);
      case 1: return LeadsView(controller: controller, onNewInquiryPressed: _showNewInquiryDialog);
      case 2: return QuotesView(controller: controller, onRequestRevision: _showRevisionDialog);
      case 5: return GalleryView(controller: controller);
      case 6:
        return WishlistView(
          controller: controller,
          onExploreGallery: () {
            if (mounted) setState(() => selectedIndex = 5);
          },
        );
      case 7:
        if (!FeatureFlags.notifications) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => selectedIndex = 0);
          });
          return OverviewView(controller: controller);
        }
        return NotificationsView(controller: controller);
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
    Get.dialog(
      NewInquiryDialog(
        controller: controller,
        onSuccess: () {
          setState(() {
            selectedIndex = 1;
          });
        },
      ),
    );
  }

  void _showRevisionDialog(String quoteId) {
    // TEMP DISABLED - OM EVENTS ADVANCED FEATURE
    // REASON: Not required for current business flow.
    // DO NOT DELETE - Keep for future reactivation.
    if (!FeatureFlags.quotationRevisions) {
      Get.snackbar(
        "Revision Requests",
        "Direct revision requests are temporarily disabled. Please contact us via WhatsApp to discuss customizations.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.dialog(RevisionRequestDialog(quoteId: quoteId, controller: controller));
  }
}
