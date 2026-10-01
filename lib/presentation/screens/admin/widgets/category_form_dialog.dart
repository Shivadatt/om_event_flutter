import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../domain/entities/category.dart';
import '../../../controllers/admin_controller.dart';
import '../../../../data/datasources/supabase_storage_source.dart';

/// Professional desktop Edit/Add Category modal matching Option 2 Modern Card Style:
/// - Single-layer professional desktop form fields (NO double/nested containers)
/// - Deep charcoal/black input background (#0F1512) with subtle border (#22352A)
/// - Rectangular rounded corners (8px radius)
/// - Genuine multiline description textarea (~80px height)
/// - Unified Theme Accent Color and Sort Order single-surface controls
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
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    isEdit = cat != null;

    nameCtrl = TextEditingController(text: cat?.name ?? '');
    slugCtrl = TextEditingController(text: cat?.slug ?? '');
    descCtrl = TextEditingController(text: cat?.description ?? '');
    iconCtrl = TextEditingController(text: cat?.icon ?? '✦');
    colorCtrl = TextEditingController(text: cat?.color ?? '#7c86bd');
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

  Color _parseColor(String hex) {
    try {
      String cleanHex = hex.trim().replaceAll('#', '');
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return const Color(0xFF7C86BD);
    }
  }

  void _incrementSortOrder() {
    final current = int.tryParse(orderCtrl.text.trim()) ?? 0;
    setState(() {
      orderCtrl.text = (current + 1).toString();
    });
  }

  void _decrementSortOrder() {
    final current = int.tryParse(orderCtrl.text.trim()) ?? 0;
    if (current > 0) {
      setState(() {
        orderCtrl.text = (current - 1).toString();
      });
    }
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

  void _openColorPicker() {
    final colors = [
      '#7c86bd',
      '#d4af37',
      '#3ba776',
      '#e5a823',
      '#e05d5d',
      '#5b8def',
      '#a855f7',
      '#c8a26a',
      '#059669',
      '#ec4899',
    ];

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF0F1512),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF22352A)),
        ),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pick Accent Color",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: colors.map((hex) {
                  final c = _parseColor(hex);
                  final isSelected = colorCtrl.text.toLowerCase() == hex.toLowerCase();
                  return InkWell(
                    onTap: () {
                      setState(() {
                        colorCtrl.text = hex;
                      });
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: colorCtrl,
                style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Custom Hex (e.g. #7c86bd)",
                  labelStyle: GoogleFonts.dmSans(fontSize: 11, color: Colors.white60),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF22352A)),
                  ),
                ),
                onSubmitted: (_) {
                  setState(() {});
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (isSaving || isUploading) return;
    final name = nameCtrl.text.trim();
    final slug = slugCtrl.text.trim();
    if (name.isEmpty || slug.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Category Name and Slug are required.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final sortOrder = int.tryParse(orderCtrl.text.trim()) ?? 0;
    final updatedCat = Category(
      id: widget.category?.id ?? slug,
      name: name,
      slug: slug,
      description: descCtrl.text.trim(),
      icon: iconCtrl.text.trim(),
      color: colorCtrl.text.trim(),
      imageUrl: imgCtrl.text.trim(),
      sortOrder: sortOrder,
      isActive: widget.category?.isActive ?? true,
    );

    setState(() {
      isSaving = true;
    });

    try {
      debugPrint("[CategorySave] START - ID: ${updatedCat.id}, Slug: ${updatedCat.slug}, isEdit: $isEdit");
      final success = await widget.controller.saveCategory(updatedCat, isEdit: isEdit);
      debugPrint("[CategorySave] saveCategory returned: $success");

      if (success && mounted) {
        debugPrint("[CategorySave] Dismissing dialog");
        if (Get.isDialogOpen == true) {
          Get.back();
        } else {
          Navigator.of(context, rootNavigator: true).pop(true);
        }
        Get.snackbar(
          "Category Saved",
          "Category '${updatedCat.name}' saved successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF132219),
          colorText: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stack) {
      debugPrint("[CategorySave] ERROR in _saveChanges: $e\n$stack");
      Get.snackbar(
        "Save Failed",
        "Error: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
      debugPrint("[CategorySave] FINALLY: isSaving reset to false");
    }
  }

  // ── Unified single-surface InputDecoration ──────────────────────────
  InputDecoration _inputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  }) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: const Color(0xFF0F1512), // Deep charcoal/black single surface
      hintText: hintText,
      hintStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.white38),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF22352A), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF22352A), width: 1.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF22352A), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 650;

          return Container(
            width: isDesktop ? 740 : double.infinity,
            constraints: BoxConstraints(
              maxWidth: 740,
              maxHeight: isDesktop ? 580 : 750,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1410),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.75),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: goldColor.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 1. Dialog Header ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 18, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? "Edit Category" : "Add Category",
                              style: GoogleFonts.dmSans(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEdit
                                  ? "Update the details of this category"
                                  : "Create a new event category",
                              style: GoogleFonts.dmSans(
                                fontSize: 11.5,
                                color: const Color(0xFFA4A9A7),
                              ),
                            ),
                          ],
                        ),
                        // Close 'X' Button
                        InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF16221B),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Color(0xFF16241C), height: 1, thickness: 1),

                  // ── 2. Dialog Body ────────────────────────────────
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column: Image Preview
                                SizedBox(
                                  width: 225,
                                  height: 395,
                                  child: _buildImageSection(goldColor),
                                ),
                                const SizedBox(width: 20),
                                // Right Column: Form Fields
                                Expanded(
                                  child: _buildFormFields(goldColor),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 160,
                                  child: _buildImageSection(goldColor),
                                ),
                                const SizedBox(height: 16),
                                _buildFormFields(goldColor),
                              ],
                            ),
                    ),
                  ),

                  const Divider(color: Color(0xFF16241C), height: 1, thickness: 1),

                  // ── 3. Dialog Footer (Cancel + Save Changes) ───────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Cancel Button
                        InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white24, width: 1),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.dmSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Save Changes Button (Primary Gold Pill)
                        InkWell(
                          onTap: (isSaving || isUploading) ? null : _saveChanges,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8.5),
                            decoration: BoxDecoration(
                              color: (isSaving || isUploading) ? goldColor.withValues(alpha: 0.6) : goldColor,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: goldColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSaving) ...[
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C1410)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Saving...",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0C1410),
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(
                                    Icons.save_outlined,
                                    size: 15,
                                    color: Color(0xFF0C1410),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Save Changes",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0C1410),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Image Section with Floating "Change Image" Button ───────────────
  Widget _buildImageSection(Color goldColor) {
    final hasImage = imgCtrl.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1512),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF22352A), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          if (hasImage)
            AppImage(
              url: imgCtrl.text.trim(),
              fit: BoxFit.cover,
              placeholder: Container(
                color: const Color(0xFF0F1512),
                child: const Center(
                  child: Icon(Icons.image_outlined, size: 36, color: Colors.white24),
                ),
              ),
            )
          else
            Container(
              color: const Color(0xFF0F1512),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 36, color: goldColor.withValues(alpha: 0.4)),
                    const SizedBox(height: 6),
                    Text(
                      "No Image Selected",
                      style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ),

          // Dark luxury gradient at bottom
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Uploading State Overlay
          if (isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(goldColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Uploading...",
                      style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // "Change Image" Floating Pill Button
          Positioned(
            bottom: 14,
            left: 14,
            right: 14,
            child: InkWell(
              onTap: isUploading ? null : uploadCategoryImage,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: goldColor.withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 14,
                      color: goldColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Change Image",
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form Fields: Single Surface Inputs with Zero Nested Containers ──
  Widget _buildFormFields(Color goldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Category Name *
        _fieldLabel("Category Name *"),
        const SizedBox(height: 6),
        TextFormField(
          controller: nameCtrl,
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(
            hintText: "e.g., Corporate Events",
          ),
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

        const SizedBox(height: 14),

        // 2. Slug / URL Handle *
        _fieldLabel("Slug / URL Handle *"),
        const SizedBox(height: 6),
        TextFormField(
          controller: slugCtrl,
          enabled: !isEdit,
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(
            hintText: "corporate",
            prefixIcon: Icon(
              Icons.link_rounded,
              size: 16,
              color: goldColor.withValues(alpha: 0.8),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 3. Description (Genuine multiline textarea, height ~80px)
        _fieldLabel("Description"),
        const SizedBox(height: 6),
        TextFormField(
          controller: descCtrl,
          maxLines: 3,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: Colors.white,
            height: 1.4,
          ),
          decoration: _inputDecoration(
            hintText: "Polished launches, openings, and branded experiences.",
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),

        const SizedBox(height: 14),

        // 4. Theme Accent Color (Single surface color control)
        _fieldLabel("Theme Accent Color"),
        const SizedBox(height: 6),
        InkWell(
          onTap: _openColorPicker,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1512),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF22352A),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // Color swatch circle
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _parseColor(colorCtrl.text),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    colorCtrl.text.isNotEmpty ? colorCtrl.text : '#7c86bd',
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: goldColor.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 5. Sort Order (Single surface numeric field with up/down steppers)
        _fieldLabel("Sort Order"),
        const SizedBox(height: 6),
        TextFormField(
          controller: orderCtrl,
          keyboardType: TextInputType.number,
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(
            suffixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _incrementSortOrder,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 15,
                      color: Colors.white70,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _decrementSortOrder,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 15,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Consistent uppercase champagne gold label
  Widget _fieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFD4AF37),
        letterSpacing: 0.6,
      ),
    );
  }
}
