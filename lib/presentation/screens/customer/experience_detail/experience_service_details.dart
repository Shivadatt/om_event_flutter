import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/package_option.dart';
import '../../../controllers/cart_controller.dart';
import 'experience_action_buttons.dart';
import 'experience_customization_panel.dart';
import 'experience_package_tier_selector.dart';

class ExperienceServiceDetails extends StatelessWidget {
  final dynamic item;
  final PackageOption? currentPkg;
  final CartController cartController;
  final String selectedColor;
  final String selectedTheme;
  final TextEditingController notesController;
  final ValueChanged<PackageOption> onSelectPackage;
  final ValueChanged<String?> onColorChanged;
  final ValueChanged<String?> onThemeChanged;
  final bool isDesktop;
  final Color goldColor;
  final Color inputBgColor;

  const ExperienceServiceDetails({
    super.key,
    required this.item,
    required this.currentPkg,
    required this.cartController,
    required this.selectedColor,
    required this.selectedTheme,
    required this.notesController,
    required this.onSelectPackage,
    required this.onColorChanged,
    required this.onThemeChanged,
    required this.isDesktop,
    required this.goldColor,
    required this.inputBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${item.categoryName.toUpperCase()} • CUSTOMIZABLE",
          style: AppTheme.sansBody(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: goldColor,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.name as String,
          style: GoogleFonts.italiana(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.star_rounded, size: 16, color: goldColor),
            const SizedBox(width: 4),
            Text(
              "${item.rating} (${item.reviewCount} Verified Reviews)",
              style: AppTheme.sansBody(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          item.description as String,
          style: AppTheme.sansBody(
            fontSize: 12.5,
            color: Colors.white60,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              AppFormatters.formatCurrency(
                (item.effectivePrice as num).toDouble(),
              ),
              style: AppTheme.sansBody(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "starting price",
              style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ExperiencePackageTierSelector(
          item: item,
          currentPkg: currentPkg,
          onSelectPackage: onSelectPackage,
          goldColor: goldColor,
        ),
        const SizedBox(height: 14),
        ExperienceCustomizationPanel(
          item: item,
          selectedColor: selectedColor,
          selectedTheme: selectedTheme,
          notesController: notesController,
          onColorChanged: onColorChanged,
          onThemeChanged: onThemeChanged,
          isDesktop: isDesktop,
          goldColor: goldColor,
          inputBgColor: inputBgColor,
        ),
        const SizedBox(height: 14),
        ExperienceActionButtons(
          item: item,
          currentPkg: currentPkg,
          selectedColor: selectedColor,
          selectedTheme: selectedTheme,
          notes: notesController.text,
          cartController: cartController,
          isDesktop: isDesktop,
          goldColor: goldColor,
        ),
      ],
    );
  }
}
