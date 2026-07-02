import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/business_details_controller.dart';
import '../../../domain/entities/business_details_entity.dart';
import 'widgets/admin_back_button.dart';


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
        return _buildGeneralTab();
      case 1:
        return _buildContactsTab(context);
      case 2:
        return _buildBranchesTab(context);
      case 3:
        return _buildAddressesTab(context);
      case 4:
        return _buildSocialTab();
      case 5:
        return _buildWorkingHoursTab();
      case 6:
        return _buildBankDetailsTab();
      case 7:
        return _buildLegalTab();
      case 8:
        return _buildSeoTab();
      case 9:
        return _buildMapsTab();
      case 10:
        return _buildMediaTab();
      default:
        return const SizedBox();
    }
  }

  // ──── 1. GENERAL TAB ──────────────────────────────────────────────────────────
  Widget _buildGeneralTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("GENERAL PROFILE", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Business Name *", controller.busNameCtrl),
        _field("Company Name", controller.compNameCtrl),
        _field("Business Tagline", controller.taglineCtrl),
        _field("Business Description", controller.descCtrl, maxLines: 3),
        _field("Owner Name", controller.ownerNameCtrl),
        _field("Owner Designation", controller.ownerDesignationCtrl),
        _field("Established Year", controller.estYearCtrl),
        _field("Registration Number", controller.regNumCtrl),
        _field("GST Number", controller.gstNumCtrl),
        _field("PAN Number", controller.panNumCtrl),
        _field("Business License Number", controller.licenseNumCtrl),
      ],
    );
  }

  // ──── 2. CONTACTS TAB ──────────────────────────────────────────────────────────
  Widget _buildContactsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("CONTACT INFORMATION", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _buildContactManager(
          context: context,
          title: "Phone Numbers",
          list: controller.phones,
          isPhone: true,
        ),
        const SizedBox(height: 24),
        _buildContactManager(
          context: context,
          title: "WhatsApp Numbers",
          list: controller.whatsapps,
          isPhone: true,
        ),
        const SizedBox(height: 24),
        _buildContactManager(
          context: context,
          title: "Emails",
          list: controller.emails,
          isEmail: true,
        ),
        const SizedBox(height: 24),
        _buildContactManager(
          context: context,
          title: "Customer Care",
          list: controller.customerCares,
          isPhone: true,
        ),
        const SizedBox(height: 24),
        _buildContactManager(
          context: context,
          title: "Emergency Contacts",
          list: controller.emergencyContacts,
          isPhone: true,
        ),
      ],
    );
  }

  Widget _buildContactManager({
    required BuildContext context,
    required String title,
    required RxList<ContactItemEntity> list,
    bool isPhone = false,
    bool isEmail = false,
  }) {


    return Card(
      color: const Color(0xFF131D1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF254235)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTheme.sansBody(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFC9A77E))),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC9A77E)),
                  onPressed: () => _showContactItemDialog(context, list, null, isPhone, isEmail),
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            Obx(() {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("No items configured.", style: AppTheme.sansBody(fontSize: 12, color: Colors.grey)),
                );
              }
              return ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = list.removeAt(oldIndex);
                  list.insert(newIndex, item);
                  // Update displayOrder
                  for (int i = 0; i < list.length; i++) {
                    final c = list[i];
                    list[i] = ContactItemEntity(
                      id: c.id,
                      label: c.label,
                      value: c.value,
                      isPrimary: c.isPrimary,
                      isActive: c.isActive,
                      displayOrder: i + 1,
                    );
                  }
                },
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    key: ValueKey(item.id),
                    leading: const Icon(Icons.drag_handle, color: Colors.grey),
                    title: Row(
                      children: [
                        Text(item.value, style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        if (item.isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFC9A77E), borderRadius: BorderRadius.circular(4)),
                            child: const Text("Primary", style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    subtitle: Text(item.label, style: AppTheme.sansBody(fontSize: 12, color: Colors.grey)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: item.isActive,
                          activeColor: const Color(0xFFC9A77E),
                          onChanged: (val) {
                            list[index] = ContactItemEntity(
                              id: item.id,
                              label: item.label,
                              value: item.value,
                              isPrimary: item.isPrimary,
                              isActive: val,
                              displayOrder: item.displayOrder,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                          onPressed: () => _showContactItemDialog(context, list, index, isPhone, isEmail),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => list.removeAt(index),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showContactItemDialog(
    BuildContext context,
    RxList<ContactItemEntity> list,
    int? editIndex,
    bool isPhone,
    bool isEmail,
  ) {
    final isEditing = editIndex != null;
    final existing = isEditing ? list[editIndex] : null;

    final valueCtrl = TextEditingController(text: existing?.value ?? "");
    final labelCtrl = TextEditingController(text: existing?.label ?? "Mobile");
    bool isPrimaryVal = existing?.isPrimary ?? false;
    bool isActiveVal = existing?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1915),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFC9A77E)),
              ),
              title: Text(isEditing ? "Edit Contact" : "Add Contact", style: GoogleFonts.italiana(color: const Color(0xFFC9A77E))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: valueCtrl,
                    style: AppTheme.sansBody(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: isEmail ? "Email Address" : "Phone Number",
                      labelStyle: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: labelCtrl,
                    style: AppTheme.sansBody(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Label (e.g. Sales, Support, Office)",
                      labelStyle: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: Text("Mark as Primary", style: AppTheme.sansBody(fontSize: 13)),
                    value: isPrimaryVal,
                    activeColor: const Color(0xFFC9A77E),
                    onChanged: (val) {
                      setDialogState(() {
                        isPrimaryVal = val ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Is Active", style: AppTheme.sansBody(fontSize: 13)),
                    value: isActiveVal,
                    activeColor: const Color(0xFFC9A77E),
                    onChanged: (val) {
                      setDialogState(() {
                        isActiveVal = val ?? true;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: AppTheme.sansBody(fontSize: 13, color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final valStr = valueCtrl.text.trim();
                    final lblStr = labelCtrl.text.trim();

                    if (valStr.isEmpty) {
                      Get.snackbar("Validation Error", "Value is required", backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    if (isPhone && !AppValidators.isValidPhone(valStr)) {
                      Get.snackbar("Validation Error", "Please enter a valid 10-digit phone number", backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    if (isEmail && !AppValidators.isValidEmail(valStr)) {
                      Get.snackbar("Validation Error", "Please enter a valid email address", backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }

                    if (isPrimaryVal) {
                      // Reset other primary flags in list
                      for (int i = 0; i < list.length; i++) {
                        if (i != editIndex) {
                          final c = list[i];
                          list[i] = ContactItemEntity(
                            id: c.id,
                            label: c.label,
                            value: c.value,
                            isPrimary: false,
                            isActive: c.isActive,
                            displayOrder: c.displayOrder,
                          );
                        }
                      }
                    }

                    final newItem = ContactItemEntity(
                      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      label: lblStr.isEmpty ? "Contact" : lblStr,
                      value: isPhone ? AppValidators.cleanPhone(valStr) : valStr,
                      isPrimary: isPrimaryVal,
                      isActive: isActiveVal,
                      displayOrder: existing?.displayOrder ?? list.length + 1,
                    );

                    if (isEditing) {
                      list[editIndex] = newItem;
                    } else {
                      list.add(newItem);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(isEditing ? "Save" : "Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ──── 3. BRANCHES TAB ──────────────────────────────────────────────────────────
  Widget _buildBranchesTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("OFFICE BRANCHES", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC9A77E), size: 28),
              onPressed: () => _showBranchDialog(context, null),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() {
          if (controller.branches.isEmpty) {
            return Text("No branches configured.", style: AppTheme.sansBody(fontSize: 14, color: Colors.grey));
          }
          return ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.branches.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final b = controller.branches.removeAt(oldIndex);
              controller.branches.insert(newIndex, b);
              for (int i = 0; i < controller.branches.length; i++) {
                final curr = controller.branches[i];
                controller.branches[i] = BranchEntity(
                  id: curr.id,
                  branchName: curr.branchName,
                  branchManager: curr.branchManager,
                  phoneNumber: curr.phoneNumber,
                  whatsapp: curr.whatsapp,
                  email: curr.email,
                  fullAddress: curr.fullAddress,
                  googleMapUrl: curr.googleMapUrl,
                  latitude: curr.latitude,
                  longitude: curr.longitude,
                  workingHours: curr.workingHours,
                  openingDays: curr.openingDays,
                  displayOrder: i + 1,
                  isActive: curr.isActive,
                  instagram: curr.instagram,
                );
              }
            },
            itemBuilder: (context, index) {
              final b = controller.branches[index];
              return Container(
                key: ValueKey(b.id),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D1A),
                  border: Border.all(color: const Color(0xFF254235)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.drag_handle, color: Colors.grey),
                  title: Text(b.branchName, style: AppTheme.sansBody(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text("${b.cityText} • ${b.phoneNumber}", style: AppTheme.sansBody(fontSize: 12, color: Colors.grey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: b.isActive,
                        activeColor: const Color(0xFFC9A77E),
                        onChanged: (val) {
                          controller.branches[index] = BranchEntity(
                            id: b.id,
                            branchName: b.branchName,
                            branchManager: b.branchManager,
                            phoneNumber: b.phoneNumber,
                            whatsapp: b.whatsapp,
                            email: b.email,
                            fullAddress: b.fullAddress,
                            googleMapUrl: b.googleMapUrl,
                            latitude: b.latitude,
                            longitude: b.longitude,
                            workingHours: b.workingHours,
                            openingDays: b.openingDays,
                            displayOrder: b.displayOrder,
                            isActive: val,
                            instagram: b.instagram,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showBranchDialog(context, index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.branches.removeAt(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showBranchDialog(BuildContext context, int? editIndex) {
    final isEditing = editIndex != null;
    final b = isEditing ? controller.branches[editIndex] : null;

    final nameCtrl = TextEditingController(text: b?.branchName ?? "");
    final managerCtrl = TextEditingController(text: b?.branchManager ?? "");
    final phoneCtrl = TextEditingController(text: b?.phoneNumber ?? "");
    final waCtrl = TextEditingController(text: b?.whatsapp ?? "");
    final emailCtrl = TextEditingController(text: b?.email ?? "");
    final addrCtrl = TextEditingController(text: b?.fullAddress ?? "");
    final mapCtrl = TextEditingController(text: b?.googleMapUrl ?? "");
    final latCtrl = TextEditingController(text: b?.latitude ?? "");
    final lngCtrl = TextEditingController(text: b?.longitude ?? "");
    final hoursCtrl = TextEditingController(text: b?.workingHours ?? "");
    final daysCtrl = TextEditingController(text: b?.openingDays ?? "");
    final instagramCtrl = TextEditingController(text: b?.instagram ?? "");
    bool isActiveVal = b?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1915),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFC9A77E)),
          ),
          title: Text(isEditing ? "Edit Branch" : "Add Branch", style: GoogleFonts.italiana(color: const Color(0xFFC9A77E))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField("Branch Name *", nameCtrl),
                _dialogField("Branch Manager", managerCtrl),
                _dialogField("Phone Number *", phoneCtrl),
                _dialogField("WhatsApp Number", waCtrl),
                _dialogField("Email", emailCtrl),
                _dialogField("Instagram URL", instagramCtrl),
                _dialogField("Full Address *", addrCtrl),
                _dialogField("Google Maps Share Link", mapCtrl),
                Row(
                  children: [
                    Expanded(child: _dialogField("Latitude", latCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _dialogField("Longitude", lngCtrl)),
                  ],
                ),
                _dialogField("Working Hours (e.g. 9am - 8pm)", hoursCtrl),
                _dialogField("Opening Days (e.g. Mon - Sat)", daysCtrl),
                CheckboxListTile(
                  title: Text("Is Active", style: AppTheme.sansBody(fontSize: 13)),
                  value: isActiveVal,
                  activeColor: const Color(0xFFC9A77E),
                  onChanged: (val) {
                    isActiveVal = val ?? true;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: AppTheme.sansBody(fontSize: 13, color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || addrCtrl.text.isEmpty) {
                  Get.snackbar("Validation Error", "Name, Phone, and Address are required", backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }
                final newB = BranchEntity(
                  id: b?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  branchName: nameCtrl.text.trim(),
                  branchManager: managerCtrl.text.trim(),
                  phoneNumber: phoneCtrl.text.trim(),
                  whatsapp: waCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  fullAddress: addrCtrl.text.trim(),
                  googleMapUrl: mapCtrl.text.trim(),
                  latitude: latCtrl.text.trim(),
                  longitude: lngCtrl.text.trim(),
                  workingHours: hoursCtrl.text.trim(),
                  openingDays: daysCtrl.text.trim(),
                  displayOrder: b?.displayOrder ?? controller.branches.length + 1,
                  isActive: isActiveVal,
                  instagram: instagramCtrl.text.trim(),
                );

                if (isEditing) {
                  controller.branches[editIndex] = newB;
                } else {
                  controller.branches.add(newB);
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? "Save" : "Add"),
            ),
          ],
        );
      },
    );
  }

  // ──── 4. ADDRESSES TAB ──────────────────────────────────────────────────────────
  Widget _buildAddressesTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("UNLIMITED ADDRESSES", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC9A77E), size: 28),
              onPressed: () => _showAddressDialog(context, null),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() {
          if (controller.addresses.isEmpty) {
            return Text("No addresses configured.", style: AppTheme.sansBody(fontSize: 14, color: Colors.grey));
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.addresses.length,
            itemBuilder: (context, index) {
              final a = controller.addresses[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D1A),
                  border: Border.all(color: const Color(0xFF254235)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(a.addressTitle, style: AppTheme.sansBody(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text("${a.street}, ${a.city}, ${a.state} - ${a.pincode}", style: AppTheme.sansBody(fontSize: 12, color: Colors.grey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddressDialog(context, index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.addresses.removeAt(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showAddressDialog(BuildContext context, int? editIndex) {
    final isEditing = editIndex != null;
    final a = isEditing ? controller.addresses[editIndex] : null;

    final titleCtrl = TextEditingController(text: a?.addressTitle ?? "");
    final streetCtrl = TextEditingController(text: a?.street ?? "");
    final areaCtrl = TextEditingController(text: a?.area ?? "");
    final cityCtrl = TextEditingController(text: a?.city ?? "");
    final distCtrl = TextEditingController(text: a?.district ?? "");
    final stateCtrl = TextEditingController(text: a?.state ?? "");
    final countryCtrl = TextEditingController(text: a?.country ?? "India");
    final pinCtrl = TextEditingController(text: a?.pincode ?? "");
    final landmarkCtrl = TextEditingController(text: a?.landmark ?? "");
    final mapCtrl = TextEditingController(text: a?.googleMapsLink ?? "");
    final latCtrl = TextEditingController(text: a?.latitude ?? "");
    final lngCtrl = TextEditingController(text: a?.longitude ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1915),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFC9A77E)),
          ),
          title: Text(isEditing ? "Edit Address" : "Add Address", style: GoogleFonts.italiana(color: const Color(0xFFC9A77E))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField("Address Title * (e.g. Main Office, Warehouse)", titleCtrl),
                _dialogField("Street Address", streetCtrl),
                _dialogField("Area / Locality", areaCtrl),
                Row(
                  children: [
                    Expanded(child: _dialogField("City *", cityCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _dialogField("District", distCtrl)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _dialogField("State *", stateCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _dialogField("Pincode *", pinCtrl)),
                  ],
                ),
                _dialogField("Country", countryCtrl),
                _dialogField("Landmark", landmarkCtrl),
                _dialogField("Google Maps Link", mapCtrl),
                Row(
                  children: [
                    Expanded(child: _dialogField("Latitude", latCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _dialogField("Longitude", lngCtrl)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: AppTheme.sansBody(fontSize: 13, color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || cityCtrl.text.isEmpty || stateCtrl.text.isEmpty || pinCtrl.text.isEmpty) {
                  Get.snackbar("Validation Error", "Title, City, State, and Pincode are required", backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }
                final newAddr = AddressEntity(
                  id: a?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  addressTitle: titleCtrl.text.trim(),
                  street: streetCtrl.text.trim(),
                  area: areaCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                  district: distCtrl.text.trim(),
                  state: stateCtrl.text.trim(),
                  country: countryCtrl.text.trim(),
                  pincode: pinCtrl.text.trim(),
                  landmark: landmarkCtrl.text.trim(),
                  googleMapsLink: mapCtrl.text.trim(),
                  latitude: latCtrl.text.trim(),
                  longitude: lngCtrl.text.trim(),
                );

                if (isEditing) {
                  controller.addresses[editIndex] = newAddr;
                } else {
                  controller.addresses.add(newAddr);
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? "Save" : "Add"),
            ),
          ],
        );
      },
    );
  }

  // ──── 5. SOCIAL MEDIA TAB ─────────────────────────────────────────────────────
  Widget _buildSocialTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SOCIAL MEDIA ACCOUNTS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Instagram URL (Kadi Branch)", controller.socialInstaKadiCtrl),
        _field("Instagram URL (Thangadh Branch)", controller.socialInstaThangadhCtrl),
        _field("Official Website", controller.socialWebCtrl),
        _field("Google Business Profile Link", controller.socialGoogleBusinessCtrl),
      ],
    );
  }

  // ──── 6. WORKING HOURS TAB ───────────────────────────────────────────────────
  Widget _buildWorkingHoursTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("WORKING HOURS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Monday Timings", controller.workMondayCtrl),
        _field("Tuesday Timings", controller.workTuesdayCtrl),
        _field("Wednesday Timings", controller.workWednesdayCtrl),
        _field("Thursday Timings", controller.workThursdayCtrl),
        _field("Friday Timings", controller.workFridayCtrl),
        _field("Saturday Timings", controller.workSaturdayCtrl),
        _field("Sunday Timings", controller.workSundayCtrl),
        _field("Holiday Lists & Notes", controller.workHolidayNotesCtrl, maxLines: 3),
        _field("Emergency Support Hours", controller.workEmergencyHoursCtrl),
      ],
    );
  }

  // ──── 7. BANK DETAILS TAB ─────────────────────────────────────────────────────
  Widget _buildBankDetailsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BANK DETAILS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Bank Name", controller.bankNameCtrl),
        _field("Account Holder Name", controller.bankHolderCtrl),
        _field("Account Number", controller.bankAccCtrl),
        _field("IFSC Code", controller.bankIfscCtrl),
        _field("UPI ID", controller.bankUpiCtrl),
        _field("UPI QR Code Image URL", controller.bankQrCodeCtrl),
      ],
    );
  }

  // ──── 8. LEGAL DETAILS TAB ────────────────────────────────────────────────────
  Widget _buildLegalTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("LEGAL DOCUMENTS & POLICIES", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("GST Registration Number", controller.legalGstCtrl),
        _field("PAN Registration Number", controller.legalPanCtrl),
        _field("MSME Registration Number", controller.legalMsmeCtrl),
        _field("Terms & Conditions", controller.legalTermsCtrl, maxLines: 5),
        _field("Privacy Policy", controller.legalPrivacyCtrl, maxLines: 5),
        _field("Refund Policy", controller.legalRefundCtrl, maxLines: 5),
        _field("Cancellation Policy", controller.legalCancellationCtrl, maxLines: 5),
      ],
    );
  }

  // ──── 9. SEO METADATA TAB ─────────────────────────────────────────────────────
  Widget _buildSeoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SEO SPECIFICATIONS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Meta Title", controller.seoTitleCtrl),
        _field("Meta Description", controller.seoDescCtrl, maxLines: 3),
        _field("Keywords (comma separated)", controller.seoKeywordsCtrl),
        _field("Canonical URL", controller.seoCanonicalCtrl),
        _field("OpenGraph Share Image URL", controller.seoOgImageCtrl),
        _field("Twitter Card Image URL", controller.seoTwitterImageCtrl),
      ],
    );
  }

  // ──── 10. GOOGLE MAPS TAB ─────────────────────────────────────────────────────
  Widget _buildMapsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("GOOGLE MAPS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Google Maps URL (Default)", controller.mapsUrlCtrl),
        _field("Coordinates (e.g. 23.3000, 72.3300)", controller.mapsCoordsCtrl),
        _field("Google Map Embed iframe Code", controller.mapsEmbedCtrl, maxLines: 4),
      ],
    );
  }

  // ──── 11. MEDIA ASSETS TAB ────────────────────────────────────────────────────
  Widget _buildMediaTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("MEDIA ASSETS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Business Logo Image URL", controller.logoCtrl),
        _field("Business Cover Image URL", controller.coverImageCtrl),
        _field("Business Favicon Image URL", controller.faviconCtrl),
        const SizedBox(height: 16),
        const Text("Media Previews", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
        const SizedBox(height: 12),
        Row(
          children: [
            _mediaPreviewCard("Logo", controller.logoCtrl),
            const SizedBox(width: 16),
            _mediaPreviewCard("Cover Image", controller.coverImageCtrl),
            const SizedBox(width: 16),
            _mediaPreviewCard("Favicon", controller.faviconCtrl),
          ],
        ),
      ],
    );
  }

  Widget _mediaPreviewCard(String label, TextEditingController ctrl) {
    return Container(
      width: 120,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF131D1A),
        border: Border.all(color: const Color(0xFF254235)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Obx(() {
              // Read rxDetails just to rebuild on change, or watch controller saves
              final url = ctrl.text.trim();
              if (url.isEmpty || !url.startsWith("http")) {
                return const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey));
              }
              return Image.network(url, fit: BoxFit.contain, errorBuilder: (c, o, s) {
                return const Center(child: Icon(Icons.error_outline, color: Colors.red));
              });
            }),
          ),
        ],
      ),
    );
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
