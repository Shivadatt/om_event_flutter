import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/utils/formatters.dart';
import 'package:om_event/domain/entities/experience.dart';
import 'package:om_event/presentation/controllers/cart_controller.dart';
import 'package:om_event/presentation/widgets/item_visual_placeholder.dart';

void showExperienceDetailDialog(BuildContext context, Experience item) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.70),
    builder: (_) => ExperienceDetailDialog(item: item),
  );
}

class ExperienceDetailDialog extends StatefulWidget {
  final Experience item;
  const ExperienceDetailDialog({super.key, required this.item});

  @override
  State<ExperienceDetailDialog> createState() => _ExperienceDetailDialogState();
}

class _ExperienceDetailDialogState extends State<ExperienceDetailDialog> {
  final _notesController = TextEditingController();
  String _selectedColor = '';
  String _selectedTheme = '';

  @override
  void initState() {
    super.initState();
    if (widget.item.colors.isNotEmpty) {
      _selectedColor = widget.item.colors.first;
    }
    if (widget.item.themes.isNotEmpty) {
      _selectedTheme = widget.item.themes.first;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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
    final cartController = Get.find<CartController>();
    final item = widget.item;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = width >= 800;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;

    final dialogWidth = (width * 0.9).clamp(320.0, 940.0);
    final dialogMaxHeight = height * 0.92;

    final hasDiscount =
        item.offerPrice != null && item.price > item.effectivePrice;
    final discountPct =
        hasDiscount
            ? ((1 - item.effectivePrice / item.price) * 100).round()
            : 0;
    final savedAmount = item.price - item.effectivePrice;

    Widget rightPanel = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 36 : 20,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop) ...[
            AspectRatio(
              aspectRatio: 1.4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildImage(
                  item.imageUrl,
                  item.name,
                  item.categorySlug,
                  item.categoryName,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            "${item.categoryName.toUpperCase()} · CUSTOMIZABLE",
            style: AppTheme.sansBody(
              fontSize: 10,
              color: goldColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            style: GoogleFonts.italiana(
              fontSize: isDesktop ? 40 : 28,
              color: inkColor,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            style: AppTheme.sansBody(
              fontSize: 13,
              color: inkColor.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: paperColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lineColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "STARTING PRICE",
                      style: AppTheme.sansBody(
                        fontSize: 9,
                        color: mutedColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: goldColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$discountPct% OFF",
                          style: AppTheme.sansBody(
                            fontSize: 10,
                            color: goldColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      AppFormatters.formatCurrency(item.effectivePrice),
                      style: GoogleFonts.italiana(
                        fontSize: 34,
                        color: inkColor,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 12),
                      Text(
                        AppFormatters.formatCurrency(item.price),
                        style: AppTheme.sansBody(
                          fontSize: 15,
                          color: mutedColor,
                        ).copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                if (hasDiscount) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "You Save ${AppFormatters.formatCurrency(savedAmount)}",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          if (item.colors.isNotEmpty) ...[
            Text(
              "COLOR STORY",
              style: AppTheme.sansBody(
                fontSize: 9,
                color: inkColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            _ModalDropdown(
              value: _selectedColor,
              items: item.colors,
              onChanged: (v) => setState(() => _selectedColor = v),
            ),
            const SizedBox(height: 16),
          ],
          if (item.themes.isNotEmpty) ...[
            Text(
              "DESIGN MOOD",
              style: AppTheme.sansBody(
                fontSize: 9,
                color: inkColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            _ModalDropdown(
              value: _selectedTheme,
              items: item.themes,
              onChanged: (v) => setState(() => _selectedTheme = v),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            "YOUR NOTE",
            style: AppTheme.sansBody(
              fontSize: 9,
              color: inkColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: AppTheme.sansBody(
              fontSize: 13,
              color: inkColor,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: paperColor,
              hintText: "Names, venue details or a specific idea…",
              hintStyle: AppTheme.sansBody(
                fontSize: 12,
                color: mutedColor,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: lineColor,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: lineColor,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: goldColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: const [
              _InclusionChip("Styling & installation"),
              _InclusionChip("Teardown"),
              _InclusionChip("Dedicated coordinator"),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                cartController.addToCart(
                  item,
                  color: _selectedColor,
                  theme: _selectedTheme,
                  notes: _notesController.text,
                );
                Navigator.of(context).pop();
                Get.snackbar(
                  "Added to Canvas",
                  "${item.name} added to your selection.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: paperColor,
                  colorText: inkColor,
                  margin: const EdgeInsets.all(16),
                  boxShadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                );
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: Text(
                "ADD TO MY SELECTION",
                style: AppTheme.sansBody(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ((width - dialogWidth) / 2).clamp(8.0, double.infinity),
        vertical: (height - dialogMaxHeight) / 2,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Material(
          color: const Color(0xFF0D1915),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.secondaryAccent.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: dialogWidth * 0.47,
                          child: _buildImage(
                            item.imageUrl,
                            item.name,
                            item.categorySlug,
                            item.categoryName,
                          ),
                        ),
                        Expanded(child: rightPanel),
                      ],
                    )
                  : rightPanel,
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: paperColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: lineColor,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: inkColor,
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

class _ModalDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String) onChanged;

  const _ModalDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: lineColor,
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          style: AppTheme.sansBody(
            fontSize: 14,
            color: inkColor,
            fontWeight: FontWeight.w500,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: goldColor,
            size: 22,
          ),
          dropdownColor: paperColor,
          borderRadius: BorderRadius.circular(10),
          items:
              items
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _InclusionChip extends StatelessWidget {
  final String label;
  const _InclusionChip(this.label);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: goldColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: goldColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.sansBody(
              fontSize: 11,
              color: inkColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
