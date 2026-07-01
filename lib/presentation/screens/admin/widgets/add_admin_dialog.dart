import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/entities/admin_role.dart';
import '../../../controllers/admin_controller.dart';
import '../../../controllers/auth_controller.dart';

/// Dialog to add a new administrator role configuration.
class AddAdminDialog extends StatefulWidget {
  /// The controller used to save the created role.
  final AdminController controller;

  /// Creates a [AddAdminDialog] instance.
  const AddAdminDialog({super.key, required this.controller});

  @override
  State<AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<AddAdminDialog> {
  final _uidCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _selectedRoleType = 'demo_admin';

  final Map<String, bool> _defaultPermissions = {
    'can_manage_categories': true,
    'can_manage_items': true,
    'can_manage_customers': true,
    'can_manage_users': false,
    'can_manage_reviews': true,
    'can_manage_quotes': true,
    'can_manage_leads': true,
    'can_manage_settings': false,
    'can_create': true,
    'can_edit': true,
    'can_delete': false,
  };

  @override
  void dispose() {
    _uidCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Admin Profile"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _uidCtrl,
              decoration: const InputDecoration(labelText: "Firebase User UID"),
            ),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: "Email Address"),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _selectedRoleType,
              decoration: const InputDecoration(labelText: "Role Type"),
              items: const [
                DropdownMenuItem(
                  value: 'super_admin',
                  child: Text("Super Admin (Full Access)"),
                ),
                DropdownMenuItem(
                  value: 'demo_admin',
                  child: Text("Demo Admin (Restricted)"),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedRoleType = val;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(child: const Text("Cancel"), onPressed: () => Get.back()),
        ElevatedButton(
          child: const Text("Create"),
          onPressed: () {
            if (_uidCtrl.text.isEmpty ||
                _nameCtrl.text.isEmpty ||
                _emailCtrl.text.isEmpty) {
              Get.snackbar("Validation Error", "All fields are required.");
              return;
            }

            final newAdmin = AdminRole(
              uid: _uidCtrl.text.trim(),
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              role: 'admin',
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              createdBy:
                  Get.find<AuthController>().rxAdminRole.value?.uid ?? 'system',
              roleType: _selectedRoleType,
              permissions: _defaultPermissions,
            );

            Get.back();
            widget.controller.saveAdminRole(newAdmin, isEdit: false);
          },
        ),
      ],
    );
  }
}
