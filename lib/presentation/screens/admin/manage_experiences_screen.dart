import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../../domain/entities/experience.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/experience_list_tile.dart';
import 'widgets/experience_form_dialog.dart';

class ManageExperiencesScreen extends GetView<AdminController> {
  const ManageExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const AdminBackButton(),
        title: Text(
          "MANAGE CATALOG",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showExperienceDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingExperiences.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = controller.rxExperiences;
        if (items.isEmpty) {
          return const Center(child: Text("No items loaded."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ExperienceListTile(
              item: item,
              isDark: isDark,
              controller: controller,
              onEdit: () => _showExperienceDialog(context, experience: item),
              onDelete: () => _confirmDelete(item.slug),
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(String slug) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Experience"),
        content: Text(
          "Are you sure you want to delete experience '$slug'? This will remove it from the catalog.",
        ),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
            onPressed: () {
              Get.back();
              controller.deleteExperience(slug);
            },
          ),
        ],
      ),
    );
  }

  void _showExperienceDialog(BuildContext context, {Experience? experience}) {
    Get.dialog(
      ExperienceFormDialog(
        experience: experience,
        controller: controller,
      ),
    );
  }
}
