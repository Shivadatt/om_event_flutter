import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/services/inquiry_image_resolver.dart';
import 'package:om_event/core/widgets/app_image.dart';
import 'package:om_event/domain/entities/quotation.dart';

/// A premium list card representing an included scenography or prop item.
/// Styled to match Option 2 Modern Card Style in Client Lounge.
class QuotationItemCard extends StatelessWidget {
  final QuotationItem item;

  const QuotationItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // 1. Resolve canonical image dynamically from catalog without N+1 Firestore queries
    String imageUrl = '';
    final match = InquiryImageResolver.findBestCatalogMatch(item.name);
    if (match.imageUrl.isNotEmpty) {
      imageUrl = match.imageUrl;
    } else if (item.theme.isNotEmpty) {
      final themeMatch = InquiryImageResolver.findBestCatalogMatch(item.theme);
      if (themeMatch.imageUrl.isNotEmpty) {
        imageUrl = themeMatch.imageUrl;
      }
    }

    final formattedPrice = (item.totalPrice > 0 ? item.totalPrice : item.unitPrice).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131A15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22D4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Image Thumbnail
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF18221D),
              border: Border.all(color: const Color(0x33D4AF37), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl.isNotEmpty
                ? AppImage(
                    url: imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: _buildItemPlaceholder(),
                  )
                : _buildItemPlaceholder(),
          ),
          const SizedBox(width: 14),

          // Center: Title, Chips & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.italiana(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0x1AD4AF37),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0x33D4AF37)),
                      ),
                      child: Text(
                        "${item.quantity} ${item.quantity == 1 ? 'Item' : 'Items'}",
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFFE5C378),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Attribute Badges / Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.theme.isNotEmpty)
                      _buildChip(item.theme),
                    if (item.color.isNotEmpty)
                      _buildChip("Color: ${item.color}"),
                    _buildChip("Qty: ${item.quantity}"),
                  ],
                ),
                const SizedBox(height: 8),

                // Unit / Total Price
                Text(
                  "₹$formattedPrice",
                  style: GoogleFonts.italiana(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1512),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0x2BD4AF37)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9.5,
          color: Color(0xFFE6C98D),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildItemPlaceholder() {
    return const Center(
      child: Icon(
        Icons.spa_outlined,
        color: Color(0xFFD4AF37),
        size: 26,
      ),
    );
  }
}
