import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../../domain/entities/category.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/category_list_tile.dart';
import 'widgets/category_form_dialog.dart';

class ManageCategoriesScreen extends GetView<AdminController> {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const AdminBackButton(),
        title: Text(
          "MANAGE CATEGORIES",
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
            onPressed: () => _showCategoryDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingCategories.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = controller.rxCategories;
        if (categories.isEmpty) {
          return const Center(child: Text("No categories loaded."));
        }

        final active = controller.activeCategoriesCount.value;
        final total = categories.length;

        return Column(
          children: [
            // Stats banner
            Container(
              width: double.infinity,
              color: isDark ? const Color(0xFF0F1C17) : const Color(0xFFEAF3EB),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  _statChip(
                    label: "$active Active",
                    color: Colors.green.shade700,
                    textColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  _statChip(
                    label: "${total - active} Hidden",
                    color: Colors.red.shade600,
                    textColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$total Total",
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Category list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return CategoryListTile(
                    cat: cat,
                    isDark: isDark,
                    controller: controller,
                    onEdit: () => _showCategoryDialog(context, category: cat),
                    onDelete: () => _confirmDelete(cat.slug),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _statChip({
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTheme.sansBody(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _confirmDelete(String slug) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Category"),
        content: Text(
          "Are you sure you want to delete category '$slug'? This action cannot be undone.",
        ),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
            onPressed: () {
              Get.back();
              controller.deleteCategory(slug);
            },
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    Get.dialog(
      CategoryFormDialog(
        category: category,
        controller: controller,
      ),
    );
  }
}
