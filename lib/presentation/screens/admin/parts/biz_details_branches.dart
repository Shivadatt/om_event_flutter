part of '../business_details_screen.dart';

extension BusinessDetailsBranches on BusinessDetailsScreen {
  Widget _buildBranchesTab(BuildContext context, BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("OFFICE BRANCHES", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC9A77E), size: 28),
              onPressed: () => _showBranchDialog(context, controller, null),
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
            onReorderItem: (oldIndex, newIndex) {
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
                        activeThumbColor: const Color(0xFFC9A77E),
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
                        onPressed: () => _showBranchDialog(context, controller, index),
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

  void _showBranchDialog(BuildContext context, BusinessDetailsController controller, int? editIndex) {
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
          title: Text(
            isEditing ? "Edit Branch" : "Add Branch",
            style: GoogleFonts.italiana(color: const Color(0xFFC9A77E)),
          ),
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
              child: Text(
                "Cancel",
                style: AppTheme.sansBody(fontSize: 13, color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || addrCtrl.text.isEmpty) {
                  Get.snackbar(
                    "Validation Error",
                    "Name, Phone, and Address are required",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
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
}
