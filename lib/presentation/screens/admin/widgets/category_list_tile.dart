import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../domain/entities/category.dart';
import '../../../controllers/admin_controller.dart';

/// Premium Detailed Style category card matching Option 4 reference design:
/// - Compact height (~265-275px) with cover-style hero image
/// - Visible luxury gold card border and hover glow
/// - Top badges: ACTIVE/HIDDEN emerald status badge + SORT order gold badge
/// - Deep vignette gradient ensuring 100% white text legibility
/// - Clean category title + 2-line description
/// - Bottom bar: #tag pill, status switch, edit icon, delete icon, and gold circular action button
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
                ? goldColor.withValues(alpha: 0.85)
                : goldColor.withValues(alpha: 0.28),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.55 : 0.35),
              blurRadius: _isHovered ? 22 : 12,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
            ),
            if (_isHovered)
              BoxShadow(
                color: goldColor.withValues(alpha: 0.16),
                blurRadius: 18,
                spreadRadius: 1,
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

            // ── Protective text contrast gradient overlay ───────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.82),
                      Colors.black.withValues(alpha: 0.96),
                    ],
                    stops: const [0.0, 0.45, 0.65, 0.85, 1.0],
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
                      ? const Color(0xFF0C2417).withValues(alpha: 0.95)
                      : const Color(0xFF271214).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isActive ? const Color(0xFF22C55E) : const Color(0xFFEF4444))
                          .withValues(alpha: 0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  isActive ? "ACTIVE" : "HIDDEN",
                  style: GoogleFonts.dmSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
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
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: goldColor.withValues(alpha: 0.65),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  "SORT ${cat.sortOrder}",
                  style: GoogleFonts.dmSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: goldColor,
                    letterSpacing: 0.6,
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
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 13),
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

                    // Description (2 lines max matching Option 4 reference)
                    Text(
                      cat.description.isNotEmpty
                          ? cat.description
                          : "Curated event and decor arrangements tailored for memorable celebrations.",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        color: const Color(0xFFA4A9A7),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Bottom Row: Tag, Switch, Edit, Delete, and Arrow Action Button
                    Row(
                      children: [
                        // Tag Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16140D).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: goldColor.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            "#${cat.slug}",
                            style: GoogleFonts.dmSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
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
                        Tooltip(
                          message: "Edit Category",
                          child: InkWell(
                            onTap: widget.onEdit,
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Delete Action Icon
                        Tooltip(
                          message: "Delete Category",
                          child: InkWell(
                            onTap: widget.onDelete,
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Gold Round Arrow Action Button
                        Tooltip(
                          message: "Manage Category",
                          child: InkWell(
                            onTap: widget.onEdit,
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: goldColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: goldColor.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: Color(0xFF0C1410),
                              ),
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

  static Alignment getImageAlignment(String slug) {
    switch (slug.toLowerCase()) {
      case 'birthday':
        // Frame upward toward "Happy Birthday" neon sign and ceiling balloon arch
        return const Alignment(0.0, -0.65);
      case 'corporate':
        // Frame toward royal stage arch canopy and floral backdrop
        return const Alignment(0.0, -0.35);
      case 'grand-entries':
      case 'entries':
        // Frame portrait orientation entrance photo and cold pyro from top down
        return const Alignment(0.0, -0.45);
      case 'chhathi-poojan':
        return const Alignment(0.0, -0.30);
      case 'proposal':
        // Frame beach proposal arch and candlelight setup
        return const Alignment(0.0, -0.15);
      case 'wedding':
        return Alignment.center;
      case 'baby':
        return Alignment.center;
      case 'shrimant-sanskar':
        return Alignment.center;
      case 'room-decoration':
        return Alignment.center;
      case 'new-shop-opening':
        return Alignment.center;
      default:
        return Alignment.center;
    }
  }

  Widget _buildCategoryThumbnail(Category cat) {
    if (cat.imageUrl.isEmpty) {
      return _buildIcon(cat.icon);
    }

    return AppImage(
      url: cat.imageUrl,
      fit: BoxFit.cover,
      alignment: getImageAlignment(cat.slug),
      placeholder: _buildIcon(cat.icon),
    );
  }

  Widget _buildIcon(String icon) {
    return Container(
      color: const Color(0xFF14241B),
      child: Center(
        child: Text(
          icon.isNotEmpty ? icon : '✨',
          style: const TextStyle(fontSize: 32, color: AppColors.primaryAccent),
        ),
      ),
    );
  }
}

/// Compact List/Table View row for categories matching Option 4 styling
class CategoryRowTile extends StatefulWidget {
  final Category cat;
  final AdminController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryRowTile({
    super.key,
    required this.cat,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CategoryRowTile> createState() => _CategoryRowTileState();
}

class _CategoryRowTileState extends State<CategoryRowTile> {
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
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF101915),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? goldColor.withValues(alpha: 0.75)
                : goldColor.withValues(alpha: 0.22),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.35 : 0.15),
              blurRadius: _isHovered ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: goldColor.withValues(alpha: 0.35)),
                color: const Color(0xFF1A2620),
              ),
              clipBehavior: Clip.antiAlias,
              child: cat.imageUrl.isNotEmpty
                  ? AppImage(
                      url: cat.imageUrl,
                      fit: BoxFit.cover,
                      alignment: _CategoryListTileState.getImageAlignment(cat.slug),
                      placeholder: Center(
                        child: Text(cat.icon.isNotEmpty ? cat.icon : '✨', style: const TextStyle(fontSize: 20)),
                      ),
                    )
                  : Center(
                      child: Text(cat.icon.isNotEmpty ? cat.icon : '✨', style: const TextStyle(fontSize: 20)),
                    ),
            ),
            const SizedBox(width: 16),

            // Name + Description + Tag
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          cat.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16140D),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: goldColor.withValues(alpha: 0.35), width: 0.8),
                        ),
                        child: Text(
                          "#${cat.slug}",
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: goldColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cat.description.isNotEmpty ? cat.description : "No description provided.",
                    style: GoogleFonts.dmSans(
                      fontSize: 11.5,
                      color: const Color(0xFFA4A9A7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF0C2417) : const Color(0xFF271214),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                  width: 0.8,
                ),
              ),
              child: Text(
                isActive ? "ACTIVE" : "HIDDEN",
                style: GoogleFonts.dmSans(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Sort order badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: goldColor.withValues(alpha: 0.4), width: 0.8),
              ),
              child: Text(
                "SORT ${cat.sortOrder}",
                style: GoogleFonts.dmSans(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Active Switch
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
                    widget.controller.toggleCategoryStatus(cat.slug, isActive: val);
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Edit
            Tooltip(
              message: "Edit",
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 17, color: Colors.white70),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: widget.onEdit,
              ),
            ),

            // Delete
            Tooltip(
              message: "Delete",
              child: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 17, color: Color(0xFFEF4444)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: widget.onDelete,
              ),
            ),
            const SizedBox(width: 6),

            // Action Arrow
            Tooltip(
              message: "Manage",
              child: InkWell(
                onTap: widget.onEdit,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: goldColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: Color(0xFF0C1410),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

