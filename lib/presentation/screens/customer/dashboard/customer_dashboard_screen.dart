import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
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

  Widget buildBlurBlob({
    required double size,
    required Color color,
    required double top,
    double? left,
    double? right,
  }) {
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
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF171411),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x33D4AF37), width: 1.5),
        ),
        title: Text(
          "LOG OUT",
          style: AppTheme.serifHeader(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        content: Text(
          "Are you sure you want to exit the customer lounge?",
          style: AppTheme.sansBody(fontSize: 14, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              authController.logout();
            },
            child: const Text("CONFIRM", style: TextStyle(color: Color(0xFF091210), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1000;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0D0B), // Matte Black base
      body: Stack(
        children: [
          // Ambient luxury lighting background (vignette)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 130.0, sigmaY: 130.0),
              child: Stack(
                children: [
                  buildBlurBlob(size: 600, color: AppColors.primaryAccent, top: -200, left: -100),
                  buildBlurBlob(size: 500, color: AppColors.secondaryAccent, top: 250, right: -150),
                  buildBlurBlob(size: 400, color: AppColors.highlight, top: 600, left: 200),
                ],
              ),
            ),
          ),

          // Main orchestrator
          Column(
            children: [
              // Premium Top Bar
              _buildTopBar(context),
              Expanded(
                child: Row(
                  children: [
                    if (isDesktop) _buildSidebar(context),
                    Expanded(
                      child: Obx(() {
                        if (controller.rxProfile.value == null) {
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
      bottomNavigationBar: !isDesktop ? _buildBottomNavBar() : null,
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Color(0x1AD4AF37), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting & Logo Brand
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 20),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Get.back();
                  } else {
                    Get.offAllNamed(AppRoutes.home);
                  }
                },
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "OM EVENTS",
                    style: GoogleFonts.italiana(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD4AF37),
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(
                    "CLIENT LOUNGE",
                    style: AppTheme.sansBody(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // User tier summary & notification/logout controls
          Obx(() {
            final profile = controller.rxProfile.value;
            final unread = controller.rxNotifications.where((n) => !n.isRead).length;

            return Row(
              children: [
                if (profile != null) ...[
                  // Reward Points Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x1AD4AF37),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x33D4AF37)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_outlined, color: Color(0xFFD4AF37), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          "1,500 PTS",
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Membership Tier
                  Text(
                    "PLATINUM TIER",
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE6C98D),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],

                // Notification Center Icon
                IconButton(
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text(unread.toString(), style: const TextStyle(fontSize: 9, color: Colors.black)),
                    backgroundColor: const Color(0xFFD4AF37),
                    child: const Icon(Icons.notifications_none_outlined, color: Colors.white70, size: 22),
                  ),
                  onPressed: () => setState(() => selectedIndex = 7),
                ),
                const SizedBox(width: 8),

                // Logout
                IconButton(
                  icon: const Icon(Icons.logout_outlined, color: Colors.white70, size: 20),
                  onPressed: _showLogoutConfirmation,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 270,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF171411), // Graphite / Ebony
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x22D4AF37), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Customer luxury profile card
          Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(() {
              final profile = controller.rxProfile.value;
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF2A241F),
                      backgroundImage: profile?.profileImageUrl.isNotEmpty == true
                          ? NetworkImage(profile!.profileImageUrl)
                          : null,
                      child: profile?.profileImageUrl.isEmpty == true
                          ? const Icon(Icons.person_outline, size: 40, color: Color(0xFFD4AF37))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile?.fullName.toUpperCase() ?? "CLIENT",
                    style: GoogleFonts.italiana(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.email ?? "",
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }),
          ),
          const Divider(color: Color(0x1AD4AF37), height: 1),

          // Menu navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              children: [
                _SidebarTile(title: "Overview", icon: Icons.dashboard_outlined, isActive: selectedIndex == 0, onTap: () => setState(() => selectedIndex = 0)),
                _SidebarTile(title: "Inquiries", icon: Icons.assignment_outlined, isActive: selectedIndex == 1, onTap: () => setState(() => selectedIndex = 1)),
                _SidebarTile(title: "Quotations", icon: Icons.description_outlined, isActive: selectedIndex == 2, onTap: () => setState(() => selectedIndex = 2)),
                _SidebarTile(title: "Event Gallery", icon: Icons.photo_library_outlined, isActive: selectedIndex == 5, onTap: () => setState(() => selectedIndex = 5)),
                _SidebarTile(title: "Wishlist", icon: Icons.favorite_border, isActive: selectedIndex == 6, onTap: () => setState(() => selectedIndex = 6)),
                _SidebarTile(title: "Notifications", icon: Icons.notifications_none_outlined, isActive: selectedIndex == 7, onTap: () => setState(() => selectedIndex = 7)),
                _SidebarTile(title: "Profile Settings", icon: Icons.person_outline, isActive: selectedIndex == 8, onTap: () => setState(() => selectedIndex = 8)),
                _SidebarTile(title: "Concierge Support", icon: Icons.contact_support_outlined, isActive: selectedIndex == 9, onTap: () => setState(() => selectedIndex = 9)),
                _SidebarTile(title: "Office Maps & Legal", icon: Icons.gavel_outlined, isActive: selectedIndex == 10, onTap: () => setState(() => selectedIndex = 10)),
                _SidebarTile(title: "Alert Preferences", icon: Icons.settings_outlined, isActive: selectedIndex == 11, onTap: () => setState(() => selectedIndex = 11)),
              ],
            ),
          ),
        ],
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
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Overview"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Inquiries"),
        BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: "Quotes"),
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
    final budgetCtrl = TextEditingController();
    String selectedBranch = 'Ahmedabad';
    DateTime eventDate = DateTime.now().add(const Duration(days: 7));

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              width: 500,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1D1916), // Dark warm bronze
                    Color(0xFF0F0D0C), // Ebonized dark chocolate
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header
                  Text(
                    "NEW DESIGN INQUIRY",
                    style: GoogleFonts.italiana(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Submit details to consult our curation coordinators",
                    style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0x1AD4AF37), height: 1),
                  const SizedBox(height: 24),

                  // Service Required input field
                  _buildDialogFieldLabel("Service Required"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: serviceCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _buildInputDecoration(
                      hint: "e.g., Wedding Mandap, Reception Decor, Birthday Backdrop",
                      icon: Icons.celebration_outlined,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Row: Branch Location & Target Budget
                  Row(
                    children: [
                      // Branch Location (Dropdown)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogFieldLabel("Branch Location"),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              dropdownColor: const Color(0xFF171411),
                              value: selectedBranch,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: _buildInputDecoration(
                                hint: "Select Branch",
                                icon: Icons.business_outlined,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Ahmedabad', child: Text("Ahmedabad")),
                                DropdownMenuItem(value: 'Kadi', child: Text("Kadi")),
                                DropdownMenuItem(value: 'Thangadh', child: Text("Thangadh")),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedBranch = val;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Target Budget
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogFieldLabel("Approx. Budget (INR)"),
                            const SizedBox(height: 8),
                            TextField(
                              controller: budgetCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: _buildInputDecoration(
                                hint: "e.g., 50000",
                                icon: Icons.currency_rupee,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Event Date (Date Picker Trigger Box)
                  _buildDialogFieldLabel("Target Event Date"),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final chosen = await showDatePicker(
                        context: context,
                        initialDate: eventDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFFD4AF37),
                                onPrimary: Color(0xFF091210),
                                surface: Color(0xFF171411),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (chosen != null) {
                        setDialogState(() {
                          eventDate = chosen;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined, color: Color(0xFFD4AF37), size: 18),
                              const SizedBox(width: 12),
                              Text(
                                "${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
                                style: AppTheme.sansBody(fontSize: 14, color: Colors.white70),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.white38),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "CANCEL",
                          style: AppTheme.sansBody(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white60,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: const Color(0xFF091210),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          elevation: 4,
                        ),
                        onPressed: () {
                          final budget = double.tryParse(budgetCtrl.text) ?? 0.0;
                          controller.submitLead(
                            service: serviceCtrl.text,
                            branch: selectedBranch,
                            budget: budget,
                            eventDate: eventDate,
                          );
                          Get.back();
                          Get.snackbar(
                            "Inquiry Submitted",
                            "Your design consultation request has been successfully created.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF171411),
                            colorText: const Color(0xFFD4AF37),
                          );
                        },
                        child: const Text("SUBMIT CONSULTATION"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showRevisionDialog(String quoteId) {
    final revisionCtrl = TextEditingController();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1D1916),
                Color(0xFF0F0D0C),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35), width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "REQUEST REVISION",
                style: GoogleFonts.italiana(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
              ),
              const SizedBox(height: 4),
              Text("Describe any modifications required for this quotation proposal", style: AppTheme.sansBody(fontSize: 11, color: Colors.white54)),
              const SizedBox(height: 24),
              const Divider(color: Color(0x1AD4AF37), height: 1),
              const SizedBox(height: 24),
              _buildDialogFieldLabel("Revision Details"),
              const SizedBox(height: 8),
              TextField(
                controller: revisionCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _buildInputDecoration(
                  hint: "Describe colors, specific changes, prop items, or timeline modifications...",
                  icon: Icons.edit_note,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text("CANCEL", style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1.0)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF091210),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
                      elevation: 4,
                    ),
                    onPressed: () {
                      controller.requestRevision(quoteId, revisionCtrl.text);
                      Get.back();
                      Get.snackbar(
                        "Revision Requested",
                        "Your feedback was submitted to the design coordinators.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF171411),
                        colorText: const Color(0xFFD4AF37),
                      );
                    },
                    child: const Text("SUBMIT REQUEST"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogFieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: AppTheme.sansBody(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFD4AF37),
        letterSpacing: 1.0,
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
      filled: true,
      fillColor: Colors.black26,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4AF37)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isActive
            ? const LinearGradient(
                colors: [
                  Color(0x33D4AF37),
                  Color(0x0AD4AF37),
                ],
              )
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFFD4AF37) : Colors.white60,
          size: 20,
        ),
        title: Text(
          title,
          style: AppTheme.sansBody(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFFD4AF37) : Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
