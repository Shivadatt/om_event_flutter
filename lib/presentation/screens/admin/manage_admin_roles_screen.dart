import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/add_admin_dialog.dart';
import 'widgets/admin_role_card.dart';
import 'widgets/admin_back_button.dart';

/// Screen managing role access, status, and permissions for the administrator team.
class ManageAdminRolesScreen extends GetView<AdminController> {
  /// Creates a [ManageAdminRolesScreen] instance.
  const ManageAdminRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final searchCtrl = TextEditingController();
    final rxSearchQuery = ''.obs;

    return Scaffold(
      appBar: AppBar(
        leading: const AdminBackButton(),
        title: Text(
          "ADMIN MANAGEMENT",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        actions: [
          Obx(() {
            // Only Super Admins can create new Admins
            final isSuper =
                authController.rxAdminRole.value?.roleType == 'super_admin';
            if (!isSuper) return const SizedBox();
            return IconButton(
              icon: const Icon(Icons.add_moderator),
              onPressed:
                  () => Get.dialog(AddAdminDialog(controller: controller)),
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
                list =
                    list
                        .where(
                          (a) =>
                              a.name.toLowerCase().contains(query) ||
                              a.email.toLowerCase().contains(query),
                        )
                        .toList();
              }

              if (list.isEmpty) {
                return const Center(
                  child: Text("No administrator profiles found."),
                );
              }

              final currentAdmin = authController.rxAdminRole.value;
              final isSuper = currentAdmin?.roleType == 'super_admin';

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final admin = list[index];
                  return AdminRoleCard(
                    admin: admin,
                    isSuper: isSuper,
                    currentAdmin: currentAdmin,
                    controller: controller,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
