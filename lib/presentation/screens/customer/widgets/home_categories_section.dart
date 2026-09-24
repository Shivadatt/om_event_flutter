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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered
                  ? AppColors.secondaryAccent.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.12),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.secondaryAccent.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.4),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image or solid gradient fallback
                if (hasImage)
                  Image.network(
                    widget.category.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            baseColor.withValues(alpha: 0.5),
                            const Color(0xFF152621),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.celebration_outlined,
                          color: AppColors.secondaryAccent,
                          size: 36,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          baseColor.withValues(alpha: 0.5),
                          const Color(0xFF152621),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.celebration_outlined,
                        color: AppColors.secondaryAccent,
                        size: 36,
                      ),
                    ),
                  ),

                // Scrim / gradient overlay for text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.35, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),

                // Ambient glow on hover
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.0,
                          colors: [
                            AppColors.secondaryAccent.withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                // Category title at bottom left
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.category.name,
                        style: GoogleFonts.italiana(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.18,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
    final paddingHorizontal = width >= 1200
        ? 48.0
        : (width >= 800 ? 32.0 : 20.0);
    final double sectionPaddingVertical = width >= 1000 ? 44.0 : 32.0;
    final double titleSize =
        width >= 700 ? (width * 0.04).clamp(32.0, 48.0) : 28.0;

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
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header (Centered, matching Image 1)
                Text(
                  "BEGIN WITH A FEELING",
                  style: AppTheme.sansBody(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.5,
                    color: AppColors.secondaryAccent,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.italiana(
                      fontSize: titleSize,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    children: [
                      const TextSpan(text: "WHAT ARE WE "),
                      TextSpan(
                        text: "CELEBRATING?",
                        style: GoogleFonts.italiana(
                          color: AppColors.secondaryAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.isLoadingCategories.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.secondaryAccent),
                    );
                  }

                  if (controller.rxCategories.isEmpty) {
                    return const SizedBox();
                  }

                  // Responsive column count: 6 on large desktop, 4 on medium, 3 on tablet, 2 on mobile
                  final gridCount = width >= 1150
                      ? 6
                      : (width >= 850
                          ? 4
                          : (width >= 600
                              ? 3
                              : 2));

                  final childAspectRatio = width >= 1150 ? 0.88 : (width >= 600 ? 0.90 : 0.86);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
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
