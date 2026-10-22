import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/gallery_controller.dart';
import '../../../../widgets/app_page_container.dart';
import 'gallery_category_circle_item.dart';
import 'gallery_category_helper.dart';

class GalleryCategoryFilterRow extends StatelessWidget {
  final GalleryController controller;
  final ScrollController categoryScrollCtrl;
  final bool isDesktop;
  final Color goldColor;

  const GalleryCategoryFilterRow({
    super.key,
    required this.controller,
    required this.categoryScrollCtrl,
    required this.isDesktop,
    required this.goldColor,
  });

  Widget _buildScrollArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF101E1A),
            border: Border.all(
              color: goldColor.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: goldColor, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      child: Obx(() {
        final categories = controller.rxCategories;
        final selectedCat = controller.rxSelectedCategory.value;
        final allItems = controller.rxGalleryItems;

        return Row(
          children: [
            if (isDesktop) ...[
              _buildScrollArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  categoryScrollCtrl.animateTo(
                    (categoryScrollCtrl.offset - 240).clamp(
                      0.0,
                      categoryScrollCtrl.position.maxScrollExtent,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: SizedBox(
                height: 104,
                child: ListView.builder(
                  controller: categoryScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: categories.length,
                  itemBuilder: (context, idx) {
                    final cat = categories[idx];
                    final isAll = cat.toUpperCase() == 'ALL';
                    final isSelected =
                        isAll
                            ? (selectedCat.isEmpty ||
                                selectedCat.toUpperCase() == 'ALL')
                            : (selectedCat.toLowerCase() == cat.toLowerCase());
                    final imgUrl =
                        isAll
                            ? null
                            : GalleryCategoryHelper.getCategoryImageUrl(
                              cat,
                              allItems,
                            );

                    return GalleryCategoryCircleItem(
                      label: GalleryCategoryHelper.formatCategoryLabel(cat),
                      isSelected: isSelected,
                      isAll: isAll,
                      imageUrl: imgUrl,
                      goldColor: goldColor,
                      onTap: () {
                        controller.setCategory(cat);
                      },
                    );
                  },
                ),
              ),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 8),
              _buildScrollArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  categoryScrollCtrl.animateTo(
                    (categoryScrollCtrl.offset + 240).clamp(
                      0.0,
                      categoryScrollCtrl.position.maxScrollExtent,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ],
        );
      }),
    );
  }
}
