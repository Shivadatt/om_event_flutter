import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/config/app_theme.dart';

class GalleryCardCategoryBadge extends StatelessWidget {
  final String categoryName;
  final Color goldColor;

  const GalleryCardCategoryBadge({
    super.key,
    required this.categoryName,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryName.isEmpty) return const SizedBox.shrink();
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        decoration: BoxDecoration(
          color: const Color(0xD908110E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: goldColor.withValues(alpha: 0.45),
            width: 0.9,
          ),
        ),
        child: Text(
          categoryName.toUpperCase(),
          style: AppTheme.sansBody(
            fontSize: 9.0,
            fontWeight: FontWeight.bold,
            color: goldColor,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class GalleryCardBottomOverlay extends StatelessWidget {
  final String title;
  final String description;
  final Color goldColor;

  const GalleryCardBottomOverlay({
    super.key,
    required this.title,
    required this.description,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.italiana(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sansBody(
                      fontSize: 10.5,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goldColor,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33D4AF37),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: Color(0xFF08110E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
