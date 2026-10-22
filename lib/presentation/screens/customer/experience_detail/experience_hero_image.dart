import 'package:flutter/material.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../widgets/item_visual_placeholder.dart';

class ExperienceHeroImage extends StatelessWidget {
  final dynamic item;
  final double height;
  final Color goldColor;

  const ExperienceHeroImage({
    super.key,
    required this.item,
    required this.height,
    required this.goldColor,
  });

  Widget _buildImage(
    String url,
    String title,
    String categorySlug,
    String categoryName,
  ) {
    if (url.isEmpty) {
      return ItemVisualPlaceholder(
        title: title,
        categorySlug: categorySlug,
        categoryName: categoryName,
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => ItemVisualPlaceholder(
              title: title,
              categorySlug: categorySlug,
              categoryName: categoryName,
            ),
      );
    }
    return AppImage(
      url: url,
      fit: BoxFit.cover,
      placeholder: ItemVisualPlaceholder(
        title: title,
        categorySlug: categorySlug,
        categoryName: categoryName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1713),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.08),
            blurRadius: 20,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(
        item.imageUrl as String,
        item.name as String,
        item.categorySlug as String,
        item.categoryName as String,
      ),
    );
  }
}
