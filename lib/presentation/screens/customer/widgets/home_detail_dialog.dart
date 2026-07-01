import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_theme.dart';
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
  State<ExperienceDetailDialog> createState() =>
      _ExperienceDetailDialogState();
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
        errorBuilder: (_, __, ___) => ItemVisualPlaceholder(
          title: title,
          categorySlug: categorySlug,
          categoryName: categoryName,
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ItemVisualPlaceholder(
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

    final dialogWidth = (width * 0.9).clamp(320.0, 940.0);
    final dialogMaxHeight = height * 0.92;

    final hasDiscount =
        item.offerPrice != null && item.price > item.effectivePrice;
    final discountPct =
        hasDiscount ? ((1 - item.effectivePrice / item.price) * 100).round() : 0;
    final savedAmount = item.price - item.effectivePrice;

    Widget rightPanel = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 20,
        vertical: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${item.categoryName.toUpperCase()} · CUSTOMIZABLE",
            style: AppTheme.sansBody(
              fontSize: 9,
              color: const Color(0xFFAA7C4B),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            item.name,
            style: GoogleFonts.italiana(
              fontSize: isDesktop ? 42 : 30,
              color: const Color(0xFF17201E),
              height: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            item.description,
            style: AppTheme.sansBody(
              fontSize: 13,
              color: const Color(0xFF6D746F),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          if (hasDiscount) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppFormatters.formatCurrency(item.price),
                  style: AppTheme.sansBody(
                    fontSize: 14,
                    color: const Color(0xFF6D746F),
                  ).copyWith(decoration: TextDecoration.lineThrough),
                ),
                const SizedBox(width: 10),
                Text(
                  "$discountPct% OFF",
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    color: const Color(0xFFAA7C4B),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Text(
            AppFormatters.formatCurrency(item.effectivePrice),
            style: GoogleFonts.italiana(
              fontSize: 34,
              color: const Color(0xFF17201E),
              height: 1,
            ),
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 4),
            Text(
              "You Save ${AppFormatters.formatCurrency(savedAmount)}",
              style: AppTheme.sansBody(
                fontSize: 12,
                color: const Color(0xFF3A7A5A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            "Starting Price",
            style: AppTheme.sansBody(
              fontSize: 11,
              color: const Color(0xFF17201E),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          if (item.colors.isNotEmpty) ...[
            Text(
              "COLOR STORY",
              style: AppTheme.sansBody(
                fontSize: 9,
                color: const Color(0xFF17201E),
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
                color: const Color(0xFF17201E),
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
              color: const Color(0xFF17201E),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF17201E).withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              style: AppTheme.sansBody(
                fontSize: 13,
                color: const Color(0xFF17201E),
              ),
              decoration: InputDecoration(
                hintText: "Names, venue details or a specific idea…",
                hintStyle: AppTheme.sansBody(
                  fontSize: 12,
                  color: const Color(0xFF6D746F),
                ),
                contentPadding: const EdgeInsets.all(12),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: const [
              _InclusionChip("Styling & installation"),
              _InclusionChip("Teardown"),
              _InclusionChip("Dedicated coordinator"),
            ],
          ),
          const SizedBox(height: 16),
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
                );
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: Text(
                "ADD TO MY SELECTION",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAA7C4B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
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
          color: const Color(0xFFFBF9F4),
          borderRadius: BorderRadius.zero,
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
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF9F4),
                      border: Border.all(
                        color: const Color(0xFF17201E).withValues(alpha: 0.2),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF17201E),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF17201E).withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          style: AppTheme.sansBody(
            fontSize: 13,
            color: const Color(0xFF17201E),
          ),
          iconEnabledColor: const Color(0xFF17201E),
          items: items
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, size: 12, color: Color(0xFFAA7C4B)),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 11,
            color: const Color(0xFF6D746F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
