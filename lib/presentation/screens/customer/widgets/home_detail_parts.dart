import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/utils/formatters.dart';
import 'package:om_event/domain/entities/experience.dart';
import 'package:om_event/presentation/widgets/item_visual_placeholder.dart';

class ModalDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const ModalDropdown({
    super.key,
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
        border: Border.all(color: lineColor, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          style: AppTheme.sansBody(fontSize: 14, color: inkColor, fontWeight: FontWeight.w500),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: goldColor, size: 22),
          dropdownColor: paperColor,
          borderRadius: BorderRadius.circular(10),
          items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class InclusionChip extends StatelessWidget {
  final String label;
  const InclusionChip({super.key, required this.label});

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
        border: Border.all(color: goldColor.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 14, color: goldColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.sansBody(fontSize: 11, color: inkColor.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class ExperienceDetailImage extends StatelessWidget {
  final String url;
  final String title;
  final String categorySlug;
  final String categoryName;

  const ExperienceDetailImage({
    super.key,
    required this.url,
    required this.title,
    required this.categorySlug,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return ItemVisualPlaceholder(title: title, categorySlug: categorySlug, categoryName: categoryName);
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ItemVisualPlaceholder(title: title, categorySlug: categorySlug, categoryName: categoryName),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ItemVisualPlaceholder(title: title, categorySlug: categorySlug, categoryName: categoryName),
    );
  }
}

class ExperiencePriceCard extends StatelessWidget {
  final Experience item;
  final bool hasDiscount;
  final int discountPct;
  final double savedAmount;

  const ExperiencePriceCard({
    super.key,
    required this.item,
    required this.hasDiscount,
    required this.discountPct,
    required this.savedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final goldColor = isDark ? AppColors.darkGold : AppColors.lightGold;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lineColor, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("STARTING PRICE", style: AppTheme.sansBody(fontSize: 9, color: mutedColor, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
              if (hasDiscount) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: goldColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text("% OFF", style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(AppFormatters.formatCurrency(item.effectivePrice), style: GoogleFonts.italiana(fontSize: 34, color: inkColor, fontWeight: FontWeight.w600, height: 1)),
              if (hasDiscount) ...[
                const SizedBox(width: 12),
                Text(AppFormatters.formatCurrency(item.price), style: AppTheme.sansBody(fontSize: 15, color: mutedColor).copyWith(decoration: TextDecoration.lineThrough)),
              ],
            ],
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Text("You Save ", style: AppTheme.sansBody(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
