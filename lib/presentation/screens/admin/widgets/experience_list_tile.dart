import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/experience.dart';
import '../../../controllers/admin_controller.dart';

class ExperienceListTile extends StatelessWidget {
  final Experience item;
  final bool isDark;
  final AdminController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExperienceListTile({
    super.key,
    required this.item,
    required this.isDark,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  Experience _copyWithActiveFeatured(
    Experience item, {
    bool? active,
    bool? featured,
  }) {
    return Experience(
      id: item.id,
      categoryId: item.categoryId,
      categoryName: item.categoryName,
      categorySlug: item.categorySlug,
      categoryIds: item.categoryIds,
      name: item.name,
      slug: item.slug,
      description: item.description,
      price: item.price,
      offerPrice: item.offerPrice,
      durationHours: item.durationHours,
      popularity: item.popularity,
      rating: item.rating,
      reviewCount: item.reviewCount,
      availability: item.availability,
      tags: item.tags,
      colors: item.colors,
      themes: item.themes,
      imageUrl: item.imageUrl,
      videoUrl: item.videoUrl,
      isFeatured: featured ?? item.isFeatured,
      isActive: active ?? item.isActive,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              color: Colors.grey.shade900,
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 20),
                    )
                  : const Icon(Icons.image, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTheme.serifHeader(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.categoryName,
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.formatCurrency(item.effectivePrice),
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Text(
                      "Active",
                      style: TextStyle(fontSize: 10),
                    ),
                    Switch(
                      value: item.isActive,
                      onChanged: (val) {
                        final updated = _copyWithActiveFeatured(
                          item,
                          active: val,
                        );
                        controller.saveExperience(
                          updated,
                          isEdit: true,
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Featured",
                      style: TextStyle(fontSize: 10),
                    ),
                    Switch(
                      value: item.isFeatured,
                      onChanged: (val) {
                        final updated = _copyWithActiveFeatured(
                          item,
                          featured: val,
                        );
                        controller.saveExperience(
                          updated,
                          isEdit: true,
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
