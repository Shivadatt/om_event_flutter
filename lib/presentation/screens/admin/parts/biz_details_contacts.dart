part of '../business_details_screen.dart';

extension BusinessDetailsContacts on BusinessDetailsScreen {
  Widget _buildContactsTab(BuildContext context, BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CONTACT INFORMATION",
          style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E)),
        ),
        const SizedBox(height: 24),
        _buildContactManager(
          context: context,
          controller: controller,
          title: "Phone Numbers",
          list: controller.phones,
          isPhone: true,
        ),
        const SizedBox(height: 24),
        _buildContactManager(
          context: context,
          controller: controller,
          title: "WhatsApp Numbers",
          list: controller.whatsapps,
          isPhone: true,
        ),
        const SizedBox(height: 24),
        _buildContactManager(
          context: context,
          controller: controller,
          title: "Emails",
          list: controller.emails,
          isEmail: true,
        ),
        const SizedBox(height: 24),
        _buildContactManager(
          context: context,
          controller: controller,
          title: "Customer Care",
          list: controller.customerCares,
          isPhone: true,
        ),
        const SizedBox(height: 24),
        _buildContactManager(
          context: context,
          controller: controller,
          title: "Emergency Contacts",
          list: controller.emergencyContacts,
          isPhone: true,
        ),
      ],
    );
  }

  Widget _buildContactManager({
    required BuildContext context,
    required BusinessDetailsController controller,
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
                Text(
                  title,
                  style: AppTheme.sansBody(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC9A77E),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC9A77E)),
                  onPressed: () =>
                      _showContactItemDialog(context, list, null, isPhone, isEmail),
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            Obx(() {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "No items configured.",
                    style: AppTheme.sansBody(fontSize: 12, color: Colors.grey),
                  ),
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
                        Text(
                          item.value,
                          style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        if (item.isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9A77E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Primary",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      item.label,
                      style: AppTheme.sansBody(fontSize: 12, color: Colors.grey),
                    ),
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
                          onPressed: () =>
                              _showContactItemDialog(context, list, index, isPhone, isEmail),
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
              title: Text(
                isEditing ? "Edit Contact" : "Add Contact",
                style: GoogleFonts.italiana(color: const Color(0xFFC9A77E)),
              ),
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
                  child: Text(
                    "Cancel",
                    style: AppTheme.sansBody(fontSize: 13, color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final valStr = valueCtrl.text.trim();
                    final lblStr = labelCtrl.text.trim();

                    if (valStr.isEmpty) {
                      Get.snackbar(
                        "Validation Error",
                        "Value is required",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    if (isPhone && !AppValidators.isValidPhone(valStr)) {
                      Get.snackbar(
                        "Validation Error",
                        "Please enter a valid 10-digit phone number",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    if (isEmail && !AppValidators.isValidEmail(valStr)) {
                      Get.snackbar(
                        "Validation Error",
                        "Please enter a valid email address",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    if (isPrimaryVal) {
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
}
