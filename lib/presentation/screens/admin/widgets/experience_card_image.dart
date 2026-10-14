import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image.dart';

/// Reusable experience card image widget with a fixed 16:9 aspect ratio,
/// complete non-cropped image display (BoxFit.contain), and luxury emerald & gold styling.
///
/// Ensures all experience cards across the catalog grid maintain identical
/// image-container dimensions regardless of whether the source photo is portrait,
/// landscape, or square.
class ExperienceCardImage extends StatelessWidget {
  final String imageUrl;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final Color backgroundColor;
  final bool isFeatured;
  final bool isActive;
  final bool showBadges;
  final double? price;
  final List<Widget>? customTopLeft;
  final Widget? customTopRight;

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _mintColor = Color(0xFF2DD4BF);
  static const Color _defaultBg = Color(0xFF0F1B18);

  const ExperienceCardImage({
    super.key,
    required this.imageUrl,
    this.aspectRatio = 16 / 9,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(14)),
    this.backgroundColor = _defaultBg,
    this.isFeatured = false,
    this.isActive = true,
    this.showBadges = true,
    this.price,
    this.customTopLeft,
    this.customTopRight,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF13221C),
                Color(0xFF0A130F),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. Complete Original Image (Zero Cropping, BoxFit.contain) ──
              Center(
                child: AppImage(
                  url: imageUrl,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),

              // ── 2. Subtle Top-Only Vignette for Badge Legibility ───────────
              if (showBadges)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 46,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x3D000000), // ~24% black for badge contrast
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // ── 3. Top-Left Badges (FEATURED, ACTIVE / HIDDEN) ────────────
              if (showBadges)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: customTopLeft ??
                        [
                          if (isFeatured) ...[
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
                              color: isActive
                                  ? _mintColor
                                  : Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                              border: isActive
                                  ? null
                                  : Border.all(
                                      color: Colors.white24,
                                      width: 0.8,
                                    ),
                            ),
                            child: Text(
                              isActive ? "ACTIVE" : "HIDDEN",
                              style: GoogleFonts.dmSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: isActive
                                    ? const Color(0xFF0C1410)
                                    : Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                  ),
                ),

              // ── 4. Top-Right Price Badge ──────────────────────────────────
              if (showBadges && (customTopRight != null || price != null))
                Positioned(
                  top: 8,
                  right: 8,
                  child: customTopRight ??
                      Container(
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
                          AppFormatters.formatCurrency(price ?? 0),
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
      ),
    );
  }
}
