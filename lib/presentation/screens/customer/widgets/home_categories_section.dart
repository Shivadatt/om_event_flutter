import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/domain/entities/category.dart';
import 'package:om_event/presentation/controllers/catalog_controller.dart';
import 'package:om_event/presentation/controllers/customer_auth_controller.dart';
import 'package:om_event/presentation/screens/customer/auth/widgets/customer_auth_box.dart';

class ConcentricCirclesPainter extends CustomPainter {
  const ConcentricCirclesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint1 =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    final paint2 =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.025)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 24;

    final paint3 =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.018)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 50;

    canvas.drawCircle(center, 120.0 + 25.0, paint3);
    canvas.drawCircle(center, 120.0 + 12.0, paint2);
    canvas.drawCircle(center, 120.0, paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    Color catColor;
    try {
      catColor = Color(
        int.parse(widget.category.color.replaceFirst('#', '0xFF')),
      );
    } catch (_) {
      catColor = const Color(0xFFC79B61);
    }
    const cardBackground = Color(0xFF1C2724);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform:
              Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow:
                _isHovered
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                    : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [catColor, cardBackground],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -60,
                  top: -70,
                  child: const CustomPaint(
                    size: Size(240, 240),
                    painter: ConcentricCirclesPainter(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.category.icon,
                        style: const TextStyle(fontSize: 34),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.category.itemCount} SIGNATURE EXPERIENCES",
                            style: AppTheme.sansBody(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.65),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.category.name,
                            style: GoogleFonts.italiana(
                              fontSize: 30,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.category.description,
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                              height: 1.6,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHovered ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color:
                            _isHovered
                                ? Colors.transparent
                                : Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedRotation(
                      turns: _isHovered ? 0.125 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        "↗",
                        style: AppTheme.sansBody(
                          fontSize: 18,
                          color:
                              _isHovered
                                  ? const Color(0xFF17201E)
                                  : Colors.white,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = width >= 1000 ? 64.0 : 24.0;

    final double sectionPaddingVertical = (width * 0.08).clamp(85.0, 155.0);
    final double titleSize =
        width >= 700 ? (width * 0.05).clamp(46.0, 78.0) : 42.0;
    final bool isWide = width >= 800;

    final headingWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BEGIN WITH A FEELING",
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: const Color(0xFFAA7C4B),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.italiana(
              fontSize: titleSize,
              fontWeight: FontWeight.normal,
              color: isDark ? Colors.white : const Color(0xFF17201E),
              height: 0.98,
            ),
            children: [
              const TextSpan(text: "What are we\n"),
              TextSpan(
                text: "celebrating?",
                style: GoogleFonts.italiana(
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFAA7C4B),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final descWidget = Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Text(
        "Choose a chapter and make it personal. Every collection is a starting point, never a fixed package.",
        style: AppTheme.sansBody(
          fontSize: 14,
          color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
          height: 1.8,
        ),
      ),
    );

    final headerRow =
        isWide
            ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                headingWidget,
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: descWidget,
                ),
              ],
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [headingWidget, const SizedBox(height: 22), descWidget],
            );

    return Container(
      key: categoriesKey,
      width: double.infinity,
      color: isDark ? const Color(0xFF0B100E) : const Color(0xFFFAF8F5),
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
              const SizedBox(height: 62),
              Obx(() {
                if (controller.isLoadingCategories.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFAA7C4B)),
                  );
                }

                if (controller.rxCategories.isEmpty) {
                  return const SizedBox();
                }

                final gridCount = width >= 1000 ? 3 : (width >= 600 ? 2 : 1);
                final double cardHeight = width >= 600 ? 275 : 230;
                final double gridWidth = width - (paddingHorizontal * 2);
                final double cardWidth =
                    (gridWidth.clamp(0.0, 1200.0) - (gridCount - 1) * 16) /
                    gridCount;
                final double childAspectRatio = cardWidth / cardHeight;

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
                        final authCtrl = Get.find<CustomerAuthController>();
                        if (!authCtrl.rxIsLoggedIn.value) {
                          Get.dialog(
                            const Dialog(
                              backgroundColor: Colors.transparent,
                              child: CustomerAuthBox(),
                            ),
                          );
                          return;
                        }
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
    );
  }
}
