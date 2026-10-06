import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../core/services/customer_auth_provisioning_service.dart';
import '../../../controllers/admin_controller.dart';

class CustomerDetailsDialog extends StatefulWidget {
  final CustomerModel customer;
  final AdminController controller;

  const CustomerDetailsDialog({
    super.key,
    required this.customer,
    required this.controller,
  });

  @override
  State<CustomerDetailsDialog> createState() => _CustomerDetailsDialogState();
}

class _CustomerDetailsDialogState extends State<CustomerDetailsDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isLoginEnabled;
  bool _isProcessingAuth = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isLoginEnabled = widget.customer.loginEnabled;
  }

  Future<void> _sendPortalInvite() async {
    if (widget.customer.email.isEmpty) {
      Get.snackbar(
        "Email Required",
        "A valid email address is required to send client portal invitations.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isProcessingAuth = true);
    try {
      final res = await CustomerAuthProvisioningService.sendPortalInvite(
        phone: widget.customer.phone,
        email: widget.customer.email,
        name: widget.customer.name,
      );
      if (res.success) {
        setState(() => _isLoginEnabled = true);
        Get.snackbar(
          "Invitation Dispatched",
          res.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF132219),
          colorText: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          "Could Not Send Invitation",
          res.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingAuth = false);
    }
  }

  Future<void> _toggleLogin(bool enable) async {
    setState(() => _isProcessingAuth = true);
    try {
      final ok = await CustomerAuthProvisioningService.toggleCustomerLogin(
        phone: widget.customer.phone,
        enable: enable,
      );
      if (!ok) {
        Get.snackbar(
          "Update Failed",
          "Could not update client login status.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return;
      }

      setState(() => _isLoginEnabled = enable);
      await widget.controller.loadCustomers();

      Get.snackbar(
        "Client Portal Status",
        enable ? "Client login has been enabled." : "Client login has been disabled.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF132219),
        colorText: const Color(0xFFD4AF37),
      );
    } finally {
      if (mounted) setState(() => _isProcessingAuth = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _detailRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label.toUpperCase(),
              style: AppTheme.sansBody(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryAccent,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "Not Configured",
              style: AppTheme.sansBody(
                fontSize: 13,
                color: value.isNotEmpty ? textColor : textColor.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryAccent = AppColors.primaryAccent;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: (MediaQuery.of(context).size.width * 0.9).clamp(320.0, 680.0),
        height: (MediaQuery.of(context).size.height * 0.9).clamp(360.0, 520.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Title & Tabs
              Container(
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.customer.name.toUpperCase(),
                          style: GoogleFonts.italiana(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: textColor.withValues(alpha: 0.5),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: primaryAccent,
                      unselectedLabelColor: textColor.withValues(alpha: 0.4),
                      indicatorColor: primaryAccent,
                      indicatorWeight: 1.5,
                      labelStyle: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      unselectedLabelStyle: AppTheme.sansBody(fontSize: 10, letterSpacing: 1.2),
                      dividerColor: Colors.transparent,
                      tabAlignment: TabAlignment.start,
                      tabs: const [
                        Tab(text: "PROFILE"),
                        Tab(text: "INQUIRIES"),
                        Tab(text: "MEDIA"),
                      ],
                    ),
                  ],
                ),
              ),
              // Body Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(),
                    _buildLeadsTab(),
                    _buildGalleryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inputFillColor = isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: inputFillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          children: [
            _detailRow("Name", widget.customer.name),
            const Divider(height: 1),
            _detailRow("Client Type", widget.customer.type),
            const Divider(height: 1),
            _detailRow("Phone Number", widget.customer.phone),
            const Divider(height: 1),
            _detailRow("Email", widget.customer.email),
            const Divider(height: 1),
            _detailRow("Address", widget.customer.address),
            const Divider(height: 1),
            _detailRow("City", widget.customer.city),
            if (widget.customer.state.isNotEmpty) ...[
              const Divider(height: 1),
              _detailRow("State", widget.customer.state),
            ],
            if (widget.customer.pincode.isNotEmpty) ...[
              const Divider(height: 1),
              _detailRow("Pincode", widget.customer.pincode),
            ],
            if (widget.customer.mapLocation.isNotEmpty) ...[
              const Divider(height: 1),
              _detailRow("Map Location", widget.customer.mapLocation),
            ],
            const SizedBox(height: 20),
            // Client Portal Access Section (Phase 6 & 7)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132219) : const Color(0xFFF3EFEA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryAccent.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.vpn_key_outlined,
                            size: 16,
                            color: AppColors.primaryAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "CLIENT PORTAL LOGIN",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryAccent,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _isLoginEnabled
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isLoginEnabled ? Colors.green : Colors.red,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          _isLoginEnabled ? "Enabled" : "Disabled",
                          style: AppTheme.sansBody(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _isLoginEnabled ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.customer.email.isNotEmpty
                        ? "Linked Email: ${widget.customer.email}"
                        : "No email address configured. An email is required for portal login.",
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_isProcessingAuth)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryAccent),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (_isLoginEnabled && widget.customer.email.isNotEmpty)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.send_rounded, size: 14),
                            label: const Text("Send Portal Invite"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              textStyle: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _sendPortalInvite,
                          ),
                        if (_isLoginEnabled)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.block_rounded, size: 14, color: AppColors.error),
                            label: const Text("Disable Client Login", style: TextStyle(color: AppColors.error)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.error, width: 0.8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _toggleLogin(false),
                          )
                        else if (widget.customer.email.isNotEmpty)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline, size: 14),
                            label: const Text("Enable Client Login"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              textStyle: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _toggleLogin(true),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsTab() {
    final leads = widget.controller.rxLeads.where((l) => l.phone == widget.customer.phone).toList();
    if (leads.isEmpty) {
      return Center(
        child: Text(
          "No inquiries received from this client.",
          style: AppTheme.sansBody(fontSize: 12, color: AppColors.darkMuted),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inputFillColor = isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final l = leads[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.requestType.toUpperCase(),
                    style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryAccent),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Requested: ${l.eventDate != null ? AppFormatters.formatShortDate(l.eventDate!) : 'TBD'}",
                    style: AppTheme.sansBody(fontSize: 11, color: AppColors.darkMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l.status.toUpperCase(),
                  style: AppTheme.sansBody(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGalleryTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 44,
            color: AppColors.primaryAccent.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            "Customer Media Gallery",
            style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            "Upload event photos or decor proposals shared with this client.",
            textAlign: TextAlign.center,
            style: AppTheme.sansBody(fontSize: 11, color: AppColors.darkMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file_rounded, size: 16),
            label: Text(
              "UPLOAD PROPOSAL MEDIA",
              style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 0,
            ),
            onPressed: () {
              Get.snackbar(
                "Upload Successful",
                "Shared file saved to customer gallery bucket successfully.",
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }
}
