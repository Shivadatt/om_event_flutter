import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_images.dart';
import 'contact_hero_divider.dart';
import 'contact_hero_video_dialog.dart';

class ContactHeroSection extends StatelessWidget {
  final Color goldColor;
  final bool isDesktop;
  final bool isTablet;
  final bool isMobile;

  const ContactHeroSection({
    super.key,
    required this.goldColor,
    required this.isDesktop,
    required this.isTablet,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: isDesktop ? 300 : (isTablet ? 270 : 250),
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF091410),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.luxuryEveningDecor,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0C1914)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF060B09).withValues(alpha: 0.88),
                    const Color(0xFF060D0A).withValues(alpha: 0.65),
                    const Color(0xFF060D0A).withValues(alpha: 0.98),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: isMobile ? 12 : 20,
            right: isMobile ? 14 : 24,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => showContactHeroVideoDialog(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 14,
                    vertical: isMobile ? 5 : 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1914).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: goldColor.withValues(alpha: 0.45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        size: isMobile ? 14 : 16,
                        color: goldColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Play Video",
                        style: AppTheme.sansBody(
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 14 : 20,
                vertical: isMobile ? 42 : 36,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "CONNECT WITH OUR CREATIVE TEAM",
                      textAlign: TextAlign.center,
                      style: AppTheme.sansBody(
                        fontSize: isMobile ? 9.0 : 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: isMobile ? 1.8 : 2.8,
                        color: goldColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Let's Craft Something ",
                            style: GoogleFonts.italiana(
                              fontSize: isDesktop ? 36 : (isTablet ? 30 : 23),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                          TextSpan(
                            text: "Extraordinary.",
                            style: GoogleFonts.italiana(
                              fontSize: isDesktop ? 36 : (isTablet ? 30 : 23),
                              fontWeight: FontWeight.bold,
                              color: goldColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Whether you're planning a lavish wedding, an intimate milestone birthday, or require custom fabrication, our dual studios in Kadi and Thangadh are ready to assist you.",
                      textAlign: TextAlign.center,
                      style: AppTheme.sansBody(
                        fontSize: isMobile ? 11.0 : (isTablet ? 11.5 : 12.5),
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ContactHeroDivider(
                      goldColor: goldColor,
                      isMobile: isMobile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
