import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../../domain/entities/category.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/category_list_tile.dart';
import 'widgets/category_form_dialog.dart';

class ManageCategoriesScreen extends GetView<AdminController> {
  const ManageCategoriesScreen({super.key});

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4; // Desktop
    if (width > 900) return 3;  // Laptop
    if (width > 600) return 2;  // Tablet
    return 1;                   // Mobile
  }

  double _getChildAspectRatio(int crossAxisCount, double width) {
    final double cardWidth = (width - 64 - (crossAxisCount - 1) * 24) / crossAxisCount;
    return cardWidth / 280; // Aspect ratio for Netflix-style showcase
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isInsideDrawer = AdminLayoutScope.of(context);

    final Color headerColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF111827);
    final Color subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0x14FFFFFF) : const Color(0x0F000000);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text(
          "MANAGE CATEGORIES",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: headerColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, size: 24, color: AppColors.primaryAccent),
            onPressed: () => _showCategoryDialog(context),
          ),
          const SizedBox(width: 12),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent, // Let parent AdminLayout gradient show through
      body: Obx(() {
        if (controller.isLoadingCategories.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4F8CFF)));
        }

        final categories = controller.rxCategories;
        if (categories.isEmpty) {
          return const Center(child: Text("No categories loaded."));
        }

        final active = controller.activeCategoriesCount.value;
        final total = categories.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats banner - Redesigned as modern luxury horizontal badge row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: Row(
                children: [
                  _statChip(
                    context: context,
                    label: "$active Active",
                    color: const Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 12),
                  _statChip(
                    context: context,
                    label: "${total - active} Hidden",
                    color: const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161F2F) : const Color(0xFFFAFAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      "$total Total Categories",
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Responsive Grid of categories
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
                  final aspect = _getChildAspectRatio(crossAxisCount, constraints.maxWidth);

                  return GridView.builder(
                    padding: const EdgeInsets.all(32),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: aspect > 0 ? aspect : 1.0,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return CategoryListTile(
                        cat: cat,
                        isDark: isDark,
                        controller: controller,
                        onEdit: () => _showCategoryDialog(context, category: cat),
                        onDelete: () => _confirmDelete(cat.slug),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _statChip({
    required BuildContext context,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTheme.sansBody(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _confirmDelete(String slug) {
    final isDark = Get.isDarkMode;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(32),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "DELETE CATEGORY",
                    style: AppTheme.sansBody(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Are you sure you want to delete category '$slug'? This action cannot be undone and will permanently remove this catalog division.",
                style: AppTheme.sansBody(
                  fontSize: 13,
                  color: textColor.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
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
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Get.back();
                      controller.deleteCategory(slug);
                    },
                    child: Text(
                      "CONFIRM DELETE",
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    Get.dialog(
      CategoryFormDialog(
        category: category,
        controller: controller,
      ),
    );
  }
}
