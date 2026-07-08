part of '../system_settings_screen.dart';

extension _SettingsBusinessContactsAddExtension on _SystemSettingsScreenState {
  void _showAddContactDialog() {
    final numberCtrl = TextEditingController();
    final labelCtrl = TextEditingController(text: "Mobile");
    bool isPrimaryVal = _contactNumbers.isEmpty;
    bool isActiveVal = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Contact Number"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: numberCtrl,
                      decoration: const InputDecoration(
                        labelText: "Phone Number (e.g. 9512149944)",
                        hintText: "10-digit Indian number",
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: labelCtrl,
                      decoration: const InputDecoration(
                        labelText: "Label (e.g. Primary, Secondary, Office)",
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
                    if (_contactNumbers.any((c) => c.number.endsWith(formattedNum))) {
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
                      }

                      _contactNumbers.add(
                        ContactNumberEntity(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          label: lblStr,
                          number: formattedNum,
                          isPrimary: isPrimaryVal,
                          isActive: isActiveVal,
                          displayOrder: _contactNumbers.length + 1,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
