import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
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

  Widget _dialogField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    bool enabled = true,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    String? hintText,
    Widget? prefixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryAccent = AppColors.primaryAccent;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color inputFillColor = isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTheme.sansBody(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: primaryAccent,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            enabled: enabled,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: AppTheme.sansBody(fontSize: 14, color: textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFillColor,
              hintText: hintText,
              hintStyle: AppTheme.sansBody(
                fontSize: 13,
                color: textColor.withValues(alpha: 0.3),
              ),
              prefixIcon: prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryAccent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryAccent = AppColors.primaryAccent;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color inputFillColor = isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? "EDIT CATEGORY" : "ADD CATEGORY",
                      style: AppTheme.sansBody(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: textColor.withValues(alpha: 0.5),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dialogField(
                        "Category Name *",
                        nameCtrl,
                        hintText: "e.g., Luxury Weddings",
                        prefixIcon: Icon(Icons.title, color: primaryAccent.withValues(alpha: 0.4), size: 18),
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
                      _dialogField(
                        "Slug / URL Handle *",
                        slugCtrl,
                        enabled: !isEdit,
                        hintText: "e.g., luxury-weddings",
                        prefixIcon: Icon(Icons.link, color: primaryAccent.withValues(alpha: 0.4), size: 18),
                      ),
                      _dialogField(
                        "Description",
                        descCtrl,
                        maxLines: 3,
                        hintText: "e.g., Bespoke floral stages, mandaps and grand entry paths...",
                        prefixIcon: Icon(Icons.description_outlined, color: primaryAccent.withValues(alpha: 0.4), size: 18),
                      ),
                      _dialogField(
                        "Theme Accent Color",
                        colorCtrl,
                        hintText: "e.g., #D4AF37",
                        prefixIcon: Icon(Icons.color_lens_outlined, color: primaryAccent.withValues(alpha: 0.4), size: 18),
                      ),
                      const SizedBox(height: 8),
                      // Image Upload
                      Text(
                        "CATEGORY DISPLAY IMAGE",
                        style: AppTheme.sansBody(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: primaryAccent,
                          letterSpacing: 1.0,
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
                              color: inputFillColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderColor,
                                width: 1.2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: isUploading
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFFC79B61),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Uploading to Supabase...",
                                            style: AppTheme.sansBody(
                                              fontSize: 11,
                                              color: textColor.withValues(alpha: 0.6),
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
                                            Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.cloud_upload_outlined,
                                                    color: Colors.white,
                                                    size: 32,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "Click to Change Image",
                                                    style: AppTheme.sansBody(
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
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cloud_upload_outlined,
                                                color: primaryAccent.withValues(alpha: 0.4),
                                                size: 36,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Upload Cover Image",
                                                style: AppTheme.sansBody(
                                                  color: textColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "(Saves to Supabase thumbnail folder)",
                                                style: AppTheme.sansBody(
                                                  color: textColor.withValues(alpha: 0.5),
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
                      const SizedBox(height: 20),
                      _dialogField(
                        "Sort Order",
                        orderCtrl,
                        keyboardType: TextInputType.number,
                        hintText: "e.g., 1",
                        prefixIcon: Icon(Icons.sort, color: primaryAccent.withValues(alpha: 0.4), size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: Text(
                        "CANCEL",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        elevation: 0,
                      ),
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
                      child: Text(
                        "SAVE CHANGES",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
