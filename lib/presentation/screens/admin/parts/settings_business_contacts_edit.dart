part of '../system_settings_screen.dart';

extension _SettingsBusinessContactsEditExtension on _SystemSettingsScreenState {
  void _showEditContactDialog(ContactNumberEntity cn, int index) {
    final numberCtrl = TextEditingController(text: cn.number);
    final labelCtrl = TextEditingController(text: cn.label);
    bool isPrimaryVal = cn.isPrimary;
    bool isActiveVal = cn.isActive;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Contact Number"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: numberCtrl,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        hintText: "10-digit Indian number",
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: labelCtrl,
                      decoration: const InputDecoration(
                        labelText: "Label",
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text("Set as Primary Number"),
                      value: isPrimaryVal,
                      activeColor: const Color(0xFFC9A77E),
                      onChanged: (val) {
                        setDialogState(() {
                          isPrimaryVal = val ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text("Is Active"),
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final numStr = numberCtrl.text.trim();
                    final lblStr = labelCtrl.text.trim();

                    if (!AppValidators.isValidPhone(numStr)) {
                      Get.snackbar(
                        "Validation Error",
                        "Please enter a valid 10-digit number.",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    final formattedNum = AppValidators.cleanPhone(numStr);
                    if (_contactNumbers.asMap().entries.any((entry) => entry.key != index && entry.value.number.endsWith(formattedNum))) {
                      Get.snackbar(
                        "Validation Error",
                        "This contact number already exists.",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    if (lblStr.isEmpty) {
                      Get.snackbar(
                        "Validation Error",
                        "Label cannot be empty.",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    if (!isActiveVal && isPrimaryVal) {
                      Get.snackbar(
                        "Validation Error",
                        "Primary number must be active.",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    updateState(() {
                      if (isPrimaryVal) {
                        for (int i = 0; i < _contactNumbers.length; i++) {
                          final c = _contactNumbers[i];
                          _contactNumbers[i] = ContactNumberEntity(
                            id: c.id,
                            label: c.label,
                            number: c.number,
                            isPrimary: false,
                            isActive: c.isActive,
                            displayOrder: c.displayOrder,
                          );
                        }
                      } else if (cn.isPrimary) {
                        final otherPrimary = _contactNumbers.asMap().entries.any((entry) => entry.key != index && entry.value.isPrimary);
                        if (!otherPrimary) {
                          Get.snackbar(
                            "Validation Error",
                            "One contact number must be marked as Primary.",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                      }

                      _contactNumbers[index] = ContactNumberEntity(
                        id: cn.id,
                        label: lblStr,
                        number: formattedNum,
                        isPrimary: isPrimaryVal,
                        isActive: isActiveVal,
                        displayOrder: cn.displayOrder,
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
