import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/utils/studio_locations_helper.dart';
import 'contact_studio_card.dart';

class ContactStudiosSection extends StatelessWidget {
  final Color goldColor;
  final bool isDesktop;
  final bool isMobile;

  const ContactStudiosSection({
    super.key,
    required this.goldColor,
    required this.isDesktop,
    required this.isMobile,
  });

  static const kadiAddress =
      "Medha (kadi-kalyanpura road), Kadi, Mehsana, Gujarat 382715";
  static const thangadhAddress =
      "Thangadh(Surendranagar), Thangadh, Surendranagar, Gujarat 363530";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: goldColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.storefront_rounded, size: 16, color: goldColor),
            ),
            const SizedBox(width: 8),
            Text(
              "OUR STUDIOS & SHOWROOMS",
              style: GoogleFonts.italiana(
                fontSize: isMobile ? 17 : 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Visit our creative spaces to explore themes, setups and personalised consultations.",
          style: AppTheme.sansBody(
            fontSize: isMobile ? 11 : 11.5,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 14),

        ContactStudioCard(
          title: "Kadi (Medha)",
          address: kadiAddress,
          imageAsset: AppImages.luxuryReception,
          goldColor: goldColor,
          isDesktop: isDesktop,
          isMobile: isMobile,
          onMapTap: () => StudioLocationsHelper.openInGoogleMaps(kadiAddress),
          onDirectionsTap:
              () => StudioLocationsHelper.getDirections(kadiAddress),
        ),
        const SizedBox(height: 14),

        ContactStudioCard(
          title: "Thangadh",
          address: thangadhAddress,
          imageAsset: AppImages.luxuryEveningDecor,
          goldColor: goldColor,
          isDesktop: isDesktop,
          isMobile: isMobile,
          onMapTap:
              () => StudioLocationsHelper.openInGoogleMaps(thangadhAddress),
          onDirectionsTap:
              () => StudioLocationsHelper.getDirections(thangadhAddress),
        ),
      ],
    );
  }
}
