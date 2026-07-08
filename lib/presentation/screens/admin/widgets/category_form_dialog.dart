import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../domain/entities/category.dart';
import '../../../controllers/admin_controller.dart';
import '../../../../data/datasources/supabase_storage_source.dart';

class CategoryFormDialog extends StatefulWidget {
  final Category? category;
  final AdminController controller;

  const CategoryFormDialog({
    super.key,
    this.category,
    required this.controller,
  });

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  late bool isEdit;
  late TextEditingController nameCtrl;
  late TextEditingController slugCtrl;
  late TextEditingController descCtrl;
  late TextEditingController iconCtrl;
  late TextEditingController colorCtrl;
  late TextEditingController imgCtrl;
  late TextEditingController orderCtrl;

  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    isEdit = cat != null;

    nameCtrl = TextEditingController(text: cat?.name ?? '');
    slugCtrl = TextEditingController(text: cat?.slug ?? '');
    descCtrl = TextEditingController(text: cat?.description ?? '');
    iconCtrl = TextEditingController(text: cat?.icon ?? '✦');
    colorCtrl = TextEditingController(text: cat?.color ?? '#c79b61');
    imgCtrl = TextEditingController(text: cat?.imageUrl ?? '');
    orderCtrl = TextEditingController(text: cat?.sortOrder.toString() ?? '0');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    slugCtrl.dispose();
    descCtrl.dispose();
    iconCtrl.dispose();
    colorCtrl.dispose();
    imgCtrl.dispose();
    orderCtrl.dispose();
    super.dispose();
  }

  Future<void> uploadCategoryImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null) return;

      setState(() {
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

      final storage = Get.find<SupabaseStorageSource>();
      final publicUrl = await storage.uploadFile(
        'images/$fileName',
        fileBytes,
        contentType,
        bucket: 'thumbnails',
      );

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
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              controller: colorCtrl,
              decoration: const InputDecoration(labelText: "Theme Color"),
            ),
            const SizedBox(height: 16),
            Column(
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                              errorBuilder: (_, __, ___) => const Center(
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                      Container(
                                        color: Colors.black45,
                                      ),
                                      const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload_outlined,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              "Click to Change Image",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                            fontWeight: FontWeight.bold,
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
              id: widget.category?.id ?? slugCtrl.text,
              name: nameCtrl.text.trim(),
              slug: slugCtrl.text.trim(),
              description: descCtrl.text.trim(),
              icon: iconCtrl.text.trim(),
              color: colorCtrl.text.trim(),
              imageUrl: imgCtrl.text.trim(),
              sortOrder: sortOrder,
              isActive: widget.category?.isActive ?? true,
            );
            Get.back();
            widget.controller.saveCategory(updatedCat, isEdit: isEdit);
          },
        ),
      ],
    );
  }
}
