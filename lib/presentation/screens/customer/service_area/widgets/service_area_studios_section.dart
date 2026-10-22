import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/constants/app_images.dart';
import '../../../../../../core/utils/studio_locations_helper.dart';

import 'service_area_studio_card.dart';

class ServiceAreaStudiosSection extends StatelessWidget {
  final bool isDesktop;
  final bool isLaptop;
  final bool isTablet;
  final bool isMobile;
  final double availableWidth;
  final Color goldColor;

  const ServiceAreaStudiosSection({
    super.key,
    required this.isDesktop,
    required this.isLaptop,
    required this.isTablet,
    required this.isMobile,
    required this.availableWidth,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    final studios = StudioLocationsHelper.getPublicStudios();
    final kadiStudio =
        studios.isNotEmpty ? studios.first : StudioLocationsHelper.kadiStudio;
    final thangadhStudio =
        studios.length > 1 ? studios[1] : StudioLocationsHelper.thangadhStudio;

    final kadiTitle =
        kadiStudio.name.contains("Studio")
            ? kadiStudio.name
            : "Kadi Showroom & Studio";
    final thangadhTitle =
        thangadhStudio.name.contains("Base") ||
                thangadhStudio.name.contains("Showroom")
            ? thangadhStudio.name
            : "Thangadh Creative Base";

    final card1 = ServiceAreaStudioCard(
      title: kadiTitle,
      address: kadiStudio.fullAddress,
      primaryCoverage: "Mehsana, Gandhinagar & North Ahmedabad",
      imageAsset: AppImages.luxuryReception,
      goldColor: goldColor,
      isMobile: isMobile,
      onArrowTap:
          () => StudioLocationsHelper.openInGoogleMaps(kadiStudio.fullAddress),
    );

    final card2 = ServiceAreaStudioCard(
      title: thangadhTitle,
      address: thangadhStudio.fullAddress,
      primaryCoverage: "Surendranagar, Wadhwan, Chotila & Surroundings",
      imageAsset: AppImages.luxuryEveningDecor,
      goldColor: goldColor,
      isMobile: isMobile,
      onArrowTap:
          () =>
              StudioLocationsHelper.openInGoogleMaps(thangadhStudio.fullAddress),
    );

    final showSideBySide =
        (isDesktop || isLaptop || (isTablet && availableWidth >= 680));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Our Physical Creative Studios",
          style: GoogleFonts.italiana(
            fontSize: isDesktop ? 21 : (isLaptop ? 20 : (isTablet ? 19 : 18)),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 12),
        if (showSideBySide)
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 14),
              Expanded(child: card2),
            ],
          )
        else
          Column(children: [card1, const SizedBox(height: 12), card2]),
      ],
    );
  }
}
