import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/user_model.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';

class ManageUsersScreen extends GetView<AdminController> {
  const ManageUsersScreen({super.key});

  int _getCrossAxisCount(double width) {
    if (width > 1100) return 3; // Desktop
    if (width > 700) return 2;  // Laptop/Tablet
    return 1;                   // Mobile
  }

  double _getChildAspectRatio(int crossAxisCount, double width) {
    final double cardWidth = (width - 64 - (crossAxisCount - 1) * 24) / crossAxisCount;
    return cardWidth / 195; // Aspect ratio for team cards
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryAccent = AppColors.primaryAccent;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text(
          "STUDIO TEAM",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_moderator_rounded, size: 24, color: primaryAccent),
            onPressed: () => _showAddUserDialog(context),
          ),
          const SizedBox(width: 12),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoadingUsers.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
        }

        final users = controller.rxUsers;
        if (users.isEmpty) {
          return const Center(child: Text("No user profiles found."));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
            final aspect = _getChildAspectRatio(crossAxisCount, constraints.maxWidth);

            return GridView.builder(
              padding: const EdgeInsets.all(32),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: aspect > 0 ? aspect : 1.5,
              ),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                
                // Color badges based on roles
                Color roleColor = AppColors.secondaryAccent;
                if (user.role == 'admin') roleColor = AppColors.primaryAccent;
                if (user.role == 'staff') roleColor = AppColors.highlight;

                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: borderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              backgroundColor: roleColor.withValues(alpha: 0.1),
                              radius: 22,
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name.substring(0, 1).toUpperCase()
                                    : 'U',
                                style: AppTheme.serifHeader(
                                  color: roleColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: AppTheme.serifHeader(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    user.email,
                                    style: AppTheme.sansBody(
                                      fontSize: 11,
                                      color: subtitleColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: roleColor.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                user.role.toUpperCase(),
                                style: AppTheme.sansBody(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: roleColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            // Active status switch
                            Row(
                              children: [
                                Text(
                                  "Active",
                                  style: AppTheme.sansBody(
                                    fontSize: 11,
                                    color: subtitleColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  height: 20,
                                  width: 32,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Switch(
                                      value: user.isActive,
                                      activeColor: AppColors.success,
                                      onChanged: (val) {
                                        final updated = UserModel(
                                          id: user.id,
                                          name: user.name,
                                          email: user.email,
                                          role: user.role,
                                          isActive: val,
                                          createdAt: user.createdAt,
                                        );
                                        controller.saveUser(updated, isEdit: true);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_note_rounded, size: 20, color: textColor),
                              onPressed: () => _showEditUserDialog(context, user),
                              tooltip: "Edit Team Member",
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 14),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_sweep_outlined,
                                size: 20,
                                color: AppColors.error,
                              ),
                              onPressed: () => _confirmDelete(user.id),
                              tooltip: "Delete Team Member",
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(String uid) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete User Profile"),
        content: const Text(
          "Are you sure you want to delete this user profile? The user will lose their admin/staff access.",
        ),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("Delete"),
            onPressed: () {
              Get.back();
              controller.deleteUser(uid);
            },
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    String selectedRole = user.role;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Edit User Profile"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: "Role"),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text("Admin")),
                    DropdownMenuItem(value: 'staff', child: Text("Staff")),
                    DropdownMenuItem(
                      value: 'customer',
                      child: Text("Customer"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedRole = val;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Get.back(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAccent),
                child: const Text("Save"),
                onPressed: () {
                  final updated = UserModel(
                    id: user.id,
                    name: nameCtrl.text.trim(),
                    email: user.email,
                    role: selectedRole,
                    isActive: user.isActive,
                    createdAt: user.createdAt,
                  );
                  Get.back();
                  controller.saveUser(updated, isEdit: true);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final uidCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedRole = 'staff';

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add User Profile"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: uidCtrl,
                    decoration: const InputDecoration(
                      labelText: "Firebase UID (from Console)",
                    ),
                  ),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: "Role"),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text("Admin")),
                      DropdownMenuItem(value: 'staff', child: Text("Staff")),
                      DropdownMenuItem(
                        value: 'customer',
                        child: Text("Customer"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedRole = val;
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
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAccent),
                child: const Text("Create"),
                onPressed: () {
                  if (uidCtrl.text.isEmpty ||
                      nameCtrl.text.isEmpty ||
                      emailCtrl.text.isEmpty) {
                    Get.snackbar(
                      "Validation Error",
                      "All fields are required.",
                    );
                    return;
                  }
                  final newUser = UserModel(
                    id: uidCtrl.text.trim(),
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    role: selectedRole,
                    isActive: true,
                    createdAt: DateTime.now(),
                  );
                  Get.back();
                  controller.saveUser(newUser, isEdit: false);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
