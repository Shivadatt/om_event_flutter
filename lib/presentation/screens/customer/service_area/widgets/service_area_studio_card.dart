import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/config/app_theme.dart';

class ServiceAreaStudioCard extends StatelessWidget {
  final String title;
  final String address;
  final String primaryCoverage;
  final String imageAsset;
  final VoidCallback onArrowTap;
  final Color goldColor;
  final bool isMobile;

  const ServiceAreaStudioCard({
    super.key,
    required this.title,
    required this.address,
    required this.primaryCoverage,
    required this.imageAsset,
    required this.onArrowTap,
    required this.goldColor,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 122),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withValues(alpha: 0.22)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 36,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
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
              flex: 64,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 14,
                  vertical: isMobile ? 10 : 11,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: BoxDecoration(
                            color: goldColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: goldColor,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.italiana(
                              fontSize: isMobile ? 13.5 : 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Material(
                          color: goldColor,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onArrowTap,
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 12,
                                color: Color(0xFF091210),
                              ),
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
                        fontSize: isMobile ? 10 : 10.5,
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Primary Coverage: ",
                            style: AppTheme.sansBody(
                              fontSize: isMobile ? 9.5 : 10,
                              fontWeight: FontWeight.bold,
                              color: goldColor,
                            ),
                          ),
                          TextSpan(
                            text: primaryCoverage,
                            style: AppTheme.sansBody(
                              fontSize: isMobile ? 9.5 : 10,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
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
