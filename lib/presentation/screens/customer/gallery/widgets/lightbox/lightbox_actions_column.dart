import 'package:flutter/material.dart';
import '../../../../../../core/config/app_theme.dart';
import '../../../../../../domain/entities/experience.dart';
import '../../../../../../domain/entities/gallery_item.dart';

class LightboxActionsColumn extends StatelessWidget {
  final GalleryItem item;
  final Experience? matchedExp;
  final void Function(BuildContext, GalleryItem, Experience?) onBookTheme;
  final void Function(BuildContext, GalleryItem, Experience?)
  onViewServiceDetails;
  final Color goldColor;

  const LightboxActionsColumn({
    super.key,
    required this.item,
    required this.matchedExp,
    required this.onBookTheme,
    required this.onViewServiceDetails,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    final tags =
        item.tags.isNotEmpty
            ? item.tags
            : ['proposal', 'premium', 'customizable'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TAGS & THEMES",
          style: AppTheme.sansBody(
            fontSize: 9.5,
            color: goldColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 22,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: tags.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final tag = tags[index];
              final cleanTag = tag.startsWith('#') ? tag : '#$tag';
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF13221E),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white12),
                ),
                child: Center(
                  child: Text(
                    cleanTag,
                    style: AppTheme.sansBody(
                      fontSize: 9.5,
                      color: Colors.white70,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: goldColor,
              foregroundColor: const Color(0xFF091210),
              elevation: 2,
              shadowColor: goldColor.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () => onBookTheme(context, item, matchedExp),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 14,
                  color: Color(0xFF091210),
                ),
                SizedBox(width: 6),
                Text(
                  "BOOK THIS THEME",
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Color(0xFF091210),
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 13,
                  color: Color(0xFF091210),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          height: 32,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: goldColor,
              side: BorderSide(
                color: goldColor.withValues(alpha: 0.65),
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () => onViewServiceDetails(context, item, matchedExp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.north_east_rounded, size: 12),
                const SizedBox(width: 5),
                Text(
                  "VIEW SERVICE DETAILS",
                  style: AppTheme.sansBody(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: goldColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
