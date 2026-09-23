import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/gallery_item.dart';
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
    // Ensure GalleryController is available
    if (!Get.isRegistered<GalleryController>()) {
      Get.put(GalleryController());
    }
    controller = Get.find<GalleryController>();
    // Lazy-start the admin stream (H-2 fix) — only opened when admin enters this screen.
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
              if (controller.rxIsLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryAccent),
                );
              }

              final items = controller.rxAllGalleryItems;

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 64,
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted),
                      const SizedBox(height: 16),
                      Text(
                        'No gallery items yet.\nTap + to add your first image.',
                        textAlign: TextAlign.center,
                        style: AppTheme.sansBody(
                          fontSize: 14,
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return LayoutBuilder(builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1200
                    ? 5
                    : constraints.maxWidth > 900
                        ? 4
                        : constraints.maxWidth > 600
                            ? 3
                            : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _GalleryItemCard(
                    item: items[i],
                    isDark: isDark,
                    onEdit: () => _showGalleryItemDialog(context, controller, item: items[i]),
                    onDelete: () => _confirmDelete(context, controller, items[i].id),
                    onToggleActive: () => controller.toggleGalleryItemActive(items[i]),
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
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            Obx(() => Text(
                  '${controller.rxAllGalleryItems.length} items',
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                )),
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

  void _confirmDelete(BuildContext context, GalleryController controller, String id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(AlertDialog(
      backgroundColor: isDark ? const Color(0xFF141A18) : const Color(0xFFFBF9F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
      ),
      title: Text('REMOVE ITEM',
          style: AppTheme.serifHeader(fontSize: 18, fontWeight: FontWeight.bold, color: textColor(isDark))),
      content: Text(
        'This will hide the gallery item from the customer website.\nThe record is preserved in the database.',
        style: AppTheme.sansBody(fontSize: 13, color: textColor(isDark).withValues(alpha: 0.7)),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('CANCEL')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
          onPressed: () {
            Get.back();
            controller.deleteGalleryItem(id);
          },
          child: const Text('REMOVE', style: TextStyle(color: Colors.white)),
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

  const _GalleryItemCard({
    required this.item,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: item.isActive ? 1.0 : 0.55,
      duration: const Duration(milliseconds: 250),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2420) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isActive
                ? AppColors.primaryAccent.withValues(alpha: 0.25)
                : Colors.red.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
                          child: Icon(Icons.broken_image_outlined,
                              color: isDark ? AppColors.darkMuted : AppColors.lightMuted),
                        ),
                      )
                    : Container(
                        color: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
                        child: Icon(Icons.image_outlined,
                            color: isDark ? AppColors.darkMuted : AppColors.lightMuted),
                      ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                    ),
                  ),
                  if (item.categoryName.isNotEmpty)
                    Text(
                      item.categoryName,
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Active toggle
                      InkWell(
                        onTap: onToggleActive,
                        borderRadius: BorderRadius.circular(4),
                        child: Tooltip(
                          message: item.isActive ? 'Deactivate' : 'Activate',
                          child: Icon(
                            item.isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 16,
                            color: item.isActive
                                ? const Color(0xFF4CAF50)
                                : Colors.red.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(4),
                        child: const Tooltip(
                          message: 'Edit',
                          child: Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryAccent),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(4),
                        child: Tooltip(
                          message: 'Remove',
                          child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400),
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

// ── Gallery Item Form Dialog ──────────────────────────────────────────────────

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
  late final TextEditingController _serviceNameCtrl;
  late final TextEditingController _tagsCtrl;
  late final TextEditingController _sortCtrl;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _imageUrlCtrl = TextEditingController(text: e?.imageUrl ?? '');
    _thumbnailCtrl = TextEditingController(text: e?.thumbnailUrl ?? '');
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _categoryNameCtrl = TextEditingController(text: e?.categoryName ?? '');
    _serviceNameCtrl = TextEditingController(text: e?.serviceName ?? '');
    _tagsCtrl = TextEditingController(text: e?.tags.join(', ') ?? '');
    _sortCtrl = TextEditingController(text: (e?.sortOrder ?? 0).toString());
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _imageUrlCtrl.dispose();
    _thumbnailCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _categoryNameCtrl.dispose();
    _serviceNameCtrl.dispose();
    _tagsCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existing != null;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF141A18) : const Color(0xFFFBF9F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
      ),
      child: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'EDIT GALLERY ITEM' : 'ADD GALLERY ITEM',
                  style: AppTheme.serifHeader(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _field('Image URL *', _imageUrlCtrl, isDark,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                _field('Thumbnail URL', _thumbnailCtrl, isDark),
                _field('Title *', _titleCtrl, isDark,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                _field('Description', _descCtrl, isDark, maxLines: 3),
                _field('Category Name', _categoryNameCtrl, isDark),
                _field('Service Name', _serviceNameCtrl, isDark),
                _field('Tags (comma-separated)', _tagsCtrl, isDark),
                _field('Sort Order', _sortCtrl, isDark,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Switch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeThumbColor: AppColors.primaryAccent,
                    ),
                    const SizedBox(width: 8),
                    Text('Active (visible on customer website)',
                        style: AppTheme.sansBody(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                        )),
                  ],
                ),
                const SizedBox(height: 24),
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
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isEdit ? 'SAVE CHANGES' : 'ADD ITEM',
                              style: AppTheme.sansBody(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _field(
    String label,
    TextEditingController ctrl,
    bool isDark, {
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
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

      final item = GalleryItem(
        id: widget.existing?.id ?? '',
        imageUrl: _imageUrlCtrl.text.trim(),
        thumbnailUrl: _thumbnailCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        categoryName: _categoryNameCtrl.text.trim(),
        serviceName: _serviceNameCtrl.text.trim(),
        tags: tags,
        isActive: _isActive,
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
