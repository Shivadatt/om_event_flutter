import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/user_model.dart';
import 'widgets/admin_back_button.dart';

class ManageUsersScreen extends GetView<AdminController> {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const AdminBackButton(),
        title: Text(
          "MANAGE USERS",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_moderator),
            onPressed: () => _showAddUserDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingUsers.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = controller.rxUsers;
        if (users.isEmpty) {
          return const Center(child: Text("No user profiles found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          user.role == 'admin'
                              ? const Color(0xFFC9A77E)
                              : Colors.grey.shade800,
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name.substring(0, 1).toUpperCase()
                            : 'U',
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
                            user.name,
                            style: AppTheme.serifHeader(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? AppTheme.darkMuted
                                      : AppTheme.lightMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  user.role == 'admin'
                                      ? Colors.redAccent.withValues(alpha: 0.2)
                                      : Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color:
                                    user.role == 'admin'
                                        ? Colors.redAccent
                                        : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Active",
                              style: TextStyle(fontSize: 10),
                            ),
                            Switch(
                              value: user.isActive,
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
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed:
                                  () => _showEditUserDialog(context, user),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _confirmDelete(user.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
