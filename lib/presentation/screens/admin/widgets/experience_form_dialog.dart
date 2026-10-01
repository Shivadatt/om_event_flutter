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
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final exp = widget.experience;
    isEdit = exp != null;

    nameCtrl = TextEditingController(text: exp?.name ?? '');
    slugCtrl = TextEditingController(text: exp?.slug ?? '');
    descCtrl = TextEditingController(text: exp?.description ?? '');
    priceCtrl = TextEditingController(
      text: exp != null ? exp.price.toStringAsFixed(exp.price.truncateToDouble() == exp.price ? 0 : 2) : '',
    );
    offerCtrl = TextEditingController(
      text: exp?.offerPrice != null
          ? exp!.offerPrice!.toStringAsFixed(exp.offerPrice!.truncateToDouble() == exp.offerPrice ? 0 : 2)
          : '',
    );
    durCtrl = TextEditingController(
      text: exp != null
          ? exp.durationHours.toStringAsFixed(exp.durationHours.truncateToDouble() == exp.durationHours ? 0 : 1)
          : '3',
    );
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
        backgroundColor: Colors.black87,
        colorText: Colors.white,
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
        backgroundColor: Colors.black87,
        colorText: Colors.white,
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

  void _closeDialog([dynamic result]) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop(result);
    } else if (Get.isDialogOpen == true) {
      Get.back(result: result);
    }
  }

  Future<void> _handleSave() async {
    if (nameCtrl.text.trim().isEmpty ||
        slugCtrl.text.trim().isEmpty ||
        selectedCategoryIds.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Name, Slug and at least one Category are required.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final price = double.tryParse(priceCtrl.text.trim());
    if (price == null || price <= 0) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid Price (INR).",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final offerPrice = double.tryParse(offerCtrl.text.trim());
    final duration = double.tryParse(durCtrl.text.trim()) ?? 3.0;

    final firstCatId = selectedCategoryIds.first;
    final cat = widget.controller.rxCategories.firstWhereOrNull(
      (c) => c.id == firstCatId,
    );

    final updated = Experience(
      id: widget.experience?.id ?? slugCtrl.text.trim(),
      categoryId: cat?.id ?? widget.experience?.categoryId ?? firstCatId,
      categoryName: cat?.name ?? widget.experience?.categoryName ?? 'Celebration',
      categorySlug: cat?.slug ?? widget.experience?.categorySlug ?? firstCatId.toLowerCase(),
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
      packages: widget.experience?.packages ?? const [],
    );

    setState(() => isSaving = true);
    try {
      final success = await widget.controller.saveExperience(updated, isEdit: isEdit);
      if (success && mounted) {
        _closeDialog(true);
        Get.snackbar(
          "Experience Saved",
          "Experience '${updated.name}' saved successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF132219),
          colorText: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stack) {
      debugPrint("[ExperienceSave] ERROR in _handleSave: $e\n$stack");
      Get.snackbar(
        "Save Failed",
        "Error: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget _buildCompactSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            activeTrackColor: const Color(0xFFD4AF37),
            activeThumbColor: Colors.black,
            inactiveTrackColor: const Color(0xFF1E2B23),
            inactiveThumbColor: const Color(0xFF6B7A72),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.sansBody(
                  fontSize: 9,
                  color: const Color(0xFF7D8C83),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color modalBackground = Color(0xFF0E1612);
    const Color modalBorder = Color(0xFF233329);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 32 : 12,
        vertical: 20,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 1080,
          maxHeight: screenHeight * 0.90,
        ),
        decoration: BoxDecoration(
          color: modalBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: modalBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 760;
              final isWideDesktop = constraints.maxWidth >= 940;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── HEADER (Fixed) ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF223228), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit ? "Edit Experience" : "Add Experience",
                                style: AppTheme.sansBody(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "Create a stunning experience with all details and media.",
                                style: AppTheme.sansBody(
                                  fontSize: 11,
                                  color: const Color(0xFF8A9A91),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          color: const Color(0xFF8A9A91),
                          hoverColor: Colors.white10,
                          splashRadius: 18,
                          onPressed: () => _closeDialog(),
                        ),
                      ],
                    ),
                  ),

                  // ── BODY (Scrollable) ──────────────────────────────
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column: Media Showcase (32-34% width)
                                SizedBox(
                                  width: constraints.maxWidth > 900 ? 320 : constraints.maxWidth * 0.35,
                                  child: _buildMediaColumn(context),
                                ),
                                const SizedBox(width: 24),
                                // Right Column: Form Information
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildInformationColumn(context, isWide: constraints.maxWidth >= 900),
                                      if (!isWideDesktop) ...[
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 16,
                                          runSpacing: 12,
                                          children: [
                                            _buildCompactSwitch(
                                              title: "Is Active & Visible on CMS",
                                              subtitle: "Toggle visibility status in catalog lists",
                                              value: isActive,
                                              onChanged: (val) => setState(() => isActive = val),
                                            ),
                                            _buildCompactSwitch(
                                              title: "Feature on Home Gallery",
                                              subtitle: "Pin this setup experience to landing slider",
                                              value: isFeatured,
                                              onChanged: (val) => setState(() => isFeatured = val),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildInformationColumn(context, isWide: false),
                                const SizedBox(height: 20),
                                _buildMediaColumn(context),
                                const SizedBox(height: 18),
                                _buildCompactSwitch(
                                  title: "Is Active & Visible on CMS",
                                  subtitle: "Toggle visibility status in catalog lists",
                                  value: isActive,
                                  onChanged: (val) => setState(() => isActive = val),
                                ),
                                const SizedBox(height: 10),
                                _buildCompactSwitch(
                                  title: "Feature on Home Gallery",
                                  subtitle: "Pin this setup experience to landing slider",
                                  value: isFeatured,
                                  onChanged: (val) => setState(() => isFeatured = val),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // ── FOOTER (Fixed Sticky) ─────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFF223228), width: 1),
                      ),
                    ),
                    child: isWideDesktop
                        ? Row(
                            children: [
                              // Bottom Left: Switches
                              Expanded(
                                child: Row(
                                  children: [
                                    _buildCompactSwitch(
                                      title: "Is Active & Visible on CMS",
                                      subtitle: "Toggle visibility status in catalog lists",
                                      value: isActive,
                                      onChanged: (val) => setState(() => isActive = val),
                                    ),
                                    const SizedBox(width: 24),
                                    _buildCompactSwitch(
                                      title: "Feature on Home Gallery",
                                      subtitle: "Pin this setup experience to the landing portfolio slider",
                                      value: isFeatured,
                                      onChanged: (val) => setState(() => isFeatured = val),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Bottom Right: Cancel & Save Changes
                              _buildCancelButton(),
                              const SizedBox(width: 12),
                              _buildSaveButton(),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildCancelButton(),
                              const SizedBox(width: 12),
                              _buildSaveButton(),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: isSaving ? null : () => _closeDialog(),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF2A3A30), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
      child: Text(
        "Cancel",
        style: AppTheme.sansBody(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: isSaving ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        disabledBackgroundColor: const Color(0xFFD4AF37).withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        elevation: 0,
      ),
      child: isSaving
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Saving...",
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            )
          : Text(
              "Save Changes",
              style: AppTheme.sansBody(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
    );
  }
}
