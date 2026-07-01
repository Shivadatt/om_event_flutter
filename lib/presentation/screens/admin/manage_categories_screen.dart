import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../../domain/entities/category.dart';

class ManageCategoriesScreen extends GetView<AdminController> {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
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

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
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
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade900,
                      child:
                          cat.imageUrl.isNotEmpty
                              ? Image.network(
                                cat.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => _buildIcon(cat.icon),
                              )
                              : _buildIcon(cat.icon),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.name,
                            style: AppTheme.serifHeader(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Slug: ${cat.slug} | Order: ${cat.sortOrder}",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? AppTheme.darkMuted
                                      : AppTheme.lightMuted,
                            ),
                          ),
                          if (cat.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              cat.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.sansBody(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed:
                              () => _showCategoryDialog(context, category: cat),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _confirmDelete(cat.slug),
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

  Widget _buildIcon(String icon) {
    return Center(
      child: Text(
        icon,
        style: const TextStyle(fontSize: 22, color: Color(0xFFC9A77E)),
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
    final isEdit = category != null;
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final slugCtrl = TextEditingController(text: category?.slug ?? '');
    final descCtrl = TextEditingController(text: category?.description ?? '');
    final iconCtrl = TextEditingController(text: category?.icon ?? '✦');
    final colorCtrl = TextEditingController(text: category?.color ?? '#c79b61');
    final imgCtrl = TextEditingController(text: category?.imageUrl ?? '');
    final orderCtrl = TextEditingController(
      text: category?.sortOrder.toString() ?? '0',
    );
    bool isActive = category?.isActive ?? true;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEdit ? "Edit Category" : "Add Category"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Name"),
                    onChanged: (val) {
                      if (!isEdit) {
                        slugCtrl.text = val
                            .toLowerCase()
                            .trim()
                            .replaceAll(RegExp(r'\s+'), '-')
                            .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
                      }
                    },
                  ),
                  TextField(
                    controller: slugCtrl,
                    decoration: const InputDecoration(labelText: "Slug"),
                    enabled: !isEdit,
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  TextField(
                    controller: iconCtrl,
                    decoration: const InputDecoration(
                      labelText: "Icon Character",
                    ),
                  ),
                  TextField(
                    controller: colorCtrl,
                    decoration: const InputDecoration(labelText: "Theme Color"),
                  ),
                  TextField(
                    controller: imgCtrl,
                    decoration: const InputDecoration(labelText: "Image URL"),
                  ),
                  TextField(
                    controller: orderCtrl,
                    decoration: const InputDecoration(labelText: "Sort Order"),
                    keyboardType: TextInputType.number,
                  ),
                  SwitchListTile(
                    title: const Text("Is Active"),
                    value: isActive,
                    onChanged: (val) {
                      setState(() {
                        isActive = val;
                      });
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
                child: const Text("Save"),
                onPressed: () {
                  if (nameCtrl.text.isEmpty || slugCtrl.text.isEmpty) {
                    Get.snackbar(
                      "Validation Error",
                      "Name and Slug are required.",
                    );
                    return;
                  }
                  final sortOrder = int.tryParse(orderCtrl.text) ?? 0;
                  final updatedCat = Category(
                    id: category?.id ?? slugCtrl.text,
                    name: nameCtrl.text.trim(),
                    slug: slugCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    icon: iconCtrl.text.trim(),
                    color: colorCtrl.text.trim(),
                    imageUrl: imgCtrl.text.trim(),
                    sortOrder: sortOrder,
                    isActive: isActive,
                  );
                  Get.back();
                  controller.saveCategory(updatedCat, isEdit: isEdit);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
