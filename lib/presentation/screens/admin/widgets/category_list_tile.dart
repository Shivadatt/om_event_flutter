import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../domain/entities/category.dart';
import '../../../controllers/admin_controller.dart';

/// Modern Card Style category tile matching the Option 2 reference design:
/// - Compact landscape presentation (~240px height)
/// - Hero background image with smooth hover zoom
/// - Top badges: ACTIVE/HIDDEN status pill + SORT order pill
/// - Dark vignette gradient overlay for clean contrast
/// - Clean category title (17px) + 1-line description
/// - Bottom bar: #tag pill, active toggle switch, edit, delete, and gold circular action button
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
    const goldColor = Color(0xFFD4AF37);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: const Color(0xFF101C16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? goldColor.withValues(alpha: 0.6)
                : const Color(0xFF1E3328),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.45 : 0.25),
              blurRadius: _isHovered ? 20 : 10,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── Background Image with subtle hover zoom ─────────
            Positioned.fill(
              child: AnimatedScale(
                scale: _isHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: _buildCategoryThumbnail(cat),
              ),
            ),

            // ── Dark luxury gradient overlay ─────────────────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.35, 0.7, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // ── Top Left: ACTIVE / HIDDEN Status Pill ────────────
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF0C2417).withValues(alpha: 0.9)
                      : const Color(0xFF271214).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF22C55E).withValues(alpha: 0.6)
                        : const Color(0xFFEF4444).withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isActive ? "ACTIVE" : "HIDDEN",
                  style: GoogleFonts.dmSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),

            // ── Top Right: SORT Order Pill ────────────────────────
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: goldColor.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  "SORT ${cat.sortOrder}",
                  style: GoogleFonts.dmSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: goldColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // ── Bottom Content Overlay ───────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category Name
                    Text(
                      cat.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Description (1 line max to prevent oversized card)
                    Text(
                      cat.description.isNotEmpty
                          ? cat.description
                          : "Curated event and decor arrangements tailored for memorable celebrations.",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Bottom Row: Tag, Switch, Edit, Delete, and Arrow Action Button
                    Row(
                      children: [
                        // Tag Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B160E),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: goldColor.withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            "#${cat.slug}",
                            style: GoogleFonts.dmSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: goldColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Active Toggle Switch
                        SizedBox(
                          height: 18,
                          width: 28,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Switch(
                              value: isActive,
                              activeThumbColor: const Color(0xFF22C55E),
                              activeTrackColor: const Color(0xFF143822),
                              inactiveThumbColor: Colors.white38,
                              inactiveTrackColor: Colors.white12,
                              onChanged: (val) {
                                widget.controller.toggleCategoryStatus(
                                  cat.slug,
                                  isActive: val,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Edit Action Icon
                        InkWell(
                          onTap: widget.onEdit,
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Delete Action Icon
                        InkWell(
                          onTap: widget.onDelete,
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                          ),
                        ),

                        const Spacer(),

                        // Gold Round Arrow Action Button
                        InkWell(
                          onTap: widget.onEdit,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: goldColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Color(0xFF0C1410),
                            ),
                          ),
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

    return AppImage(
      url: cat.imageUrl,
      fit: BoxFit.cover,
      placeholder: _buildIcon(cat.icon),
    );
  }

  Widget _buildIcon(String icon) {
    return Center(
      child: Text(
        icon.isNotEmpty ? icon : '✨',
        style: const TextStyle(fontSize: 32, color: AppColors.primaryAccent),
      ),
    );
  }
}
