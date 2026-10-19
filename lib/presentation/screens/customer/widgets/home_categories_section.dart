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
  bool shouldRepaint(covariant _CategoriesMeshPainter oldDelegate) => false;
}

class CategoriesSectionBackground extends StatelessWidget {
  final Widget child;
  const CategoriesSectionBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: const _CategoriesMeshPainter(animValue: 0.5),
        child: child,
      ),
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double titleFontSize = isMobile ? 13.0 : (screenWidth < 1200 ? 14.0 : 15.5);
    final double cardPadding = isMobile ? 10.0 : 14.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0.0, _isHovered ? -5.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(14.5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image or solid gradient fallback
                if (hasImage && widget.category.imageUrl.startsWith('assets/'))
                  Image.asset(
                    widget.category.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildCategoryFallback(baseColor),
                  )
                else if (hasImage)
                  Image.network(
                    widget.category.imageUrl,
                    fit: BoxFit.cover,
                    cacheWidth: 600,
                    errorBuilder: (_, __, ___) => _buildCategoryFallback(baseColor),
                  )
                else
                  _buildCategoryFallback(baseColor),

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
                  left: cardPadding,
                  right: cardPadding,
                  bottom: cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.category.name,
                        style: GoogleFonts.italiana(
                          fontSize: titleFontSize,
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

  Widget _buildCategoryFallback(Color baseColor) {
    return Container(
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

  void _onCategoryTap(Category cat) {
    controller.selectCategory(cat.slug);
    if (catalogKey.currentContext != null) {
      Scrollable.ensureVisible(
        catalogKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildGallery(
    BuildContext context,
    List<Category> categories,
    double width,
    double paddingHorizontal,
  ) {
    final isDesktop = width >= 1200;
    final isLaptop = width >= 960 && width < 1200;
    final isTablet = width >= 600 && width < 960;

    final double spacing = isDesktop ? 16.0 : (isLaptop ? 12.0 : (isTablet ? 14.0 : 12.0));

    // On Desktop and Laptop: If categories fit in 1 balanced row (up to 6 items)
    if (width >= 960 && categories.length <= 6) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
        child: Row(
          children: List.generate(categories.length, (index) {
            final cat = categories[index];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: index > 0 ? spacing : 0),
                child: AspectRatio(
                  aspectRatio: 0.88,
                  child: CategoryCard(
                    category: cat,
                    onTap: () => _onCategoryTap(cat),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    }

    // Tablet & Mobile (or if more than 6 categories on Desktop):
    // Smooth horizontal scroll view with partially visible trailing cards
    final double cardWidth = isDesktop
        ? 210.0
        : (isLaptop
            ? 175.0
            : (isTablet ? 160.0 : 132.0));
    final double cardHeight = isDesktop
        ? 245.0
        : (isLaptop
            ? 205.0
            : (isTablet ? 190.0 : 160.0));

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: CategoryCard(
              category: cat,
              onTap: () => _onCategoryTap(cat),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = width >= 1200
        ? 48.0
        : (width >= 800 ? 32.0 : 20.0);
    final double sectionPaddingVertical = width >= 1000 ? 44.0 : 32.0;
    final double titleSize =
        width >= 700 ? (width * 0.038).clamp(32.0, 48.0) : 26.0;

    return CategoriesSectionBackground(
      child: Container(
        key: categoriesKey,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: sectionPaddingVertical,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header (Centered, matching Reference Image)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                  child: Column(
                    children: [
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
                    ],
                  ),
                ),
                SizedBox(height: width >= 1000 ? 28.0 : 20.0),
                Obx(() {
                  if (controller.isLoadingCategories.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.secondaryAccent),
                    );
                  }

                  final categories = controller.rxCategories;
                  if (categories.isEmpty) {
                    return const SizedBox();
                  }

                  return _buildGallery(
                    context,
                    categories,
                    width,
                    paddingHorizontal,
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

