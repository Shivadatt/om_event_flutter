import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../domain/entities/experience.dart';
import '../../../controllers/admin_controller.dart';

import 'experience_card_image.dart';

/// Compact, premium Experience catalog card designed to match
/// Option 4 Premium Detailed Style reference design:
/// - 4 cards per row on desktop (~268px height)
/// - Unified 16:9 image container with zero cropping (BoxFit.contain)
/// - FEATURED, ACTIVE/HIDDEN, and Price badges
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
            // ── Top Image Container (Unified 16:9 Frame, Complete Original Image) ──
            ExperienceCardImage(
              imageUrl: item.imageUrl,
              aspectRatio: 16 / 9,
              isFeatured: item.isFeatured,
              isActive: item.isActive,
              price: item.effectivePrice,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),

            // ── Card Body Section ─────────────────────────────────
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
                        SizedBox(
                          height: 34,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
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
                          ),
                        ),
                      ],
                    ),

                    // Rating & Duration row
                    SizedBox(
                      height: 18,
                      child: Row(
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
                color: const Color(0xFF0F1B18),
              ),
              clipBehavior: Clip.antiAlias,
              child: AppImage(
                url: item.imageUrl,
                fit: BoxFit.contain,
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
