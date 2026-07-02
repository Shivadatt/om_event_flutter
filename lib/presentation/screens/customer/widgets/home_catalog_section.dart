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

class ExperienceCard extends StatefulWidget {
  final Experience item;
  final VoidCallback onQuickAdd;
  final VoidCallback onTap;

  const ExperienceCard({
    super.key,
    required this.item,
    required this.onQuickAdd,
    required this.onTap,
  });

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  bool _isHovered = false;

  Widget _buildImage(
    String url,
    String title,
    String categorySlug,
    String categoryName,
  ) {
    if (url.isEmpty) {
      return ItemVisualPlaceholder(
        title: title,
        categorySlug: categorySlug,
        categoryName: categoryName,
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => ItemVisualPlaceholder(
              title: title,
              categorySlug: categorySlug,
              categoryName: categoryName,
            ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => ItemVisualPlaceholder(
            title: title,
            categorySlug: categorySlug,
            categoryName: categoryName,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedScale(
                        scale: _isHovered ? 1.04 : 1.0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        child: _buildImage(
                          widget.item.imageUrl,
                          widget.item.name,
                          widget.item.categorySlug,
                          widget.item.categoryName,
                        ),
                      ),
                    ),
                    if (widget.item.isFeatured)
                      Positioned(
                        left: 14,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          color: const Color(0xEBFAF5EE),
                          child: Text(
                            "MOST LOVED",
                            style: AppTheme.sansBody(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF28322E),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: widget.onQuickAdd,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _isHovered
                                      ? const Color(0xFFC79B61)
                                      : const Color(0xE6192320),
                            ),
                            alignment: Alignment.center,
                            child: AnimatedRotation(
                              turns: _isHovered ? 0.25 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: const Text(
                                "+",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.item.categoryName.toUpperCase()} · ${widget.item.durationHours.toStringAsFixed(0)} HRS",
                    style: AppTheme.sansBody(
                      fontSize: 9,
                      color: const Color(0xFFAA7C4B),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.item.name,
                    style: GoogleFonts.italiana(
                      fontSize: 25,
                      fontWeight: FontWeight.normal,
                      color: isDark ? Colors.white : const Color(0xFF17201E),
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: Text(
                      widget.item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: 12,
                        color:
                            isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            AppFormatters.formatCurrency(
                              widget.item.effectivePrice,
                            ),
                            style: AppTheme.sansBody(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark
                                      ? Colors.white
                                      : const Color(0xFF17201E),
                            ),
                          ),
                          if (widget.item.offerPrice != null &&
                              widget.item.offerPrice! < widget.item.price) ...[
                            const SizedBox(width: 6),
                            Text(
                              AppFormatters.formatCurrency(widget.item.price),
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    isDark
                                        ? AppTheme.darkMuted
                                        : AppTheme.lightMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          const SizedBox(width: 6),
                          Text(
                            "starting price",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? AppTheme.darkMuted
                                      : AppTheme.lightMuted,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Color(0xFFC79B61),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${widget.item.rating} (${widget.item.reviewCount})",
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            color:
                isActive
                    ? (isDark ? Colors.white : const Color(0xFF1E2B27))
                    : Colors.transparent,
            border: Border.all(
              color:
                  isActive
                      ? Colors.transparent
                      : (isDark ? Colors.white24 : Colors.black12),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: AppTheme.sansBody(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color:
                  isActive
                      ? (isDark ? const Color(0xFF17201E) : Colors.white)
                      : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    final double sectionPaddingVertical = (width * 0.08).clamp(85.0, 155.0);
    final double titleSize =
        width >= 700 ? (width * 0.05).clamp(46.0, 78.0) : 42.0;
    final bool isWide = width >= 800;

    final headingWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CURATED EXPERIENCES",
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
              const TextSpan(text: "Designed to leave\n"),
              const TextSpan(text: "a "),
              TextSpan(
                text: "beautiful echo.",
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
        "Explore signature concepts, see an honest starting price, then tune every color, material and detail.",
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

    final searchWidget = Container(
      height: 46,
      width: isWide ? 280 : double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 18,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (val) => controller.updateSearchQuery(val),
              style: AppTheme.sansBody(
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF17201E),
              ),
              decoration: const InputDecoration(
                hintText: "Search a mood, theme or event…",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );

    final sortWidget = Container(
      height: 46,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.sortBy.value,
            dropdownColor: isDark ? const Color(0xFF1B2320) : Colors.white,
            icon: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'popular', child: Text("Most loved")),
              DropdownMenuItem(value: 'latest', child: Text("Latest")),
              DropdownMenuItem(
                value: 'price_low',
                child: Text("Price: low to high"),
              ),
              DropdownMenuItem(
                value: 'price_high',
                child: Text("Price: high to low"),
              ),
            ],
            onChanged: (val) {
              if (val != null) controller.updateSort(val);
            },
            style: AppTheme.sansBody(
              fontSize: 12,
              color: isDark ? Colors.white : const Color(0xFF17201E),
            ),
          ),
        ),
      ),
    );

    final chipsWidget = SizedBox(
      height: 46,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Obx(() {
              final isActive = controller.selectedCategorySlug.value.isEmpty;
              return _buildChip(
                label: "All",
                isActive: isActive,
                onTap: () => controller.selectCategory(''),
                isDark: isDark,
              );
            }),
            const SizedBox(width: 7),
            Obx(
              () => Row(
                children:
                    controller.rxCategories.map((cat) {
                      final isActive =
                          controller.selectedCategorySlug.value == cat.slug;
                      return Padding(
                        padding: const EdgeInsets.only(right: 7.0),
                        child: _buildChip(
                          label: cat.name.replaceFirst(" Celebrations", ""),
                          isActive: isActive,
                          onTap: () => controller.selectCategory(cat.slug),
                          isDark: isDark,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );

    final toolbar =
        isWide
            ? Row(
              children: [
                searchWidget,
                const SizedBox(width: 14),
                Expanded(child: chipsWidget),
                const SizedBox(width: 14),
                sortWidget,
              ],
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchWidget,
                const SizedBox(height: 14),
                chipsWidget,
                const SizedBox(height: 14),
                Align(alignment: Alignment.centerLeft, child: sortWidget),
              ],
            );

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
              headerRow,
              const SizedBox(height: 62),
              toolbar,
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

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCount,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 32,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: controller.rxExperiences.length,
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
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
