import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/faq_item.dart';
import '../../../controllers/faq_controller.dart';
import '../widgets/admin_back_button.dart';
import '../widgets/admin_layout.dart';

class ManageFaqScreen extends StatefulWidget {
  const ManageFaqScreen({super.key});

  @override
  State<ManageFaqScreen> createState() => _ManageFaqScreenState();
}

class _ManageFaqScreenState extends State<ManageFaqScreen> {
  late final FaqController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<FaqController>()) {
      Get.put(FaqController());
    }
    controller = Get.find<FaqController>();
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
          'FAQ MANAGEMENT',
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
            tooltip: 'Refresh FAQs',
            onPressed: () => controller.bindFaqStream(),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryAccent),
            tooltip: 'Add FAQ Item',
            onPressed: () => _showFaqDialog(context, controller),
          ),
          const SizedBox(width: 12),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: const Color(0xFF091210),
        icon: const Icon(Icons.add),
        label: Text(
          'ADD FAQ',
          style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showFaqDialog(context, controller),
      ),
      body: Obx(() {
        if (controller.rxIsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          );
        }

        if (controller.rxError.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to load FAQ records',
                    style: AppTheme.serifHeader(
                      fontSize: 18,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.rxError.value,
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
                    onPressed: () => controller.bindFaqStream(),
                  ),
                ],
              ),
            ),
          );
        }

        final filteredFaqs = controller.adminFilteredFaqs;

        return Column(
          children: [
            // ── 1. Statistics Cards Overview ─────────────────────────────────
            _buildOverviewStats(context, controller, isDark),

            // ── 2. Search & Category Filters Bar ──────────────────────────────
            _buildFilterBar(context, controller, isDark),

            // ── 3. FAQs List / Empty State ────────────────────────────────────
            Expanded(
              child: filteredFaqs.isEmpty
                  ? _buildEmptyState(context, controller, isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                      itemCount: filteredFaqs.length,
                      itemBuilder: (context, i) {
                        final faq = filteredFaqs[i];
                        return _FaqCard(
                          faq: faq,
                          index: i,
                          isDark: isDark,
                          onEdit: () => _showFaqDialog(context, controller, item: faq),
                          onDelete: () => _confirmDelete(context, controller, faq),
                          onToggleActive: () => controller.toggleActive(faq),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  // ── Overview Statistics Cards ───────────────────────────────────────────────
  Widget _buildOverviewStats(
      BuildContext context, FaqController controller, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: LayoutBuilder(builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final cardWidth = isCompact
            ? (constraints.maxWidth - 12) / 2
            : (constraints.maxWidth - 36) / 4;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _statCard('TOTAL FAQS', '${controller.totalCount}', Icons.quiz_outlined,
                AppColors.primaryAccent, cardWidth, isDark),
            _statCard('ACTIVE', '${controller.activeCount}', Icons.check_circle_outline,
                const Color(0xFF4CAF50), cardWidth, isDark),
            _statCard('INACTIVE', '${controller.inactiveCount}', Icons.visibility_off_outlined,
                Colors.amber.shade700, cardWidth, isDark),
            _statCard('CATEGORIES', '${controller.availableCategories.length - 1}', Icons.category_outlined,
                const Color(0xFF64B5F6), cardWidth, isDark),
          ],
        );
      }),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color,
      double width, bool isDark) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141E1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTheme.sansBody(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.serifHeader(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search & Filter Controls ───────────────────────────────────────────────
  Widget _buildFilterBar(
      BuildContext context, FaqController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryAccent.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Search input
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryAccent.withValues(alpha: 0.25),
                    ),
                  ),
                  child: TextField(
                    onChanged: controller.setSearchQuery,
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      color: isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search questions, answers, or categories...',
                      hintStyle: AppTheme.sansBody(
                        fontSize: 12,
                        color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.primaryAccent),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Active Only Toggle Filter
              InkWell(
                onTap: controller.toggleFilterActiveOnly,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: controller.rxFilterActiveOnly.value
                        ? AppColors.primaryAccent
                        : (isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.rxFilterActiveOnly.value
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 16,
                        color: controller.rxFilterActiveOnly.value
                            ? const Color(0xFF091210)
                            : AppColors.primaryAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Active Only',
                        style: AppTheme.sansBody(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: controller.rxFilterActiveOnly.value
                              ? const Color(0xFF091210)
                              : (isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.availableCategories.map((cat) {
                final isSelected = controller.rxSelectedCategory.value == cat;
                final count = controller.categoryCounts[cat] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => controller.setCategory(cat),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryAccent
                            : (isDark ? const Color(0xFF141E1A) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryAccent
                              : AppColors.primaryAccent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        cat == 'ALL' ? 'ALL ($count)' : '$cat ($count)',
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF091210)
                              : (isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, FaqController controller, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
          const SizedBox(height: 16),
          Text(
            controller.rxSearchQuery.value.isNotEmpty || controller.rxSelectedCategory.value != 'ALL'
                ? 'No FAQs match the current filter or search criteria.'
                : 'No FAQ items yet. Tap + to add your first FAQ.',
            textAlign: TextAlign.center,
            style: AppTheme.sansBody(
              fontSize: 14,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('ADD FAQ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: const Color(0xFF091210),
            ),
            onPressed: () => _showFaqDialog(context, controller),
          ),
        ],
      ),
    );
  }

  void _showFaqDialog(BuildContext context, FaqController controller,
      {FaqItem? item}) {
    Get.dialog(
      _FaqItemDialog(controller: controller, existing: item),
      barrierDismissible: false,
    );
  }

  void _confirmDelete(BuildContext context, FaqController controller, FaqItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B);

    Get.dialog(AlertDialog(
      backgroundColor: isDark ? const Color(0xFF141A18) : const Color(0xFFFBF9F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
      ),
      title: Text(
        'DELETE OR HIDE FAQ',
        style: AppTheme.serifHeader(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected question: "${item.question}"',
            style: AppTheme.sansBody(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• HIDE: Marks the item inactive so it disappears from the customer website while preserving the question in Admin Studio.\n• PERMANENT DELETE: Removes the FAQ item permanently from Firestore.',
            style: AppTheme.sansBody(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.75),
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
            controller.deleteFaq(item.id, permanent: false);
          },
          child: const Text('HIDE (SOFT DELETE)', style: TextStyle(color: Colors.amber)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
          onPressed: () {
            Get.back();
            controller.deleteFaq(item.id, permanent: true);
          },
          child: const Text('PERMANENT DELETE', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}

// ── FAQ Item Card ─────────────────────────────────────────────────────────────

class _FaqCard extends StatefulWidget {
  final FaqItem faq;
  final int index;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _FaqCard({
    required this.faq,
    required this.index,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final faq = widget.faq;
    final isDark = widget.isDark;
    final Color textColor = isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B);

    return AnimatedOpacity(
      opacity: faq.isActive ? 1.0 : 0.6,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D19) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: faq.isActive
                ? AppColors.primaryAccent.withValues(alpha: 0.25)
                : Colors.red.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Display order badge, category pill, active pill, action icons
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${faq.displayOrder > 0 ? faq.displayOrder : widget.index + 1}',
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Category Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2823) : const Color(0xFFF4EEDC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primaryAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      faq.category,
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Active / Hidden Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: faq.isActive
                          ? const Color(0xFF1B5E20).withValues(alpha: 0.8)
                          : Colors.red.shade900.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      faq.isActive ? 'ACTIVE' : 'HIDDEN',
                      style: AppTheme.sansBody(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Quick toggle active
                  InkWell(
                    onTap: widget.onToggleActive,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Tooltip(
                        message: faq.isActive ? 'Hide from website' : 'Show on website',
                        child: Icon(
                          faq.isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                          color: faq.isActive ? const Color(0xFF4CAF50) : Colors.red.shade400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Edit
                  InkWell(
                    onTap: widget.onEdit,
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Tooltip(
                        message: 'Edit FAQ',
                        child: Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryAccent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Delete
                  InkWell(
                    onTap: widget.onDelete,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Tooltip(
                        message: 'Delete or Hide FAQ',
                        child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Question
              Text(
                faq.question,
                style: AppTheme.sansBody(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),

              // Answer with collapse/expand preview
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  faq.answer,
                  maxLines: _isExpanded ? 100 : 2,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: AppTheme.sansBody(
                    fontSize: 12.5,
                    color: textColor.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add / Edit FAQ Dialog ─────────────────────────────────────────────────────

class _FaqItemDialog extends StatefulWidget {
  final FaqController controller;
  final FaqItem? existing;

  const _FaqItemDialog({required this.controller, this.existing});

  @override
  State<_FaqItemDialog> createState() => _FaqItemDialogState();
}

class _FaqItemDialogState extends State<_FaqItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionCtrl;
  late final TextEditingController _answerCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _displayOrderCtrl;
  late bool _isActive;
  bool _isSaving = false;

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _questionCtrl = TextEditingController(text: e?.question ?? '');
    _answerCtrl = TextEditingController(text: e?.answer ?? '');
    _categoryCtrl = TextEditingController(text: e?.category ?? 'BOOKING');
    _displayOrderCtrl = TextEditingController(
      text: (e?.displayOrder ?? (widget.controller.totalCount + 1)).toString(),
    );
    _isActive = e?.isActive ?? true;

    // Check if category matches existing list
    final existingCats = widget.controller.availableCategories.where((c) => c != 'ALL').toList();
    if (existingCats.contains(e?.category.toUpperCase())) {
      _selectedCategory = e?.category.toUpperCase();
    } else {
      _selectedCategory = 'CUSTOM';
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    _categoryCtrl.dispose();
    _displayOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final cat = _categoryCtrl.text.trim().toUpperCase();
      final order = int.tryParse(_displayOrderCtrl.text.trim()) ?? 0;

      final faq = FaqItem(
        id: widget.existing?.id ?? 'faq_${DateTime.now().millisecondsSinceEpoch}',
        question: _questionCtrl.text.trim(),
        answer: _answerCtrl.text.trim(),
        category: cat.isNotEmpty ? cat : 'GENERAL',
        displayOrder: order,
        isActive: _isActive,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.existing != null) {
        await widget.controller.updateFaq(faq);
      } else {
        await widget.controller.createFaq(faq);
      }
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existing != null;
    final Color textColor = isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B);

    final existingCats = widget.controller.availableCategories.where((c) => c != 'ALL').toList();

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF141E1A) : const Color(0xFFFBF9F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.35)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 750),
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
                      isEdit ? 'EDIT FAQ ITEM' : 'ADD FAQ ITEM',
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

                // Question
                _field(
                  'Question *',
                  _questionCtrl,
                  isDark,
                  maxLines: 2,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Question is required' : null,
                ),

                // Answer
                _field(
                  'Answer *',
                  _answerCtrl,
                  isDark,
                  maxLines: 5,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Answer is required' : null,
                ),

                // Category selector dropdown + custom text
                if (existingCats.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Select Category',
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
                      ...existingCats.map((cat) => DropdownMenuItem<String>(
                            value: cat,
                            child: Text(
                              cat,
                              style: AppTheme.sansBody(
                                fontSize: 13,
                                color: textColor,
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
                        _selectedCategory = val;
                        if (val != null && val != 'CUSTOM') {
                          _categoryCtrl.text = val;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Category name text field
                _field(
                  'Category Name *',
                  _categoryCtrl,
                  isDark,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Category is required' : null,
                ),

                // Display Order
                _field(
                  'Display Order',
                  _displayOrderCtrl,
                  isDark,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 8),

                // Active Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1512) : const Color(0xFFF0EDE4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
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
                            'Active (Visible on public website)',
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
                              isEdit ? 'SAVE CHANGES' : 'ADD FAQ',
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
}
