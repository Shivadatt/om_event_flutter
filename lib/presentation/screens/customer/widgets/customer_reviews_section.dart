import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/constants/app_colors.dart';
import '../../../../core/config/app_theme.dart';
import '../../../controllers/catalog_controller.dart';
import 'review_slider.dart';
import 'empty_review_widget.dart';

class CustomerReviewsSection extends StatelessWidget {
  final bool isDesktop;

  const CustomerReviewsSection({
    super.key,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CatalogController>();

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 80 : 20,
          vertical: isDesktop ? 72 : 48,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF152621), // Secondary Background
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Section Header (Luxury style)
            Text(
              "HEARD FROM CLIENTS",
              style: AppTheme.sansBody(
                fontSize: 10,
                color: AppColors.secondaryAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.5,
              ),
            ),
            const SizedBox(height: 12),
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFE8A3), Color(0xFFF3D37A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                "WHAT OUR CUSTOMERS SAY.",
                style: GoogleFonts.italiana(
                  fontSize: isDesktop ? 34 : 26,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Real experiences shared by our happy clients.",
              style: AppTheme.sansBody(
                fontSize: 14,
                color: AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Realtime Stream Builder
            Obx(() {
              final reviews = controller.rxReviews;

              if (reviews.isEmpty) {
                return const EmptyReviewWidget();
              }

              return ReviewSlider(
                reviews: reviews,
                isDesktop: isDesktop,
              );
            }),
          ],
        ),
      ),
    );
  }
}
