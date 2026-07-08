import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/utils/formatters.dart';
import 'package:om_event/core/widgets/loading_indicator.dart';
import 'package:om_event/domain/entities/experience.dart';
import 'package:om_event/presentation/controllers/cart_controller.dart';
import 'package:om_event/presentation/controllers/catalog_controller.dart';
import 'package:om_event/presentation/widgets/item_visual_placeholder.dart';
import 'package:om_event/presentation/screens/customer/widgets/home_detail_dialog.dart';

part 'parts/catalog_card.dart';
part 'parts/catalog_toolbar.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    final double sectionPaddingVertical = (width * 0.08).clamp(85.0, 155.0);
    final double titleSize =
        width >= 700 ? (width * 0.05).clamp(46.0, 78.0) : 42.0;
    final bool isWide = width >= 800;

    return Container(
      key: catalogKey,
      color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
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
                isDark: isDark,
                width: width,
                titleSize: titleSize,
                isWide: isWide,
              ),
              const SizedBox(height: 34),
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
                          color:
                              isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                        ),
                      ),
                    ),
                  );
                }

                final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);
                final double gridWidth = width - (paddingHorizontal * 2);
                final double cardWidth =
                    (gridWidth.clamp(0.0, 1200.0) - (gridCount - 1) * 18) /
                    gridCount;
                final double childAspectRatio =
                    cardWidth / ((cardWidth / 1.12) + 170);

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
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 32,
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
                            );
                          },
                          onTap: () {
                            showExperienceDetailDialog(context, item);
                          },
                        );
                      },
                    ),
                    if (hasMore) ...[
                      const SizedBox(height: 48),
                      Center(
                        child: OutlinedButton(
                          onPressed: () => controller.loadMore(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : const Color(0xFF17201E),
                            side: BorderSide(
                              color: isDark ? Colors.white30 : Colors.black26,
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 38,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "LOAD MORE",
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
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
    );
  }
}
