import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../domain/entities/admin_role.dart';

class ManageAdminRolesScreen extends GetView<AdminController> {
  const ManageAdminRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchCtrl = TextEditingController();
    final rxSearchQuery = ''.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ADMIN MANAGEMENT",
          style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white),
        ),
        actions: [
          Obx(() {
            // Only Super Admins can create new Admins
            final isSuper = authController.rxAdminRole.value?.roleType == 'super_admin';
            if (!isSuper) return const SizedBox();
            return IconButton(
              icon: const Icon(Icons.add_moderator),
              onPressed: () => _showAddAdminDialog(context),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: "Search admin name or email...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchCtrl.clear();
                    rxSearchQuery.value = '';
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) {
                rxSearchQuery.value = val.toLowerCase().trim();
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingAdminRoles.value) {
                return const Center(child: CircularProgressIndicator());
              }

              var list = controller.rxAdminRoles.toList();
              final query = rxSearchQuery.value;
              if (query.isNotEmpty) {
                list = list.where((a) =>
                    a.name.toLowerCase().contains(query) ||
                    a.email.toLowerCase().contains(query)).toList();
              }

              if (list.isEmpty) {
                return const Center(child: Text("No administrator profiles found."));
              }

              final currentAdmin = authController.rxAdminRole.value;
              final isSuper = currentAdmin?.roleType == 'super_admin';

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final admin = list[index];
                  final isAdminSuper = admin.roleType == 'super_admin';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isAdminSuper ? const Color(0xFFC9A77E) : Colors.grey.shade800,
                                child: Text(
                                  admin.name.isNotEmpty ? admin.name.substring(0, 1).toUpperCase() : 'A',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(admin.name, style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text(admin.email, style: AppTheme.sansBody(fontSize: 11, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isAdminSuper ? Colors.redAccent.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            admin.roleType.replaceAll('_', ' ').toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9, 
                                              fontWeight: FontWeight.bold, 
                                              color: isAdminSuper ? Colors.redAccent : Colors.blue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          admin.isActive ? "ACTIVE" : "INACTIVE",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: admin.isActive ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isSuper) ...[
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Text("Active", style: TextStyle(fontSize: 10)),
                                        Switch(
                                          value: admin.isActive,
                                          onChanged: (val) {
                                            // Demo Admins cannot disable Super Admins
                                            if (currentAdmin?.roleType == 'demo_admin') {
                                              Get.snackbar("Unauthorized", "Demo Admins cannot modify status.");
                                              return;
                                            }
                                            final updated = AdminRole(
                                              uid: admin.uid,
                                              name: admin.name,
                                              email: admin.email,
                                              role: admin.role,
                                              isActive: val,
                                              createdAt: admin.createdAt,
                                              updatedAt: DateTime.now(),
                                              createdBy: admin.createdBy,
                                              roleType: admin.roleType,
                                              permissions: admin.permissions,
                                            );
                                            controller.saveAdminRole(updated, isEdit: true);
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.security_outlined, size: 18),
                                          onPressed: () => _showPermissionsDialog(context, admin, isSuper),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                          onPressed: () {
                                            // Prevent deleting Super Admin by Demo Admin
                                            if (isAdminSuper) {
                                              Get.snackbar("Unauthorized", "Super Admins cannot be deleted.");
                                              return;
                                            }
                                            _confirmDelete(admin.uid);
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ] else ...[
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                                  onPressed: () => _showPermissionsDialog(context, admin, false),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }

  void _confirmDelete(String uid) {
    Get.dialog(
      AlertDialog(
        title: const Text("Remove Admin"),
        content: const Text("Are you sure you want to remove this administrator profile? They will immediately lose dashboard privileges."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
            onPressed: () {
              Get.back();
              controller.deleteAdminRole(uid);
            },
          ),
        ],
      ),
    );
  }

  void _showPermissionsDialog(BuildContext context, AdminRole admin, bool canEdit) {
    final Map<String, bool> tempPermissions = Map.from(admin.permissions);
    final permissionKeys = [
      'can_manage_categories',
      'can_manage_items',
      'can_manage_customers',
      'can_manage_users',
      'can_manage_reviews',
      'can_manage_quotes',
      'can_manage_leads',
      'can_manage_settings',
      'can_create',
      'can_edit',
      'can_delete',
    ];

    // Guarantee missing keys exist
    for (var key in permissionKeys) {
      tempPermissions.putIfAbsent(key, () => false);
    }

    String selectedRoleType = admin.roleType;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          final isSuperSelected = selectedRoleType == 'super_admin';
          return AlertDialog(
            title: Text("${admin.name}'s Permissions"),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canEdit) ...[
                      DropdownButtonFormField<String>(
                        value: selectedRoleType,
                        decoration: const InputDecoration(labelText: "Role Type"),
                        items: const [
                          DropdownMenuItem(value: 'super_admin', child: Text("Super Admin (Full Access)")),
                          DropdownMenuItem(value: 'demo_admin', child: Text("Demo Admin (Fine-grained)")),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedRoleType = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      isSuperSelected
                          ? "Super Admins automatically hold all permissions."
                          : "Fine-grained permissions for Demo Admin:",
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                    const Divider(),
                    ...permissionKeys.map((key) {
                      final label = key.replaceAll('can_', '').replaceAll('_', ' ').toUpperCase();
                      return CheckboxListTile(
                        title: Text(label, style: const TextStyle(fontSize: 13)),
                        value: isSuperSelected ? true : tempPermissions[key],
                        enabled: canEdit && !isSuperSelected,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              tempPermissions[key] = val;
                            });
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text(canEdit ? "Cancel" : "Close"),
                onPressed: () => Get.back(),
              ),
              if (canEdit)
                ElevatedButton(
                  child: const Text("Save Changes"),
                  onPressed: () {
                    final updated = AdminRole(
                      uid: admin.uid,
                      name: admin.name,
                      email: admin.email,
                      role: admin.role,
                      isActive: admin.isActive,
                      createdAt: admin.createdAt,
                      updatedAt: DateTime.now(),
                      createdBy: admin.createdBy,
                      roleType: selectedRoleType,
                      permissions: tempPermissions,
                    );
                    Get.back();
                    controller.saveAdminRole(updated, isEdit: true);
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  void _showAddAdminDialog(BuildContext context) {
    final uidCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedRoleType = 'demo_admin';

    final Map<String, bool> defaultPermissions = {
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

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Admin Profile"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: uidCtrl,
                    decoration: const InputDecoration(labelText: "Firebase User UID"),
                  ),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: "Email Address"),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedRoleType,
                    decoration: const InputDecoration(labelText: "Role Type"),
                    items: const [
                      DropdownMenuItem(value: 'super_admin', child: Text("Super Admin (Full Access)")),
                      DropdownMenuItem(value: 'demo_admin', child: Text("Demo Admin (Restricted)")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedRoleType = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Get.back(),
              ),
              ElevatedButton(
                child: const Text("Create"),
                onPressed: () {
                  if (uidCtrl.text.isEmpty || nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
                    Get.snackbar("Validation Error", "All fields are required.");
                    return;
                  }

                  final newAdmin = AdminRole(
                    uid: uidCtrl.text.trim(),
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    role: 'admin',
                    isActive: true,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    createdBy: Get.find<AuthController>().rxAdminRole.value?.uid ?? 'system',
                    roleType: selectedRoleType,
                    permissions: defaultPermissions,
                  );

                  Get.back();
                  controller.saveAdminRole(newAdmin, isEdit: false);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
