import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';

class ContactStudioCard extends StatelessWidget {
  final String title;
  final String address;
  final String imageAsset;
  final Color goldColor;
  final bool isDesktop;
  final bool isMobile;
  final VoidCallback onMapTap;
  final VoidCallback onDirectionsTap;

  const ContactStudioCard({
    super.key,
    required this.title,
    required this.address,
    required this.imageAsset,
    required this.goldColor,
    required this.isDesktop,
    required this.isMobile,
    required this.onMapTap,
    required this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 34,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF14241F),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: goldColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 66,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 10 : 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: goldColor,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.italiana(
                              fontSize: isMobile ? 14.5 : 15.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Material(
                          color: goldColor.withValues(alpha: 0.15),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onDirectionsTap,
                            child: const Padding(
                              padding: EdgeInsets.all(4.5),
                              child: Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.secondaryAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      address,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: isMobile ? 10 : 11,
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onMapTap,
                          icon: Icon(
                            Icons.map_outlined,
                            size: 11,
                            color: goldColor,
                          ),
                          label: Text(
                            "View Map",
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              color: goldColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: goldColor.withValues(alpha: 0.45),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: onDirectionsTap,
                          icon: const Icon(
                            Icons.navigation_outlined,
                            size: 11,
                            color: Color(0xFF091210),
                          ),
                          label: Text(
                            "Directions",
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              color: const Color(0xFF091210),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goldColor,
                            foregroundColor: const Color(0xFF091210),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
