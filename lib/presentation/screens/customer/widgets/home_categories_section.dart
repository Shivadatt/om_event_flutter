import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/domain/entities/category.dart';
import 'package:om_event/presentation/controllers/catalog_controller.dart';

class _CategoriesMeshPainter extends CustomPainter {
  final double animValue;
  const _CategoriesMeshPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF152621); // Secondary Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final double radians = animValue * 2 * math.pi;

    // Ambient color leak: Champagne Gold
    final goldOffset = Offset(
      size.width * 0.2 + math.sin(radians) * 80,
      size.height * 0.7 + math.cos(radians) * 60,
    );
    final goldPaint = Paint()
      ..shader = ui.Gradient.radial(
        goldOffset,
        size.width * 0.45,
        [
          AppColors.secondaryAccent.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), goldPaint);

    // Ambient color leak: Deep Emerald
    final emeraldOffset = Offset(
      size.width * 0.8 - math.cos(radians) * 70,
      size.height * 0.3 + math.sin(radians) * 50,
    );
    final emeraldPaint = Paint()
      ..shader = ui.Gradient.radial(
        emeraldOffset,
        size.width * 0.40,
        [
          const Color(0xFF183129).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), emeraldPaint);
  }

  @override
  bool shouldRepaint(covariant _CategoriesMeshPainter oldDelegate) =>
      oldDelegate.animValue != animValue;
}

class CategoriesSectionBackground extends StatefulWidget {
  final Widget child;
  const CategoriesSectionBackground({super.key, required this.child});

  @override
  State<CategoriesSectionBackground> createState() => _CategoriesSectionBackgroundState();
}

class _CategoriesSectionBackgroundState extends State<CategoriesSectionBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CategoriesMeshPainter(animValue: _controller.value),
          child: widget.child,
        );
      },
    );
  }
}

/// Parses a hex color string like "#75c9a6" or "75c9a6" into a [Color].
Color _parseHexColor(String hex) {
  final cleaned = hex.replaceAll('#', '').trim();
  if (cleaned.length == 6) {
    return Color(int.parse('FF$cleaned', radix: 16));
  } else if (cleaned.length == 8) {
    return Color(int.parse(cleaned, radix: 16));
  }
  return const Color(0xFFC8A96E); // Fallback warm gold
}

class CategoryCard extends StatefulWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.category.imageUrl.isNotEmpty;
    final baseColor = _parseHexColor(widget.category.color);

    // Slightly darken/lighten the base color for the radial gradient center
    final lighterColor = Color.lerp(baseColor, Colors.white, 0.22) ?? baseColor;
    final darkerColor = Color.lerp(baseColor, Colors.black, 0.18) ?? baseColor;

    // Text color: choose dark or light based on perceived brightness of baseColor
    final luminance = baseColor.computeLuminance();
    final textColor = luminance > 0.42 ? const Color(0xFF1A2B25) : Colors.white;
    final subtextColor = luminance > 0.42
        ? const Color(0xFF1A2B25).withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.75);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: RadialGradient(
              center: const Alignment(-0.5, -0.5),
              radius: 1.4,
              colors: [lighterColor, darkerColor],
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: _isHovered ? 0.55 : 0.35),
                blurRadius: _isHovered ? 28 : 16,
                offset: Offset(0, _isHovered ? 12 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.8),
            child: Stack(
              children: [
                // Subtle radial glow overlay for depth
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.6, -0.6),
                        radius: 1.0,
                        colors: [
                          Colors.white.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom-right ambient circle decoration
                Positioned(
                  right: -40,
                  bottom: -40,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),

                // Main content: image top, text bottom — Positioned.fill so Spacer works
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 54, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                    children: [
                      // Larger thumbnail image
                      if (hasImage)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.40),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14.5),
                            child: Image.network(
                              widget.category.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.white.withValues(alpha: 0.12),
                                child: Icon(
                                  Icons.celebration_outlined,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Count badge
                      Text(
                        "${widget.category.itemCount} SIGNATURE EXPERIENCE${widget.category.itemCount == 1 ? '' : 'S'}",
                        style: AppTheme.sansBody(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: subtextColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Category name
                      Text(
                        widget.category.name,
                        style: GoogleFonts.italiana(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          height: 1.15,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.category.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          widget.category.description,
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            color: subtextColor,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                    ),
                  ),
                ),

                // Floating Action arrow (top-right)
                Positioned(
                  right: 14,
                  top: 14,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHovered
                          ? textColor.withValues(alpha: 0.90)
                          : Colors.white.withValues(alpha: 0.25),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: _isHovered ? 0.0 : 0.4),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedRotation(
                      turns: _isHovered ? 0.125 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        "↗",
                        style: AppTheme.sansBody(
                          fontSize: 15,
                          color: _isHovered ? baseColor : textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoriesSection extends StatelessWidget {
  final CatalogController controller;
  final GlobalKey categoriesKey;
  final GlobalKey catalogKey;

  const CategoriesSection({
    super.key,
    required this.controller,
    required this.categoriesKey,
    required this.catalogKey,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = width >= 1000 ? 64.0 : 24.0;
    final double sectionPaddingVertical = (width * 0.05).clamp(54.0, 90.0);
    final double titleSize =
        width >= 700 ? (width * 0.048).clamp(42.0, 72.0) : 38.0;
    final bool isWide = width >= 800;

    final headingWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BEGIN WITH A FEELING",
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 3.5,
            color: AppColors.secondaryAccent,
          ),
        ),
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Colors.white, Color(0xFFFFE8A3), Color(0xFFF3D37A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.italiana(
                fontSize: titleSize,
                fontWeight: FontWeight.normal,
                color: Colors.white,
                height: 1.0,
                letterSpacing: 1.2,
              ),
              children: [
                const TextSpan(text: "WHAT ARE WE\n"),
                TextSpan(
                  text: "CELEBRATING?",
                  style: GoogleFonts.italiana(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final descWidget = Container(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Text(
        "Choose a chapter and make it personal. Every collection is a starting point, thoughtfully composed for luxury spaces.",
        style: AppTheme.sansBody(
          fontSize: 14.5,
          color: AppColors.muted,
          height: 1.8,
        ),
      ),
    );

    final headerRow = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              headingWidget,
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: descWidget,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headingWidget,
              const SizedBox(height: 24),
              descWidget,
            ],
          );

    return CategoriesSectionBackground(
      child: Container(
        key: categoriesKey,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: sectionPaddingVertical,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerRow,
                const SizedBox(height: 60),
                Obx(() {
                  if (controller.isLoadingCategories.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.secondaryAccent),
                    );
                  }

                  if (controller.rxCategories.isEmpty) {
                    return const SizedBox();
                  }

                  final gridCount = width >= 1000 ? 3 : (width >= 600 ? 2 : 1);
                  final double cardHeight = width >= 600 ? 220 : 200;
                  final double gridWidth = width - (paddingHorizontal * 2);
                  final double cardWidth =
                      (gridWidth.clamp(0.0, 1200.0) - (gridCount - 1) * 20) /
                      gridCount;
                  final double childAspectRatio = cardWidth / cardHeight;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: controller.rxCategories.length,
                    itemBuilder: (context, index) {
                      final cat = controller.rxCategories[index];
                      return CategoryCard(
                        category: cat,
                        onTap: () {
                          controller.selectCategory(cat.slug);
                          if (catalogKey.currentContext != null) {
                            Scrollable.ensureVisible(
                              catalogKey.currentContext!,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
