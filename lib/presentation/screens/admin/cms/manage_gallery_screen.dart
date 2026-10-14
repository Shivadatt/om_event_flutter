import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/datasources/supabase_storage_source.dart';
import '../../../../domain/entities/gallery_item.dart';
import '../../../controllers/catalog_controller.dart';
import '../../../controllers/gallery_controller.dart';
import '../widgets/admin_back_button.dart';
import '../widgets/admin_layout.dart';

class ManageGalleryScreen extends StatefulWidget {
  const ManageGalleryScreen({super.key});

  @override
  State<ManageGalleryScreen> createState() => _ManageGalleryScreenState();
}

class _ManageGalleryScreenState extends State<ManageGalleryScreen> {
  late final GalleryController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<GalleryController>()) {
      Get.put(GalleryController());
    }
    controller = Get.find<GalleryController>();
    controller.initAdminStream();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B);
    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text(
          'GALLERY MANAGEMENT',
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryAccent),
            tooltip: 'Refresh Gallery',
            onPressed: () => controller.initAdminStream(),
          ),
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryAccent),
            tooltip: 'Add Gallery Item',
            onPressed: () => _showGalleryItemDialog(context, controller),
          ),
          const SizedBox(width: 12),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildFilterBar(context, controller, isDark),
          Expanded(
            child: Obx(() {
              if (controller.rxIsAdminLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryAccent),
                );
              }

              if (controller.rxAdminError.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text(
                          'Unable to load gallery records',
                          style: AppTheme.serifHeader(
                            fontSize: 18,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          controller.rxAdminError.value,
                          textAlign: TextAlign.center,
                          style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('RETRY'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAccent,
                            foregroundColor: const Color(0xFF091210),
                          ),
                          onPressed: () => controller.initAdminStream(),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final items = controller.displayedAdminGalleryItems;

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 64,
                        color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.rxAdminShowAll.value
                            ? 'No gallery items found.\nTap + to add your first image.'
                            : 'No active gallery items found.\nSwitch to "All" to view inactive items.',
                        textAlign: TextAlign.center,
                        style: AppTheme.sansBody(
                          fontSize: 14,
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('ADD GALLERY ITEM'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          foregroundColor: const Color(0xFF091210),
                        ),
                        onPressed: () => _showGalleryItemDialog(context, controller),
                      ),
                    ],
                  ),
                );
              }

              return LayoutBuilder(builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1400
                    ? 5
                    : constraints.maxWidth > 1050
                        ? 4
                        : constraints.maxWidth > 700
                            ? 3
                            : constraints.maxWidth > 480
                                ? 2
                                : 1;
                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _GalleryItemCard(
                    item: items[i],
                    isDark: isDark,
                    onEdit: () => _showGalleryItemDialog(context, controller, item: items[i]),
                    onDelete: () => _confirmDelete(context, controller, items[i]),
                    onToggleActive: () => controller.toggleGalleryItemActive(items[i]),
                    onToggleFeatured: () => controller.toggleGalleryItemFeatured(items[i]),
                  ),
                );
              });
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
      BuildContext context, GalleryController controller, bool isDark) {
    return Obx(() {
      final showAll = controller.rxAdminShowAll.value;
      final count = controller.displayedAdminGalleryItems.length;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.primaryAccent.withValues(alpha: 0.12),
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              'Show:',
              style: AppTheme.sansBody(
                fontSize: 13,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            const SizedBox(width: 12),
            _FilterChip(
              label: 'All',
              isSelected: showAll,
              onTap: () => controller.rxAdminShowAll.value = true,
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Active Only',
              isSelected: !showAll,
              onTap: () => controller.rxAdminShowAll.value = false,
              isDark: isDark,
            ),
            const Spacer(),
            Text(
              '$count items',
              style: AppTheme.sansBody(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showGalleryItemDialog(BuildContext context, GalleryController controller,
      {GalleryItem? item}) {
    Get.dialog(
      _GalleryItemDialog(controller: controller, existing: item),
      barrierDismissible: false,
    );
  }

  void _confirmDelete(BuildContext context, GalleryController controller, GalleryItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(AlertDialog(
      backgroundColor: isDark ? const Color(0xFF141A18) : const Color(0xFFFBF9F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
      ),
      title: Text(
        'DELETE OR HIDE ITEM',
        style: AppTheme.serifHeader(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor(isDark),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected: "${item.title}"',
            style: AppTheme.sansBody(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• HIDE: Marks the item as inactive. It will disappear from customer views while preserving database history.\n• PERMANENT DELETE: Removes the record permanently from Firestore.',
            style: AppTheme.sansBody(
              fontSize: 12,
              color: textColor(isDark).withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteGalleryItem(item.id, permanent: false);
          },
          child: const Text('HIDE (SOFT DELETE)', style: TextStyle(color: Colors.amber)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
          onPressed: () {
            Get.back();
            controller.deleteGalleryItem(item.id, permanent: true);
          },
          child: const Text('PERMANENT DELETE', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  Color textColor(bool isDark) =>
      isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B);
}

// ── Gallery Item Card ─────────────────────────────────────────────────────────

class _GalleryItemCard extends StatelessWidget {
  final GalleryItem item;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleFeatured;

  const _GalleryItemCard({
    required this.item,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onToggleFeatured,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: item.isActive ? 1.0 : 0.6,
      duration: const Duration(milliseconds: 250),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D19) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isFeatured
                ? AppColors.primaryAccent
                : (item.isActive
                    ? AppColors.primaryAccent.withValues(alpha: 0.25)
                    : Colors.red.withValues(alpha: 0.35)),
            width: item.isFeatured ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview Container with Badges
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryAccent,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                              ),
                            ),
                          )
                        : Container(
                            color: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
                            child: Icon(
                              Icons.image_outlined,
                              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                            ),
                          ),
                  ),

                  // Top gradient shadow for badge readability
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Featured Badge
                  if (item.isFeatured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 11, color: Color(0xFF091210)),
                            const SizedBox(width: 3),
                            Text(
                              'FEATURED',
                              style: AppTheme.sansBody(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF091210),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Active / Inactive Pill
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.isActive
                            ? const Color(0xFF1B5E20).withValues(alpha: 0.85)
                            : Colors.red.shade900.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: item.isActive ? const Color(0xFF4CAF50) : Colors.red.shade400,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        item.isActive ? 'ACTIVE' : 'HIDDEN',
                        style: AppTheme.sansBody(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Sort Order badge (bottom right of image)
                  if (item.sortOrder > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${item.sortOrder}',
                          style: AppTheme.sansBody(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info Card Bottom
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title.isNotEmpty ? item.title : 'Untitled Setup',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.categoryName.isNotEmpty ? item.categoryName : 'Decor & Events',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Featured Toggle
                      InkWell(
                        onTap: onToggleFeatured,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Tooltip(
                            message: item.isFeatured ? 'Unset Featured' : 'Mark as Featured',
                            child: Icon(
                              item.isFeatured ? Icons.star : Icons.star_border,
                              size: 18,
                              color: item.isFeatured
                                  ? AppColors.primaryAccent
                                  : (isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Active Toggle
                      InkWell(
                        onTap: onToggleActive,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Tooltip(
                            message: item.isActive ? 'Hide from Website' : 'Show on Website',
                            child: Icon(
                              item.isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 18,
                              color: item.isActive
                                  ? const Color(0xFF4CAF50)
                                  : Colors.red.shade400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Edit
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Tooltip(
                            message: 'Edit Metadata / Replace Image',
                            child: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Delete
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Tooltip(
                            message: 'Delete or Hide Item',
                            child: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gallery Item Form Dialog (Add / Edit / Replace Image) ─────────────────────

class _GalleryItemDialog extends StatefulWidget {
  final GalleryController controller;
  final GalleryItem? existing;

  const _GalleryItemDialog({required this.controller, this.existing});

  @override
  State<_GalleryItemDialog> createState() => _GalleryItemDialogState();
}

class _GalleryItemDialogState extends State<_GalleryItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _thumbnailCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _categoryNameCtrl;
  late final TextEditingController _categoryIdCtrl;
  late final TextEditingController _tagsCtrl;
  late final TextEditingController _sortCtrl;
  late bool _isActive;
  late bool _isFeatured;
  bool _isSaving = false;
  bool _isUploading = false;

  String? _selectedCategorySlug;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _imageUrlCtrl = TextEditingController(text: e?.imageUrl ?? '');
    _thumbnailCtrl = TextEditingController(text: e?.thumbnailUrl ?? '');
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _categoryNameCtrl = TextEditingController(text: e?.categoryName ?? '');
    _categoryIdCtrl = TextEditingController(text: e?.categoryId ?? '');
    _tagsCtrl = TextEditingController(text: e?.tags.join(', ') ?? '');
    _sortCtrl = TextEditingController(text: (e?.sortOrder ?? 0).toString());
    _isActive = e?.isActive ?? true;
    _isFeatured = e?.isFeatured ?? false;

    // Check if existing category matches any catalog category
    if (Get.isRegistered<CatalogController>()) {
      final cats = Get.find<CatalogController>().rxCategories;
      final match = cats.firstWhereOrNull(
        (c) => c.id == e?.categoryId || c.name.toLowerCase() == e?.categoryName.toLowerCase(),
      );
      if (match != null) {
        _selectedCategorySlug = match.id;
      }
    }
  }

  @override
  void dispose() {
    _imageUrlCtrl.dispose();
    _thumbnailCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _categoryNameCtrl.dispose();
    _categoryIdCtrl.dispose();
    _tagsCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      setState(() => _isUploading = true);

      final file = result.files.first;
      final cleanBaseName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final fileName = 'om_gallery_${DateTime.now().millisecondsSinceEpoch}_$cleanBaseName';

      List<int> fileBytes;
      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else if (file.path != null && !kIsWeb) {
        final dartFile = io.File(file.path!);
        fileBytes = await dartFile.readAsBytes();
      } else {
        throw Exception("Could not read image file bytes.");
      }

      String contentType = 'image/jpeg';
      final lower = fileName.toLowerCase();
      if (lower.endsWith('.png')) {
        contentType = 'image/png';
      } else if (lower.endsWith('.webp')) {
        contentType = 'image/webp';
      } else if (lower.endsWith('.gif')) {
        contentType = 'image/gif';
      }

      final storage = Get.find<SupabaseStorageSource>();
      final publicUrl = await storage.uploadFile(
        'images/$fileName',
        fileBytes,
        contentType,
        bucket: 'gallery',
      );

      setState(() {
        _imageUrlCtrl.text = publicUrl;
        if (_thumbnailCtrl.text.isEmpty) {
          _thumbnailCtrl.text = publicUrl;
        }
      });

      Get.snackbar(
        'Upload Complete',
        'Image saved to Supabase Storage.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Upload Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existing != null;
    final Color textColor = isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B);

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF141E1A) : const Color(0xFFFBF9F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.35)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 850),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'EDIT GALLERY ITEM' : 'ADD GALLERY ITEM',
                      style: AppTheme.serifHeader(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _isSaving ? null : Get.back,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Image Upload & Live Preview Area
                _buildImagePickerPreview(isDark),
                const SizedBox(height: 16),

                _field(
                  'Image URL *',
                  _imageUrlCtrl,
                  isDark,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Image URL is required' : null,
                  onChanged: (_) => setState(() {}),
                ),

                _field(
                  'Title *',
                  _titleCtrl,
                  isDark,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                ),

                // Category selector with CatalogController sync
                _buildCategorySelector(isDark),
                const SizedBox(height: 14),

                _field('Description', _descCtrl, isDark, maxLines: 3),

                Row(
                  children: [
                    Expanded(
                      child: _field(
                        'Display Order',
                        _sortCtrl,
                        isDark,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _field(
                        'Tags (comma-separated)',
                        _tagsCtrl,
                        isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Featured & Active Toggles
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryAccent.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, size: 18, color: AppColors.primaryAccent),
                              const SizedBox(width: 8),
                              Text(
                                'Featured in Highlights',
                                style: AppTheme.sansBody(fontSize: 13, color: textColor),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isFeatured,
                            onChanged: (v) => setState(() => _isFeatured = v),
                            activeThumbColor: AppColors.primaryAccent,
                          ),
                        ],
                      ),
                      const Divider(height: 16, thickness: 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isActive ? Icons.visibility : Icons.visibility_off,
                                size: 18,
                                color: _isActive ? const Color(0xFF4CAF50) : Colors.red.shade400,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Active (Visible on Customer Lounge)',
                                style: AppTheme.sansBody(fontSize: 13, color: textColor),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v),
                            activeThumbColor: const Color(0xFF4CAF50),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : Get.back,
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: const Color(0xFF091210),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF091210),
                              ),
                            )
                          : Text(
                              isEdit ? 'SAVE CHANGES' : 'ADD ITEM',
                              style: AppTheme.sansBody(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerPreview(bool isDark) {
    final previewUrl = _imageUrlCtrl.text.trim();
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1310) : const Color(0xFFEBE6DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (previewUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.network(
                previewUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    'Invalid image URL',
                    style: AppTheme.sansBody(fontSize: 12, color: Colors.red.shade400),
                  ),
                ),
              ),
            ),
          if (previewUrl.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),
          if (_isUploading)
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primaryAccent),
                SizedBox(height: 10),
                Text(
                  'Uploading to Supabase Storage...',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: Text(
                    previewUrl.isEmpty ? 'UPLOAD IMAGE FROM DEVICE' : 'REPLACE IMAGE',
                    style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: const Color(0xFF091210),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: _pickAndUploadImage,
                ),
                const SizedBox(height: 6),
                Text(
                  previewUrl.isEmpty
                      ? 'Uploads directly to Supabase Storage bucket: gallery/images'
                      : 'Or edit public URL manually below',
                  style: AppTheme.sansBody(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    final catalogCats = Get.isRegistered<CatalogController>()
        ? Get.find<CatalogController>().rxCategories
        : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (catalogCats.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            initialValue: _selectedCategorySlug,
            decoration: InputDecoration(
              labelText: 'Select Catalog Category',
              labelStyle: AppTheme.sansBody(
                fontSize: 12,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.2)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            dropdownColor: isDark ? const Color(0xFF141E1A) : Colors.white,
            items: [
              ...catalogCats.map((cat) => DropdownMenuItem<String>(
                    value: cat.id,
                    child: Text(
                      cat.name,
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                      ),
                    ),
                  )),
              DropdownMenuItem<String>(
                value: 'CUSTOM',
                child: Text(
                  'Custom Category...',
                  style: AppTheme.sansBody(
                    fontSize: 13,
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            onChanged: (val) {
              setState(() {
                _selectedCategorySlug = val;
                if (val != null && val != 'CUSTOM') {
                  final cat = catalogCats.firstWhereOrNull((c) => c.id == val);
                  if (cat != null) {
                    _categoryIdCtrl.text = cat.id;
                    _categoryNameCtrl.text = cat.name;
                  }
                }
              });
            },
          ),
          const SizedBox(height: 12),
        ],
        _field(
          'Category Name *',
          _categoryNameCtrl,
          isDark,
          validator: (v) => v == null || v.trim().isEmpty ? 'Category Name is required' : null,
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    bool isDark, {
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        style: AppTheme.sansBody(
          fontSize: 13,
          color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.sansBody(
            fontSize: 12,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.2)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final tags = _tagsCtrl.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      final sortOrder = int.tryParse(_sortCtrl.text) ?? 0;
      final now = DateTime.now();

      final categoryName = _categoryNameCtrl.text.trim();
      final categoryId = _categoryIdCtrl.text.trim().isNotEmpty
          ? _categoryIdCtrl.text.trim()
          : categoryName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

      final item = GalleryItem(
        id: widget.existing?.id ?? '',
        imageUrl: _imageUrlCtrl.text.trim(),
        thumbnailUrl: _thumbnailCtrl.text.trim().isNotEmpty
            ? _thumbnailCtrl.text.trim()
            : _imageUrlCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        categoryId: categoryId,
        categoryName: categoryName,
        tags: tags,
        isActive: _isActive,
        isFeatured: _isFeatured,
        sortOrder: sortOrder,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.existing != null) {
        await widget.controller.updateGalleryItem(item);
      } else {
        await widget.controller.createGalleryItem(item);
      }
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent
              : (isDark ? const Color(0xFF1A2420) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAccent
                : AppColors.primaryAccent.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF091210)
                : (isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B)),
          ),
        ),
      ),
    );
  }
}
