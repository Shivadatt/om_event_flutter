import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../domain/entities/category.dart';
import '../../../controllers/admin_controller.dart';

class CategoryListTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isActive = cat.isActive;

    return Opacity(
      opacity: isActive ? 1.0 : 0.65,
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Thumbnail
                  Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade900,
                    child: _buildCategoryThumbnail(cat),
                  ),
                  const SizedBox(width: 14),
                  // Name + meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat.name,
                                style: AppTheme.serifHeader(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.shade700
                                    : Colors.red.shade600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isActive ? "ACTIVE" : "INACTIVE",
                                style: AppTheme.sansBody(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Slug: ${cat.slug} | Order: ${cat.sortOrder}",
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            color: isDark
                                ? AppTheme.darkMuted
                                : AppTheme.lightMuted,
                          ),
                        ),
                        if (cat.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            cat.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Edit / Delete
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              // Hidden-from-customers warning
              if (!isActive) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.red.shade400.withValues(alpha: 0.35),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility_off_outlined,
                        size: 14,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "This category is hidden from customers.",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Visibility toggle row
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isActive
                        ? "Visible on customer website"
                        : "Hidden from customer website",
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    ),
                  ),
                  Switch(
                    value: isActive,
                    activeColor: Colors.green.shade600,
                    onChanged: (val) {
                      controller.toggleCategoryStatus(
                        cat.slug,
                        isActive: val,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
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
        style: const TextStyle(fontSize: 22, color: Color(0xFFC9A77E)),
      ),
    );
  }
}
