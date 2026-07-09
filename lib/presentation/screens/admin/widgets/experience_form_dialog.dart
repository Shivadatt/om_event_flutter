import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/experience.dart';
import '../../../controllers/admin_controller.dart';
import '../../../../data/datasources/supabase_storage_source.dart';

part 'parts/experience_form_fields.dart';
part 'parts/experience_form_media.dart';

class ExperienceFormDialog extends StatefulWidget {
  final Experience? experience;
  final AdminController controller;

  const ExperienceFormDialog({
    super.key,
    this.experience,
    required this.controller,
  });

  @override
  State<ExperienceFormDialog> createState() => _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends State<ExperienceFormDialog> {
  late bool isEdit;
  late TextEditingController nameCtrl;
  late TextEditingController slugCtrl;
  late TextEditingController descCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController offerCtrl;
  late TextEditingController durCtrl;
  late TextEditingController imgCtrl;
  late TextEditingController vidCtrl;
  late TextEditingController tagsCtrl;
  late TextEditingController colorsCtrl;
  late TextEditingController themesCtrl;

  final selectedCategoryIds = <String>{};
  late String availability;
  late bool isActive;
  late bool isFeatured;

  bool isUploadingImage = false;
  bool isUploadingVideo = false;

  @override
  void initState() {
    super.initState();
    final exp = widget.experience;
    isEdit = exp != null;

    nameCtrl = TextEditingController(text: exp?.name ?? '');
    slugCtrl = TextEditingController(text: exp?.slug ?? '');
    descCtrl = TextEditingController(text: exp?.description ?? '');
    priceCtrl = TextEditingController(text: exp?.price.toString() ?? '');
    offerCtrl = TextEditingController(text: exp?.offerPrice?.toString() ?? '');
    durCtrl = TextEditingController(text: exp?.durationHours.toString() ?? '3');
    imgCtrl = TextEditingController(text: exp?.imageUrl ?? '');
    vidCtrl = TextEditingController(text: exp?.videoUrl ?? '');

    tagsCtrl = TextEditingController(text: exp?.tags.join(', ') ?? '');
    colorsCtrl = TextEditingController(text: exp?.colors.join(', ') ?? '');
    themesCtrl = TextEditingController(text: exp?.themes.join(', ') ?? '');

    if (exp != null) {
      selectedCategoryIds.addAll(exp.categoryIds);
      if (selectedCategoryIds.isEmpty && exp.categoryId.isNotEmpty) {
        selectedCategoryIds.add(exp.categoryId);
      }
    } else if (widget.controller.rxCategories.isNotEmpty) {
      selectedCategoryIds.add(widget.controller.rxCategories.first.id);
    }

    availability = exp?.availability ?? 'available';
    isActive = exp?.isActive ?? true;
    isFeatured = exp?.isFeatured ?? false;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    slugCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    offerCtrl.dispose();
    durCtrl.dispose();
    imgCtrl.dispose();
    vidCtrl.dispose();
    tagsCtrl.dispose();
    colorsCtrl.dispose();
    themesCtrl.dispose();
    super.dispose();
  }

  void updateState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> uploadExperienceImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      updateState(() {
        isUploadingImage = true;
      });

      final file = result.files.first;
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
        bucket: 'gallery',
      );

      updateState(() {
        imgCtrl.text = publicUrl;
      });

      Get.snackbar(
        "Upload Successful",
        "Experience image uploaded to Supabase gallery.",
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
      updateState(() {
        isUploadingImage = false;
      });
    }
  }

  Future<void> uploadExperienceVideo() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      updateState(() {
        isUploadingVideo = true;
      });

      final file = result.files.first;
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

      String contentType = 'video/mp4';
      if (fileName.toLowerCase().endsWith('.mov')) {
        contentType = 'video/quicktime';
      } else if (fileName.toLowerCase().endsWith('.avi')) {
        contentType = 'video/x-msvideo';
      }

      final storage = Get.find<SupabaseStorageSource>();
      final publicUrl = await storage.uploadFile(
        'Video/$fileName',
        fileBytes,
        contentType,
        bucket: 'gallery',
      );

      updateState(() {
        vidCtrl.text = publicUrl;
      });

      Get.snackbar(
        "Upload Successful",
        "Experience video uploaded to Supabase gallery.",
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
      updateState(() {
        isUploadingVideo = false;
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

  Color get cardColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkPaper : AppColors.lightPaper;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryAccent = AppColors.primaryAccent;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 600,
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
                      isEdit ? "EDIT EXPERIENCE" : "ADD EXPERIENCE",
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
                      _buildFormFields(context),
                      _buildMediaUploads(context),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        title: Text(
                          "IS ACTIVE & VISIBLE ON CMS",
                          style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        subtitle: Text(
                          "Toggle visibility status in catalog lists",
                          style: AppTheme.sansBody(fontSize: 9, color: textColor.withValues(alpha: 0.5)),
                        ),
                        value: isActive,
                        activeColor: primaryAccent,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => isActive = val),
                      ),
                      SwitchListTile(
                        title: Text(
                          "FEATURE ON HOME GALLERY",
                          style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        subtitle: Text(
                          "Pin this setup experience to the landing portfolio slider",
                          style: AppTheme.sansBody(fontSize: 9, color: textColor.withValues(alpha: 0.5)),
                        ),
                        value: isFeatured,
                        activeColor: primaryAccent,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => isFeatured = val),
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
                        if (nameCtrl.text.isEmpty ||
                            slugCtrl.text.isEmpty ||
                            selectedCategoryIds.isEmpty) {
                          Get.snackbar(
                            "Validation Error",
                            "Name, Slug and Category are required.",
                          );
                          return;
                        }
                        final price = double.tryParse(priceCtrl.text) ?? 0.0;
                        final offerPrice = double.tryParse(offerCtrl.text);
                        final duration = double.tryParse(durCtrl.text) ?? 3.0;

                        final firstCatId = selectedCategoryIds.first;
                        final cat = widget.controller.rxCategories.firstWhere(
                          (c) => c.id == firstCatId,
                        );

                        final updated = Experience(
                          id: widget.experience?.id ?? slugCtrl.text,
                          categoryId: cat.id,
                          categoryName: cat.name,
                          categorySlug: cat.slug,
                          categoryIds: selectedCategoryIds.toList(),
                          name: nameCtrl.text.trim(),
                          slug: slugCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          price: price,
                          offerPrice: offerPrice,
                          durationHours: duration,
                          popularity: widget.experience?.popularity ?? 0,
                          rating: widget.experience?.rating ?? 5.0,
                          reviewCount: widget.experience?.reviewCount ?? 0,
                          availability: availability,
                          tags: tagsCtrl.text
                              .split(',')
                              .map((t) => t.trim())
                              .where((t) => t.isNotEmpty)
                              .toList(),
                          colors: colorsCtrl.text
                              .split(',')
                              .map((c) => c.trim())
                              .where((c) => c.isNotEmpty)
                              .toList(),
                          themes: themesCtrl.text
                              .split(',')
                              .map((t) => t.trim())
                              .where((t) => t.isNotEmpty)
                              .toList(),
                          imageUrl: imgCtrl.text.trim(),
                          videoUrl: vidCtrl.text.trim(),
                          isFeatured: isFeatured,
                          isActive: isActive,
                        );

                        Get.back();
                        widget.controller.saveExperience(updated, isEdit: isEdit);
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
