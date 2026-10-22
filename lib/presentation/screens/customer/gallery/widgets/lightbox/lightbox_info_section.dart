import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/config/app_theme.dart';
import '../../../../../../domain/entities/experience.dart';
import '../../../../../../domain/entities/gallery_item.dart';
import 'lightbox_actions_column.dart';
import 'lightbox_metadata_column.dart';

class LightboxInfoSection extends StatelessWidget {
  final GalleryItem item;
  final Experience? matchedExp;
  final bool isDesktop;
  final bool isTablet;
  final void Function(BuildContext, GalleryItem, Experience?) onBookTheme;
  final void Function(BuildContext, GalleryItem, Experience?)
  onViewServiceDetails;
  final Color goldColor;

  const LightboxInfoSection({
    super.key,
    required this.item,
    required this.matchedExp,
    required this.isDesktop,
    required this.isTablet,
    required this.onBookTheme,
    required this.onViewServiceDetails,
    required this.goldColor,
  });

  Widget _buildTitleAndDescription() {
    final categoryText =
        item.categoryName.isNotEmpty
            ? item.categoryName.toUpperCase()
            : 'CURATED THEME';

    final descriptionText =
        item.description.isNotEmpty
            ? item.description
            : "Private candle aisle, illuminated letters, florals and a sparkling reveal moment.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
          decoration: BoxDecoration(
            color: goldColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: goldColor.withValues(alpha: 0.4),
              width: 0.9,
            ),
          ),
          child: Text(
            categoryText,
            style: AppTheme.sansBody(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: goldColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 28,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.italiana(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.4,
                height: 1.15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 36,
          child: Text(
            descriptionText,
            style: AppTheme.sansBody(
              fontSize: 11.5,
              color: Colors.white70,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final actionsColumn = LightboxActionsColumn(
      item: item,
      matchedExp: matchedExp,
      onBookTheme: onBookTheme,
      onViewServiceDetails: onViewServiceDetails,
      goldColor: goldColor,
    );
    final metadataCol = LightboxMetadataColumn(
      item: item,
      matchedExp: matchedExp,
      goldColor: goldColor,
    );

    if (isDesktop) {
      return Container(
        height: 156,
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 38, child: _buildTitleAndDescription()),
            const SizedBox(width: 20),
            Expanded(flex: 31, child: metadataCol),
            const SizedBox(width: 20),
            Expanded(flex: 31, child: actionsColumn),
          ],
        ),
      );
    } else if (isTablet) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleAndDescription(),
                  const SizedBox(height: 12),
                  metadataCol,
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(flex: 45, child: actionsColumn),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleAndDescription(),
            const SizedBox(height: 12),
            metadataCol,
            const SizedBox(height: 12),
            actionsColumn,
          ],
        ),
      );
    }
  }
}
