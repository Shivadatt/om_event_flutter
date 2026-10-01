import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../domain/entities/experience.dart';
import '../../../controllers/admin_controller.dart';

/// Compact, modern Experience catalog card designed to match the
/// Option 2 Modern Card Style reference design:
/// - 4 cards per row on desktop
/// - Aspect-controlled top image (~160px) with Active/Featured and Price badge overlays
/// - Category eyebrow, bold title, prominent gold price, rating & setup duration
/// - Compact action row: Star (Featured toggle), Eye (Active toggle), Edit, Delete,
///   and signature circular gold arrow CTA button
/// - Supports both Grid view (card) and List view (horizontal row)
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
  static const Color _borderColor = Color(0xFF1D2B23);

  @override
  Widget build(BuildContext context) {
    if (widget.isListView) {
      return _buildListRow();
    }
    return _buildGridCard();
  }

  // ── 1. Standard 4-Column Modern Grid Card ──────────────────────────
  Widget _buildGridCard() {
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? Matrix4.translationValues(0, -4, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? _goldColor.withValues(alpha: 0.5)
                : _borderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.5 : 0.3),
              blurRadius: _isHovered ? 20 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
            if (_isHovered)
              BoxShadow(
                color: _goldColor.withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 1,
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Image Container (Height ~158px) ─────────────────
            SizedBox(
              height: 158,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    url: item.imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  // Subtle top & bottom shadow gradient for badge readability
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.35),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),

                  // Top-Left Badges (FEATURED, ACTIVE / HIDDEN)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.isFeatured) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: _goldColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "FEATURED",
                              style: GoogleFonts.dmSans(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0C1410),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: item.isActive
                                ? _mintColor
                                : Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(12),
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
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: item.isActive
                                  ? const Color(0xFF0C1410)
                                  : Colors.white70,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top-Right Price Badge Overlay
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        AppFormatters.formatCurrency(item.effectivePrice),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _goldColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Card Body Section ───────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
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
                            letterSpacing: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AppFormatters.formatCurrency(item.effectivePrice),
                          style: GoogleFonts.dmSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: _goldColor,
                          ),
                        ),
                      ],
                    ),

                    // Rating & Duration row
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: _goldColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${item.rating.toStringAsFixed(1)} (${item.reviewCount})",
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 11,
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
                    ),

                    const Divider(
                      color: Color(0xFF19261F),
                      height: 1,
                      thickness: 1,
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

                        // Option 2 Signature Circular Gold Arrow CTA Button
                        InkWell(
                          onTap: widget.onEdit,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: _goldColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
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

  // ── 2. Horizontal List View Row ────────────────────────────────────
  Widget _buildListRow() {
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? _goldColor.withValues(alpha: 0.5)
                : _borderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Square Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 90,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(url: item.imageUrl, fit: BoxFit.cover),
                    if (item.isFeatured)
                      Positioned(
                        top: 5,
                        left: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _goldColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "★",
                            style: TextStyle(
                              fontSize: 8,
                              color: Color(0xFF0C1410),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Middle Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        item.categoryName.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: _goldColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.isActive
                              ? _mintColor.withValues(alpha: 0.2)
                              : Colors.white12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.isActive ? "ACTIVE" : "HIDDEN",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: item.isActive ? _mintColor : Colors.white60,
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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        AppFormatters.formatCurrency(item.effectivePrice),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _goldColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: _goldColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "${item.rating.toStringAsFixed(1)} (${item.reviewCount})",
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionIcon(
                  icon: item.isFeatured
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: item.isFeatured ? _goldColor : Colors.white38,
                  tooltip: item.isFeatured ? "Featured" : "Mark Featured",
                  onTap: () => widget.controller.toggleExperienceFeatured(
                    item,
                    !item.isFeatured,
                  ),
                ),
                const SizedBox(width: 6),
                _buildActionIcon(
                  icon: item.isActive
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: item.isActive ? _mintColor : Colors.white38,
                  tooltip: item.isActive ? "Active" : "Hidden",
                  onTap: () => widget.controller.toggleExperienceActive(
                    item,
                    !item.isActive,
                  ),
                ),
                const SizedBox(width: 6),
                _buildActionIcon(
                  icon: Icons.edit_outlined,
                  color: Colors.white70,
                  tooltip: "Edit",
                  onTap: widget.onEdit,
                ),
                const SizedBox(width: 6),
                _buildActionIcon(
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFEF4444),
                  tooltip: "Delete",
                  onTap: widget.onDelete,
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: widget.onEdit,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: _goldColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
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
    );
  }

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
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
