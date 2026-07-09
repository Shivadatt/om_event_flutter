import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/experience.dart';
import '../../../controllers/admin_controller.dart';

class ExperienceListTile extends StatefulWidget {
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

  @override
  State<ExperienceListTile> createState() => _ExperienceListTileState();
}

class _ExperienceListTileState extends State<ExperienceListTile> {
  bool _isHovered = false;

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
    final item = widget.item;
    final isDark = widget.isDark;

    final Color primaryAccent = AppColors.primaryAccent;
    final Color secondaryAccent = AppColors.secondaryAccent;
    final Color cardColor = isDark ? AppColors.darkForestSecondary : AppColors.lightForest;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? (Matrix4.identity()..translate(0, -8, 0)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isHovered ? primaryAccent.withValues(alpha: 0.6) : borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: _isHovered ? 0.35 : 0.2)
                  : Colors.black.withValues(alpha: _isHovered ? 0.06 : 0.03),
              blurRadius: _isHovered ? 28 : 16,
              offset: _isHovered ? const Offset(0, 14) : const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Hero Image (Full card height)
            Positioned.fill(
              child: AnimatedScale(
                scale: _isHovered ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 32, color: AppColors.primaryAccent),
                      )
                    : const Icon(Icons.image_outlined, size: 32, color: AppColors.primaryAccent),
              ),
            ),

            // Soft luxury vignette overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Floating status badges
            Positioned(
              top: 16,
              left: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isActive
                          ? AppColors.success.withValues(alpha: 0.9)
                          : AppColors.error.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: Text(
                      item.isActive ? "ACTIVE" : "ARCHIVED",
                      style: AppTheme.sansBody(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  if (item.isFeatured) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: secondaryAccent.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                      child: Text(
                        "FEATURED",
                        style: AppTheme.sansBody(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Floating Price Badge overlay
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 0.5),
                ),
                child: Text(
                  AppFormatters.formatCurrency(item.effectivePrice),
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryAccent,
                  ),
                ),
              ),
            ),

            // Editorial Glass Footer (Overlay)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  border: const Border(
                    top: BorderSide(color: Colors.white12, width: 0.8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.categoryName.toUpperCase(),
                      style: AppTheme.sansBody(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: primaryAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      style: AppTheme.serifHeader(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star_border_rounded, size: 12, color: primaryAccent),
                            const SizedBox(width: 4),
                            Text(
                              "${item.rating.toStringAsFixed(1)} (${item.reviewCount})",
                              style: AppTheme.sansBody(
                                fontSize: 11,
                                color: const Color(0xFFFAF6EE).withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${item.durationHours} hours setup",
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            color: const Color(0xFFFAF6EE).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Switches for Featured/Active
                        Row(
                          children: [
                            _buildSwitchLabel("Featured"),
                            SizedBox(
                              height: 18,
                              width: 28,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Switch(
                                  value: item.isFeatured,
                                  activeColor: secondaryAccent,
                                  onChanged: (val) {
                                    widget.controller.saveExperience(
                                      _copyWithActiveFeatured(item, featured: val),
                                      isEdit: true,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSwitchLabel("Active"),
                            SizedBox(
                              height: 18,
                              width: 28,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Switch(
                                  value: item.isActive,
                                  activeColor: AppColors.success,
                                  onChanged: (val) {
                                    widget.controller.saveExperience(
                                      _copyWithActiveFeatured(item, active: val),
                                      isEdit: true,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Actions (Edit, Delete)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.white),
                              onPressed: widget.onEdit,
                              tooltip: "Edit Portfolio Item",
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.delete_sweep_outlined, size: 20, color: AppColors.error),
                              onPressed: widget.onDelete,
                              tooltip: "Delete Portfolio Item",
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Text(
        label,
        style: AppTheme.sansBody(
          fontSize: 9,
          color: const Color(0xFFFAF6EE).withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
