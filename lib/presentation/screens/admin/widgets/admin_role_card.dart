import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../domain/entities/admin_role.dart';
import '../../../controllers/admin_controller.dart';

/// Card component to render and configure individual [AdminRole] profiles.
class AdminRoleCard extends StatelessWidget {
  /// The specific admin role profile details.
  final AdminRole admin;

  /// Whether the current logged-in user is a super admin.
  final bool isSuper;

  /// The active logged-in admin role profile.
  final AdminRole? currentAdmin;

  /// The active admin manager controller.
  final AdminController controller;

  /// Creates an [AdminRoleCard] widget instance.
  const AdminRoleCard({
    super.key,
    required this.admin,
    required this.isSuper,
    required this.currentAdmin,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdminSuper = admin.roleType == 'super_admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      isAdminSuper
                          ? const Color(0xFFC9A77E)
                          : Colors.grey.shade800,
                  child: Text(
                    admin.name.isNotEmpty
                        ? admin.name.substring(0, 1).toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin.name,
                        style: AppTheme.serifHeader(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        admin.email,
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          color:
                              isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isAdminSuper
                                      ? Colors.redAccent.withValues(alpha: 0.2)
                                      : Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              admin.roleType.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color:
                                    isAdminSuper
                                        ? Colors.redAccent
                                        : Colors.blue,
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
                              if (currentAdmin?.roleType == 'demo_admin') {
                                Get.snackbar(
                                  "Unauthorized",
                                  "Demo Admins cannot modify status.",
                                );
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
                            onPressed:
                                () => _showPermissionsDialog(
                                  context,
                                  admin,
                                  isSuper,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              if (isAdminSuper) {
                                Get.snackbar(
                                  "Unauthorized",
                                  "Super Admins cannot be deleted.",
                                );
                                return;
                              }
                              _confirmDelete(admin.uid);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                    onPressed:
                        () => _showPermissionsDialog(context, admin, false),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String uid) {
    Get.dialog(
      AlertDialog(
        title: const Text("Remove Admin"),
        content: const Text(
          "Are you sure you want to remove this administrator profile? They will immediately lose dashboard privileges.",
        ),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Get.back()),
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

  void _showPermissionsDialog(
    BuildContext context,
    AdminRole admin,
    bool canEdit,
  ) {
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
                        initialValue: selectedRoleType,
                        decoration: const InputDecoration(
                          labelText: "Role Type",
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'super_admin',
                            child: Text("Super Admin (Full Access)"),
                          ),
                          DropdownMenuItem(
                            value: 'demo_admin',
                            child: Text("Demo Admin (Fine-grained)"),
                          ),
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Divider(),
                    ...permissionKeys.map((key) {
                      final label =
                          key
                              .replaceAll('can_', '')
                              .replaceAll('_', ' ')
                              .toUpperCase();
                      return CheckboxListTile(
                        title: Text(
                          label,
                          style: const TextStyle(fontSize: 13),
                        ),
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
}
