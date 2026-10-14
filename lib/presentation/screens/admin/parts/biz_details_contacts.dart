part of '../business_details_screen.dart';

extension BusinessDetailsContacts on BusinessDetailsScreen {
  Widget _buildContactsTab(BuildContext context, BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CONTACT INFORMATION",
          style: GoogleFonts.italiana(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE2B755),
            letterSpacing: 1.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 14),
          height: 1.5,
          width: 52,
          color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
        ),
        _buildContactManager(
          context: context,
          controller: controller,
          title: "Phone Numbers",
          list: controller.phones,
          isPhone: true,
        ),
        const SizedBox(height: 14),
        _buildContactManager(
          context: context,
          controller: controller,
          title: "WhatsApp Numbers",
          list: controller.whatsapps,
          isPhone: true,
        ),
        const SizedBox(height: 14),
        _buildContactManager(
          context: context,
          controller: controller,
          title: "Emails",
          list: controller.emails,
          isEmail: true,
        ),
        const SizedBox(height: 14),
        _buildContactManager(
          context: context,
          controller: controller,
          title: "Customer Care",
          list: controller.customerCares,
          isPhone: true,
        ),
        const SizedBox(height: 14),
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
    IconData headerIcon;
    if (isEmail) {
      headerIcon = Icons.mail_outline_rounded;
    } else if (title.toLowerCase().contains("whatsapp")) {
      headerIcon = Icons.forum_outlined;
    } else if (title.toLowerCase().contains("emergency")) {
      headerIcon = Icons.emergency_outlined;
    } else if (title.toLowerCase().contains("care")) {
      headerIcon = Icons.support_agent_outlined;
    } else {
      headerIcon = Icons.phone_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080F0C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.28),
          width: 0.9,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    headerIcon,
                    size: 16,
                    color: const Color(0xFFE2B755),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE2B755),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Obx(() {
                    if (list.isEmpty) return const SizedBox();
                    return Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        "${list.length}",
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE2B755),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              InkWell(
                onTap: () => _showContactItemDialog(context, list, null, isPhone, isEmail),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                      width: 0.85,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        size: 13,
                        color: Color(0xFFE2B755),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "ADD",
                        style: GoogleFonts.dmSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE2B755),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
            height: 16,
            thickness: 0.8,
          ),
          Obx(() {
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Text(
                    "No items configured yet.",
                    style: GoogleFonts.dmSans(
                      fontSize: 11.5,
                      color: Colors.white30,
                    ),
                  ),
                ),
              );
            }
            return ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: list.length,
              onReorderItem: (oldIndex, newIndex) {
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
                return Container(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1511),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.16),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Reorder Drag Handle (Only One Handle)
                      ReorderableDragStartListener(
                        index: index,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.drag_indicator_rounded,
                              size: 16,
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      // Text content + primary tag (Flexible, overflow-protected)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.value,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: item.isActive ? Colors.white : Colors.white54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                if (item.isPrimary) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "PRIMARY",
                                      style: GoogleFonts.dmSans(
                                        color: const Color(0xFF0C1410),
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 1.5),
                            Text(
                              item.label,
                              style: GoogleFonts.dmSans(
                                fontSize: 10.5,
                                color: Colors.white38,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Trailing controls: Compact Switch, Edit & Delete
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 22,
                            width: 36,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Switch(
                                value: item.isActive,
                                activeThumbColor: const Color(0xFFE2B755),
                                activeTrackColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                                inactiveThumbColor: Colors.white30,
                                inactiveTrackColor: Colors.white12,
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
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () =>
                                _showContactItemDialog(context, list, index, isPhone, isEmail),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                color: Color(0xFFE2B755),
                                size: 13.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () => list.removeAt(index),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
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
              backgroundColor: const Color(0xFF0C1511),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.45)),
              ),
              title: Text(
                isEditing ? "Edit Contact" : "Add Contact",
                style: GoogleFonts.italiana(
                  color: const Color(0xFFE2B755),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(
                    isEmail ? "Email Address" : "Phone Number",
                    valueCtrl,
                    icon: isEmail ? Icons.email_outlined : Icons.phone_outlined,
                  ),
                  _dialogField(
                    "Label (e.g. Sales, Support, Office)",
                    labelCtrl,
                    icon: Icons.label_outline,
                  ),
                  CheckboxListTile(
                    title: Text(
                      "Mark as Primary",
                      style: GoogleFonts.dmSans(fontSize: 12.5, color: Colors.white),
                    ),
                    value: isPrimaryVal,
                    activeColor: const Color(0xFFD4AF37),
                    checkColor: const Color(0xFF0C1410),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setDialogState(() {
                        isPrimaryVal = val ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      "Is Active",
                      style: GoogleFonts.dmSans(fontSize: 12.5, color: Colors.white),
                    ),
                    value: isActiveVal,
                    activeColor: const Color(0xFFD4AF37),
                    checkColor: const Color(0xFF0C1410),
                    contentPadding: EdgeInsets.zero,
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
                    style: GoogleFonts.dmSans(fontSize: 12.5, color: Colors.white54),
                  ),
                ),
                InkWell(
                  onTap: () {
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
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7.5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF3C456), Color(0xFFD89B27)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      isEditing ? "SAVE" : "ADD",
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0C1410),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
