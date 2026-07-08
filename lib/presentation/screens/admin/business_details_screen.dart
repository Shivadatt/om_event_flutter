import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/business_details_controller.dart';
import '../../../domain/entities/business_details_entity.dart';
import 'widgets/admin_back_button.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: const AdminBackButton(color: Color(0xFFC9A77E)),
        title: Text(
          "BUSINESS DETAILS CENTRAL CMS",
          style: GoogleFonts.italiana(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        return Row(
          children: [
            // Left navigation rail
            Container(
              width: 240,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.white12, width: 1),
                ),
              ),
              child: ListView.builder(
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final isSelected = index == controller.selectedIndex.value;
                  return ListTile(
                    title: Text(
                      _tabs[index],
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFFC9A77E) : Colors.white70,
                      ),
                    ),
                    selected: isSelected,
                    onTap: () {
                      controller.selectedIndex.value = index;
                    },
                  );
                },
              ),
            ),
            // Form content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildTabContent(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(() {
                          return ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : () => controller.saveCentralizedDetails(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC9A77E),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : const Text("Save & Publish CMS", style: TextStyle(fontWeight: FontWeight.bold)),
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

  // ──── REUSABLE FIELDS ────────────────────────────────────────────────────────
  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: AppTheme.sansBody(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFC9A77E))),
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: ctrl,
        style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.sansBody(fontSize: 11, color: Colors.white70),
          border: const OutlineInputBorder(),
        ),
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
