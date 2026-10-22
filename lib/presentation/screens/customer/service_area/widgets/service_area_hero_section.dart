import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/config/app_theme.dart';
import 'gujarat_coverage_map.dart';
import 'service_area_features.dart';
import 'venue_search_card.dart';

class ServiceAreaHeroSection extends StatelessWidget {
  final TextEditingController pincodeCtrl;
  final Map<String, dynamic>? checkResult;
  final VoidCallback onCheck;
  final VoidCallback onClearResult;
  final ValueChanged<String> onCitySelected;
  final bool isDesktop;
  final bool isLaptop;
  final bool isTablet;
  final bool isMobile;
  final Color goldColor;

  const ServiceAreaHeroSection({
    super.key,
    required this.pincodeCtrl,
    required this.checkResult,
    required this.onCheck,
    required this.onClearResult,
    required this.onCitySelected,
    required this.isDesktop,
    required this.isLaptop,
    required this.isTablet,
    required this.isMobile,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    final leftContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Service Locations\n",
                style: GoogleFonts.italiana(
                  fontSize:
                      isDesktop
                          ? 32
                          : (isLaptop ? 30 : (isTablet ? 28 : 24)),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: 0.3,
                ),
              ),
              TextSpan(
                text: "& Coverage",
                style: GoogleFonts.italiana(
                  fontSize:
                      isDesktop
                          ? 32
                          : (isLaptop ? 30 : (isTablet ? 28 : 24)),
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                  height: 1.15,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Operating dual creative studios in Kadi and Thangadh, OM Events & Decorators orchestrates across Ahmedabad, Gandhinagar, Mehsana, Surendranagar, and premier destinations throughout Gujarat.",
          style: AppTheme.sansBody(
            fontSize: isMobile ? 12.0 : 12.5,
            color: Colors.white70,
            height: 1.45,
          ),
        ),
        SizedBox(height: isMobile ? 14 : 16),
        VenueSearchCard(
          pincodeCtrl: pincodeCtrl,
          checkResult: checkResult,
          onCheck: onCheck,
          onClearResult: onClearResult,
          goldColor: goldColor,
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 14 : 16),
        ServiceAreaFeatures(
          goldColor: goldColor,
          isDesktop: isDesktop,
          isLaptop: isLaptop,
          isTablet: isTablet,
          isMobile: isMobile,
        ),
      ],
    );

    final rightMap = GujaratCoverageMap(
      goldColor: goldColor,
      onCitySelected: onCitySelected,
    );

    if (isDesktop || isLaptop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: isDesktop ? 44 : 46, child: leftContent),
          SizedBox(width: isDesktop ? 20 : 16),
          Expanded(
            flex: isDesktop ? 56 : 54,
            child: SizedBox(height: isDesktop ? 400 : 380, child: rightMap),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftContent,
          const SizedBox(height: 18),
          SizedBox(height: isTablet ? 380 : 300, child: rightMap),
        ],
      );
    }
  }
}
