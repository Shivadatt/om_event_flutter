import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../../domain/entities/category.dart';
import '../../../data/datasources/supabase_storage_source.dart';
import 'widgets/admin_back_button.dart';

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
                  return _buildCategoryCard(context, cat, isDark);
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

  Widget _buildCategoryCard(BuildContext context, Category cat, bool isDark) {
    final isActive = cat.isActive;

    return Opacity(
      opacity: isActive ? 1.0 : 0.65,
      child: Card(
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
                  // Thumbnail
                  Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade900,
                    child: _buildCategoryThumbnail(cat),
                  ),
                  const SizedBox(width: 14),
                  // Name + meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat.name,
                                style: AppTheme.serifHeader(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.shade700
                                    : Colors.red.shade600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isActive ? "ACTIVE" : "INACTIVE",
                                style: AppTheme.sansBody(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Slug: ${cat.slug} | Order: ${cat.sortOrder}",
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            color: isDark
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
                  // Edit / Delete
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () =>
                            _showCategoryDialog(context, category: cat),
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
              // Hidden-from-customers warning
              if (!isActive) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.red.shade400.withValues(alpha: 0.35),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility_off_outlined,
                        size: 14,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "This category is hidden from customers.",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Visibility toggle row
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isActive
                        ? "Visible on customer website"
                        : "Hidden from customer website",
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    ),
                  ),
                  Switch(
                    value: isActive,
                    activeColor: Colors.green.shade600,
                    onChanged: (val) {
                      controller.toggleCategoryStatus(
                        cat.slug,
                        isActive: val,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
    final iconCtrl = TextEditingController(text: category?.icon ?? 'U+2726');
    final colorCtrl = TextEditingController(text: category?.color ?? '#c79b61');
    final imgCtrl = TextEditingController(text: category?.imageUrl ?? '');
    final orderCtrl = TextEditingController(
      text: category?.sortOrder.toString() ?? '0',
    );

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
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setUploadState) {
                      bool isUploading = false;

                      Future<void> uploadCategoryImage() async {
                        try {
                          final result = await FilePicker.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                            withData: true,
                          );

                          if (result == null) return;

                          setUploadState(() {
                            isUploading = true;
                          });

                          final file = result.files.single;
                          final fileName = file.name;

                          List<int> fileBytes;
                          if (file.bytes != null) {
                            fileBytes = file.bytes!;
                          } else if (file.path != null) {
                            final dartFile = io.File(file.path!);
                            fileBytes = await dartFile.readAsBytes();
                          } else {
                            throw Exception("Could not read file data.");
                          }

                          String contentType = 'image/jpeg';
                          if (fileName.toLowerCase().endsWith('.png')) {
                            contentType = 'image/png';
                          }

                          // Upload to Supabase Storage inside the 'thumbnails' bucket, 'images' folder
                          final storage = Get.find<SupabaseStorageSource>();
                          final publicUrl = await storage.uploadFile(
                            'images/$fileName',
                            fileBytes,
                            contentType,
                            bucket: 'thumbnails',
                          );

                          // Update controller text & trigger main dialog state rebuild
                          setState(() {
                            imgCtrl.text = publicUrl;
                          });

                          Get.snackbar(
                            "Upload Successful",
                            "Category image uploaded to Supabase thumbnail folder.",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } catch (e) {
                          Get.snackbar(
                            "Upload Failed",
                            e.toString(),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.shade900,
                            colorText: Colors.white,
                          );
                        } finally {
                          setUploadState(() {
                            isUploading = false;
                          });
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Category Image Preview",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: isUploading ? null : uploadCategoryImage,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.grey.shade800,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: isUploading
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFFC79B61),
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                "Uploading to Supabase...",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : imgCtrl.text.isNotEmpty
                                          ? Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                imgCtrl.text.startsWith('assets/')
                                                    ? Image.asset(
                                                        imgCtrl.text,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.network(
                                                        imgCtrl.text,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (_, __, ___) =>
                                                                const Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .broken_image_outlined,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                      ),
                                                Container(
                                                  color: Colors.black45,
                                                ),
                                                const Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .cloud_upload_outlined,
                                                        color: Colors.white,
                                                        size: 32,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        "Click to Change Image",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.cloud_upload_outlined,
                                                    color: Colors.grey,
                                                    size: 36,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "Click to Upload Category Image",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "(Saves to Supabase thumbnail folder)",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: orderCtrl,
                    decoration: const InputDecoration(labelText: "Sort Order"),
                    keyboardType: TextInputType.number,
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
                    isActive: category?.isActive ?? true,
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

  Widget _buildCategoryThumbnail(Category cat) {
    if (cat.imageUrl.isEmpty) {
      return _buildIcon(cat.icon);
    }

    return Image.network(
      cat.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildIcon(cat.icon),
    );
  }
}
