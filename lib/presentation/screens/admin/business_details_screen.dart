import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/business_details_controller.dart';
import '../../../domain/entities/business_details_entity.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';

part 'parts/biz_details_general.dart';
part 'parts/biz_details_contacts.dart';
part 'parts/biz_details_branches.dart';
part 'parts/biz_details_addresses.dart';
part 'parts/biz_details_other.dart';

class BusinessDetailsScreen extends GetView<BusinessDetailsController> {
  const BusinessDetailsScreen({super.key});

  final List<String> _tabs = const [
    "General",
    "Contacts",
    "Branches",
    "Addresses",
    "Social Media",
    "Working Hours",
    "Bank Details",
    "Legal Details",
    "SEO Metadata",
    "Google Maps",
    "Media Assets",
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryAccent = AppColors.primaryAccent;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text(
          "BRAND STUDIO MANAGER",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Obx(() {
        return Row(
          children: [
            // Left floating navigation rail
            Container(
              width: 250,
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == controller.selectedIndex.value;
                    return InkWell(
                      onTap: () {
                        controller.selectedIndex.value = index;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryAccent.withValues(alpha: 0.08) : Colors.transparent,
                          border: Border(
                            left: BorderSide(
                              color: isSelected ? primaryAccent : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          _tabs[index].toUpperCase(),
                          style: AppTheme.sansBody(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? primaryAccent : subtitleColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Form Content Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 24, bottom: 24, right: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildTabContent(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(() {
                          return ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : () => controller.saveCentralizedDetails(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryAccent,
                              foregroundColor: isDark ? AppColors.black : AppColors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                            ),
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : Text(
                                    "SAVE & PUBLISH CMS",
                                    style: AppTheme.sansBody(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.black : Colors.white,
                                    ),
                                  ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (controller.selectedIndex.value) {
      case 0:
        return _buildGeneralTab(controller);
      case 1:
        return _buildContactsTab(context, controller);
      case 2:
        return _buildBranchesTab(context, controller);
      case 3:
        return _buildAddressesTab(context, controller);
      case 4:
        return _buildSocialTab(controller);
      case 5:
        return _buildWorkingHoursTab(controller);
      case 6:
        return _buildBankDetailsTab(controller);
      case 7:
        return _buildLegalTab(controller);
      case 8:
        return _buildSeoTab(controller);
      case 9:
        return _buildMapsTab(controller);
      case 10:
        return _buildMediaTab(controller);
      default:
        return const SizedBox();
    }
  }

  // Custom luxury inputs
  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTheme.sansBody(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryAccent,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            style: AppTheme.sansBody(fontSize: 14, color: AppColors.darkInk),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkForest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.darkLine),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.darkLine),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTheme.sansBody(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryAccent,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            style: AppTheme.sansBody(fontSize: 13, color: AppColors.darkInk),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkForest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.darkLine),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to safely extract city details from branch address
extension BranchEntityCity on BranchEntity {
  String get cityText {
    final parts = fullAddress.split(',');
    if (parts.length >= 2) {
      return parts[parts.length - 2].trim();
    }
    return 'Office';
  }
}
