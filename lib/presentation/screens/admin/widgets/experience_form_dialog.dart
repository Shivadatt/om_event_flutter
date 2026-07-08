import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/config/app_theme.dart';
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

    if (exp != null) {
      // ignore: avoid_print
      print("Firestore Document Loaded");
      // ignore: avoid_print
      print("Experience ID: ${exp.id}");
      // ignore: avoid_print
      print("Name: ${exp.name}");
      // ignore: avoid_print
      print("Slug: ${exp.slug}");
      // ignore: avoid_print
      print("category_id: ${exp.categoryId}");
      // ignore: avoid_print
      print("category_ids: ${exp.categoryIds}");
    }
    // ignore: avoid_print
    print("TextControllers initialized");
    // ignore: avoid_print
    print("Selected Categories Count: ${selectedCategoryIds.length}");
    // ignore: avoid_print
    print("Categories Checked: $selectedCategoryIds");
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEdit ? "Edit Experience" : "Add Experience"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFormFields(context),
            _buildMediaUploads(context),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Is Active"),
              value: isActive,
              onChanged: (val) => setState(() => isActive = val),
            ),
            SwitchListTile(
              title: const Text("Is Featured"),
              value: isFeatured,
              onChanged: (val) => setState(() => isFeatured = val),
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

            // ignore: avoid_print
            print("Saving category_ids: ${selectedCategoryIds.toList()}");
            // ignore: avoid_print
            print("Saving category_id: ${cat.id}");

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
        ),
      ],
    );
  }
}
