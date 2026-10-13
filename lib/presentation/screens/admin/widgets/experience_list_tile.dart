import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../domain/entities/experience.dart';
import '../../../controllers/admin_controller.dart';

/// Compact, premium Experience catalog card designed to match
/// Option 4 Premium Detailed Style reference design:
/// - 4 cards per row on desktop (~268px height)
/// - Compact landscape thumbnail (~118px) with FEATURED, ACTIVE, and Price badges
/// - Small uppercase gold category label, bold title, rating & setup duration
/// - Compact action row: Star (Featured toggle), Eye (Active toggle), Edit, Delete,
///   and circular gold arrow CTA button
/// - Supports both Grid view (compact card) and List view (horizontal row)
class ExperienceListTile extends StatefulWidget {
  final Experience item;
  final bool isDark;
  final AdminController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isListView;

  const ExperienceListTile({
    super.key,
    required this.item,
    required this.isDark,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
    this.isListView = false,
  });

  @override
  State<ExperienceListTile> createState() => _ExperienceListTileState();
}

class _ExperienceListTileState extends State<ExperienceListTile> {
  bool _isHovered = false;

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _mintColor = Color(0xFF2DD4BF);
  static const Color _cardBg = Color(0xFF0D1511);

  @override
  Widget build(BuildContext context) {
    if (widget.isListView) {
      return _buildListRow();
    }
    return _buildGridCard();
  }

  // ── Image BoxFit Resolution: Landscape cover matching Option 4 reference ──
  BoxFit _resolveImageFit(Experience item) {
    return BoxFit.cover;
  }

  // ── Smart Focal Alignment for Decoration Photos ────────────────────
  Alignment _resolveImageAlignment(Experience item) {
    final url = item.imageUrl.toLowerCase();
    final slug = item.slug.toLowerCase();
    final name = item.name.toLowerCase();

    // 1. Smoke Pot Entry (portrait 9:16 - focus on couple in smoke)
    if (url.contains('smoke') || slug.contains('smoke') || name.contains('smoke')) {
      return const Alignment(0.0, -0.30);
    }

    // 2. Haldi & Mehndi Decor (portrait 2:3 - focus on floral seating)
    if (url.contains('mehndi') || slug.contains('mehndi') || name.contains('mehndi') || slug.contains('haldi') || name.contains('haldi')) {
      return const Alignment(0.0, -0.15);
    }

    // 3. Birthday Celebration (keep golden ceiling chandeliers & backdrop in frame)
    if (url.contains('birthday') || slug.contains('birthday') || name.contains('birthday')) {
      return const Alignment(0.0, -0.15);
    }

    // 4. Traditional Rituals / Vana Rasam (sacred brass & clay pots on floral floor)
    if (url.contains('vanarasam') || slug.contains('vana') || name.contains('vana') || name.contains('rasam')) {
      return const Alignment(0.0, 0.08);
    }

    // 5. Chhathi Pujan (ritual boards & artificial green turf setup on stage floor)
    if (url.contains('chhathhi') || slug.contains('chhathi') || name.contains('chhathi')) {
      return const Alignment(0.0, 0.12);
    }

    // 6. Balloon Decoration (frame round balloon arch & Happy Birthday neon sign)
    if (url.contains('baloondecor') || slug.contains('balloon-decor') || name.contains('balloon decoration') || name.contains('balloon decor')) {
      return const Alignment(0.0, -0.12);
    }

    // 7. Pyro Entry (frame bride, groom and cold fireworks spark fountains)
    if (url.contains('pyro') || slug.contains('pyro') || name.contains('pyro') || name.contains('firework')) {
      return const Alignment(0.0, 0.08);
    }

    return Alignment.center;
  }

  // ── 1. Compact 4-Column Option 4 Grid Card ──────────────────────────
  Widget _buildGridCard() {
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? Matrix4.translationValues(0, -3, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? _goldColor.withValues(alpha: 0.80)
                : _goldColor.withValues(alpha: 0.28),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.5 : 0.3),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 3),
            ),
            if (_isHovered)
              BoxShadow(
                color: _goldColor.withValues(alpha: 0.12),
                blurRadius: 14,
                spreadRadius: 1,
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Image Container (168px, Option 4 reference proportion) ──
            Container(
              height: 168,
              width: double.infinity,
              color: const Color(0xFF080E0B),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    url: item.imageUrl,
                    fit: _resolveImageFit(item),
                    alignment: _resolveImageAlignment(item),
                  ),

                  // Subtle top-only vignette for badge legibility without darkening decoration
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33000000), // 20% black for badge contrast
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.25],
                      ),
                    ),
                  ),

                  // Top-Left Badges (FEATURED, ACTIVE / HIDDEN)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.isFeatured) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "FEATURED",
                              style: GoogleFonts.dmSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0C1410),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: item.isActive
                                ? _mintColor
                                : Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                            border: item.isActive
                                ? null
                                : Border.all(
                                    color: Colors.white24,
                                    width: 0.8,
                                  ),
                          ),
                          child: Text(
                            item.isActive ? "ACTIVE" : "HIDDEN",
                            style: GoogleFonts.dmSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: item.isActive
                                  ? const Color(0xFF0C1410)
                                  : Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top-Right Price Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _goldColor.withValues(alpha: 0.45),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        AppFormatters.formatCurrency(item.effectivePrice),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _goldColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Card Body Section (~140px) ───────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category & Title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.categoryName.isNotEmpty
                              ? item.categoryName.toUpperCase()
                              : "EVENT CELEBRATION",
                          style: GoogleFonts.dmSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: _goldColor,
                            letterSpacing: 0.8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.5),
                        Text(
                          item.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.22,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Rating & Duration row
                    Row(
                      children: [
                        if (item.rating > 0) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: _goldColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.reviewCount > 0
                                ? "${item.rating.toStringAsFixed(1)} (${item.reviewCount})"
                                : item.rating.toStringAsFixed(1),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (item.durationHours > 0) ...[
                          const Icon(
                            Icons.schedule_rounded,
                            size: 11.5,
                            color: Colors.white38,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${item.durationHours.toInt() == item.durationHours ? item.durationHours.toInt() : item.durationHours} hrs setup",
                            style: GoogleFonts.dmSans(
                              fontSize: 10.5,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Bottom Action Row
                    Row(
                      children: [
                        // Featured Star Toggle
                        _buildActionIcon(
                          icon: item.isFeatured
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: item.isFeatured ? _goldColor : Colors.white38,
                          tooltip: item.isFeatured
                              ? "Remove Featured"
                              : "Mark Featured",
                          onTap: () => widget.controller.toggleExperienceFeatured(
                            item,
                            !item.isFeatured,
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Active Visibility Toggle
                        _buildActionIcon(
                          icon: item.isActive
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: item.isActive ? _mintColor : Colors.white38,
                          tooltip: item.isActive ? "Hide Experience" : "Show Experience",
                          onTap: () => widget.controller.toggleExperienceActive(
                            item,
                            !item.isActive,
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Edit Button
                        _buildActionIcon(
                          icon: Icons.edit_outlined,
                          color: Colors.white70,
                          tooltip: "Edit Experience",
                          onTap: widget.onEdit,
                        ),
                        const SizedBox(width: 4),

                        // Delete Button
                        _buildActionIcon(
                          icon: Icons.delete_outline_rounded,
                          color: const Color(0xFFEF4444),
                          tooltip: "Delete Experience",
                          onTap: widget.onDelete,
                        ),

                        const Spacer(),

                        // Option 4 Signature Circular Gold Arrow CTA Button
                        Tooltip(
                          message: "Manage Experience",
                          child: InkWell(
                            onTap: widget.onEdit,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: _goldColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _goldColor.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1.5),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: Color(0xFF0C1410),
                                ),
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

  // ── 2. Horizontal List View Row ────────────────────────────────────
  Widget _buildListRow() {
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? _goldColor.withValues(alpha: 0.75)
                : _goldColor.withValues(alpha: 0.22),
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
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _goldColor.withValues(alpha: 0.35)),
                color: const Color(0xFF14201A),
              ),
              clipBehavior: Clip.antiAlias,
              child: AppImage(
                url: item.imageUrl,
                fit: _resolveImageFit(item),
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(width: 14),

            // Category & Name & Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        item.categoryName.isNotEmpty
                            ? item.categoryName.toUpperCase()
                            : "EVENT CELEBRATION",
                        style: GoogleFonts.dmSans(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: _goldColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (item.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "FEATURED",
                            style: GoogleFonts.dmSans(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0C1410),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Price
            Text(
              AppFormatters.formatCurrency(item.effectivePrice),
              style: GoogleFonts.dmSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: _goldColor,
              ),
            ),
            const SizedBox(width: 14),

            // Rating
            if (item.rating > 0) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 13, color: _goldColor),
                  const SizedBox(width: 3),
                  Text(
                    item.reviewCount > 0
                        ? "${item.rating.toStringAsFixed(1)} (${item.reviewCount})"
                        : item.rating.toStringAsFixed(1),
                    style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(width: 14),
            ],

            // Featured Toggle
            _buildActionIcon(
              icon: item.isFeatured ? Icons.star_rounded : Icons.star_border_rounded,
              color: item.isFeatured ? _goldColor : Colors.white38,
              tooltip: item.isFeatured ? "Remove Featured" : "Mark Featured",
              onTap: () => widget.controller.toggleExperienceFeatured(item, !item.isFeatured),
            ),
            const SizedBox(width: 4),

            // Active Visibility Toggle
            _buildActionIcon(
              icon: item.isActive ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: item.isActive ? _mintColor : Colors.white38,
              tooltip: item.isActive ? "Hide Experience" : "Show Experience",
              onTap: () => widget.controller.toggleExperienceActive(item, !item.isActive),
            ),
            const SizedBox(width: 4),

            // Edit
            _buildActionIcon(
              icon: Icons.edit_outlined,
              color: Colors.white70,
              tooltip: "Edit Experience",
              onTap: widget.onEdit,
            ),
            const SizedBox(width: 4),

            // Delete
            _buildActionIcon(
              icon: Icons.delete_outline_rounded,
              color: const Color(0xFFEF4444),
              tooltip: "Delete Experience",
              onTap: widget.onDelete,
            ),
            const SizedBox(width: 6),

            // Arrow CTA
            Tooltip(
              message: "Manage Experience",
              child: InkWell(
                onTap: widget.onEdit,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: _goldColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: Color(0xFF0C1410),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Icon Action ─────────────────────────────────────────────
  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 15,
            color: color,
          ),
        ),
      ),
    );
  }
}
