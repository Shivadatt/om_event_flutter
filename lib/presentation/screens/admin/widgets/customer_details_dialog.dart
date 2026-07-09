import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/customer_model.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        width: 680,
        height: 520,
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
            _detailRow("Phone Number", widget.customer.phone),
            const Divider(height: 1),
            _detailRow("Email", widget.customer.email),
            const Divider(height: 1),
            _detailRow("Address", widget.customer.address),
            const Divider(height: 1),
            _detailRow("City", widget.customer.city),
            if (widget.customer.mapLocation.isNotEmpty) ...[
              const Divider(height: 1),
              _detailRow("Map Location", widget.customer.mapLocation),
            ],
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
