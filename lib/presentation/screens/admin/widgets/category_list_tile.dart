import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/category.dart';
import '../../../controllers/admin_controller.dart';

class CategoryListTile extends StatefulWidget {
  final Category cat;
  final bool isDark;
  final AdminController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryListTile({
    super.key,
    required this.cat,
    required this.isDark,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CategoryListTile> createState() => _CategoryListTileState();
}

class _CategoryListTileState extends State<CategoryListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.cat;
    final isActive = cat.isActive;
    final isDark = widget.isDark;

    final Color primaryAccent = AppColors.primaryAccent;
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
                child: _buildCategoryThumbnail(cat),
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

            // Floating tags
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.success.withValues(alpha: 0.9)
                      : AppColors.error.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 0.5),
                ),
                child: Text(
                  isActive ? "ACTIVE" : "HIDDEN",
                  style: AppTheme.sansBody(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 0.5),
                ),
                child: Text(
                  "SORT ${cat.sortOrder}",
                  style: AppTheme.sansBody(
                    fontSize: 8,
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
                      cat.name,
                      style: AppTheme.serifHeader(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.description.isNotEmpty
                          ? cat.description
                          : "Curated Event and Floral arrangements tailored for extraordinary celebrations.",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        color: const Color(0xFFFAF6EE).withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Slug & Toggle status
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "#${cat.slug}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.sansBody(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: primaryAccent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 18,
                                width: 28,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Switch(
                                    value: isActive,
                                    activeColor: AppColors.success,
                                    onChanged: (val) {
                                      widget.controller.toggleCategoryStatus(
                                        cat.slug,
                                        isActive: val,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Action buttons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.white),
                              onPressed: widget.onEdit,
                              tooltip: "Edit Category",
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.delete_sweep_outlined, size: 20, color: AppColors.error),
                              onPressed: widget.onDelete,
                              tooltip: "Delete Category",
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

  Widget _buildCategoryThumbnail(Category cat) {
    if (cat.imageUrl.isEmpty) {
      return _buildIcon(cat.icon);
    }

    return Image.network(
      cat.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildIcon(cat.icon),
    );
  }

  Widget _buildIcon(String icon) {
    return Center(
      child: Text(
        icon,
        style: const TextStyle(fontSize: 32, color: AppColors.primaryAccent),
      ),
    );
  }
}
