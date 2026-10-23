import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/customer_model.dart';
import '../../../controllers/admin_controller.dart';
import 'client_portal_auth_handler.dart';
import 'client_portal_login_card.dart';
import 'client_profile_details_card.dart';
import 'client_profile_dialog_header.dart';
import 'client_profile_inquiries_tab.dart';
import 'client_profile_media_tab.dart';

typedef ClientProfileDialog = CustomerDetailsDialog;

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

class _CustomerDetailsDialogState extends State<CustomerDetailsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isLoginEnabled;
  bool _isProcessingAuth = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isLoginEnabled = widget.customer.loginEnabled;
  }

  @override
  void didUpdateWidget(CustomerDetailsDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customer.loginEnabled != widget.customer.loginEnabled) {
      _isLoginEnabled = widget.customer.loginEnabled;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleSendInvite() {
    ClientPortalAuthHandler.sendPortalInvite(
      context: context,
      customer: widget.customer,
      onLoading: (val) => setState(() => _isProcessingAuth = val),
      onSuccess: () => setState(() => _isLoginEnabled = true),
    );
  }

  void _handleToggleLogin(bool enable) {
    ClientPortalAuthHandler.confirmAndToggleLogin(
      context: context,
      customer: widget.customer,
      enable: enable,
      controller: widget.controller,
      onLoading: (val) => setState(() => _isProcessingAuth = val),
      onStatusChanged: (val) => setState(() => _isLoginEnabled = val),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isMobile = screenWidth < 600;

    final dialogWidth = isMobile
        ? (screenWidth - 24).clamp(300.0, 360.0)
        : (screenWidth < 900
            ? (screenWidth * 0.85).clamp(420.0, 620.0)
            : 680.0);
    final dialogHeight =
        (screenHeight * (isMobile ? 0.92 : 0.88)).clamp(400.0, 720.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: 16,
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(isMobile ? 20 : 28),
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
          borderRadius: BorderRadius.circular(isMobile ? 20 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClientProfileDialogHeader(
                clientName: widget.customer.name,
                tabController: _tabController,
                isMobile: isMobile,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 16 : 28),
                      child: Column(
                        children: [
                          ClientProfileDetailsCard(
                            customer: widget.customer,
                            isMobile: isMobile,
                          ),
                          const SizedBox(height: 16),
                          ClientPortalLoginCard(
                            customer: widget.customer,
                            isLoginEnabled: _isLoginEnabled,
                            isProcessing: _isProcessingAuth,
                            isMobile: isMobile,
                            onSendInvite: _handleSendInvite,
                            onToggleLogin: _handleToggleLogin,
                          ),
                        ],
                      ),
                    ),
                    ClientProfileInquiriesTab(
                      customer: widget.customer,
                      controller: widget.controller,
                      isMobile: isMobile,
                    ),
                    ClientProfileMediaTab(
                      isMobile: isMobile,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
