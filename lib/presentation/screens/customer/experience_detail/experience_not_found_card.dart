import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';

class ExperienceNotFoundCard extends StatelessWidget {
  final Color goldColor;
  final Color cardBgColor;

  const ExperienceNotFoundCard({
    super.key,
    required this.goldColor,
    required this.cardBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: goldColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: goldColor),
            const SizedBox(height: 16),
            Text(
              "Experience Not Found",
              style: GoogleFonts.italiana(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "The setup or service you are looking for may have been updated or renamed.",
              style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: const Color(0xFF09120E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "EXPLORE ALL EXPERIENCES",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
