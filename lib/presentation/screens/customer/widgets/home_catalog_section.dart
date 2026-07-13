import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/utils/formatters.dart';
import 'package:om_event/core/widgets/custom_button.dart';
import 'package:om_event/core/widgets/loading_indicator.dart';
import 'package:om_event/domain/entities/experience.dart';
import 'package:om_event/presentation/controllers/cart_controller.dart';
import 'package:om_event/presentation/controllers/catalog_controller.dart';
import 'package:om_event/presentation/widgets/item_visual_placeholder.dart';
import 'package:om_event/presentation/screens/customer/widgets/home_detail_dialog.dart';

part 'parts/catalog_card.dart';
part 'parts/catalog_toolbar.dart';

class _CatalogMeshPainter extends CustomPainter {
  final double animValue;
  const _CatalogMeshPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0F1B18); // Primary Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final double radians = animValue * 2 * math.pi;

    // Ambient color leak: Champagne Gold
    final goldOffset = Offset(
      size.width * 0.7 + math.sin(radians) * 90,
      size.height * 0.6 + math.cos(radians) * 70,
    );
    final goldPaint = Paint()
      ..shader = ui.Gradient.radial(
        goldOffset,
        size.width * 0.40,
        [
          AppColors.secondaryAccent.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), goldPaint);

    // Ambient color leak: Deep Emerald
    final emeraldOffset = Offset(
      size.width * 0.2 + math.cos(radians) * 80,
      size.height * 0.3 + math.sin(radians) * 60,
    );
    final emeraldPaint = Paint()
      ..shader = ui.Gradient.radial(
        emeraldOffset,
        size.width * 0.45,
        [
          const Color(0xFF183129).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), emeraldPaint);
  }

  @override
  bool shouldRepaint(covariant _CatalogMeshPainter oldDelegate) =>
      oldDelegate.animValue != animValue;
}

class CatalogSectionBackground extends StatefulWidget {
  final Widget child;
  const CatalogSectionBackground({super.key, required this.child});

  @override
  State<CatalogSectionBackground> createState() => _CatalogSectionBackgroundState();
}

class _CatalogSectionBackgroundState extends State<CatalogSectionBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
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
          painter: _CatalogMeshPainter(animValue: _controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class ExperiencesCatalogSection extends StatelessWidget {
  final CatalogController controller;
  final CartController cartController;
  final GlobalKey catalogKey;
  final bool isDesktop;
  final bool isTablet;

  const ExperiencesCatalogSection({
    super.key,
    required this.controller,
    required this.cartController,
    required this.catalogKey,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    final double sectionPaddingVertical = (width * 0.05).clamp(54.0, 90.0);
    final double titleSize =
        width >= 700 ? (width * 0.048).clamp(42.0, 72.0) : 38.0;
    final bool isWide = width >= 800;

    return CatalogSectionBackground(
      child: Container(
        key: catalogKey,
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
                _buildToolbar(
                  context: context,
                  isDark: true,
                  width: width,
                  titleSize: titleSize,
                  isWide: isWide,
                ),
                const SizedBox(height: 48),
                Obx(() {
                  if (controller.isLoadingExperiences.value) {
                    return const Center(
                      child: LoadingIndicator(
                        message: "Refreshing experiences canvas...",
                      ),
                    );
                  }

                  if (controller.rxExperiences.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Text(
                          "No experiences match that search. Try a broader mood.",
                          style: AppTheme.sansBody(
                            fontSize: 14,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    );
                  }

                  final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);
                  final double gridWidth = width - (paddingHorizontal * 2);
                  final double cardWidth =
                      (gridWidth.clamp(0.0, 1200.0) - (gridCount - 1) * 20) /
                      gridCount;
                  
                  // Aspect ratio adjusted to fit glassmorphic details
                  final double childAspectRatio = cardWidth / (cardWidth * 0.8 + 190);

                  final totalItems = controller.rxExperiences.length;
                  final visibleCount = controller.rxVisibleCount.value.clamp(0, totalItems);
                  final hasMore = visibleCount < totalItems;

                  return Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 28,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: visibleCount,
                        itemBuilder: (context, index) {
                          final item = controller.rxExperiences[index];
                          return ExperienceCard(
                            item: item,
                            onQuickAdd: () {
                              cartController.addToCart(item);
                              Get.snackbar(
                                "Added to Canvas",
                                "${item.name} added.",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF1B2D27).withValues(alpha: 0.85), // Card Background
                                colorText: Colors.white,
                                borderColor: AppColors.secondaryAccent.withValues(alpha: 0.3),
                                borderWidth: 1.2,
                                margin: const EdgeInsets.all(16),
                              );
                            },
                            onTap: () {
                              showExperienceDetailDialog(context, item);
                            },
                          );
                        },
                      ),
                      if (hasMore) ...[
                        const SizedBox(height: 56),
                        Center(
                          child: CustomButton(
                            text: "Load More Designs",
                            isPrimary: false,
                            onPressed: () => controller.loadMore(),
                          ),
                        ),
                      ],
                    ],
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
