import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/config/app_theme.dart';
import '../../../../controllers/gallery_controller.dart';
import 'gallery_category_filter_row.dart';
import 'gallery_search_bar_pill.dart';

class GalleryHeroHeader extends StatelessWidget {
  final TextEditingController searchCtrl;
  final ScrollController categoryScrollCtrl;
  final GalleryController controller;
  final bool isDesktop;
  final bool isTablet;
  final Color goldColor;

  const GalleryHeroHeader({
    super.key,
    required this.searchCtrl,
    required this.categoryScrollCtrl,
    required this.controller,
    required this.isDesktop,
    required this.isTablet,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Text(
          "STUDIO PORTFOLIO",
          style: AppTheme.sansBody(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: goldColor,
            letterSpacing: 3.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Curated Moments of Grandeur & Artistry",
          textAlign: TextAlign.center,
          style: GoogleFonts.italiana(
            fontSize: isDesktop ? 34 : (isTablet ? 28 : 22),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            "Explore our real-world event installations across Gujarat — from opulent weddings and magnificent receptions to whimsical birthdays and bespoke stage decor.",
            textAlign: TextAlign.center,
            style: AppTheme.sansBody(
              fontSize: isDesktop ? 13 : 12,
              color: Colors.white60,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        GallerySearchBarPill(
          searchCtrl: searchCtrl,
          controller: controller,
          goldColor: goldColor,
        ),
        const SizedBox(height: 24),
        GalleryCategoryFilterRow(
          controller: controller,
          categoryScrollCtrl: categoryScrollCtrl,
          isDesktop: isDesktop,
          goldColor: goldColor,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
