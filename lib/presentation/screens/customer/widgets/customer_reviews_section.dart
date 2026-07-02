import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          vertical: 64,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF0B1714),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Section Header
            Text(
              "What Our Customers Say",
              style: AppTheme.serifHeader(
                fontSize: isDesktop ? 32 : 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Real experiences shared by our happy clients.",
              style: AppTheme.sansBody(
                fontSize: 14,
                color: const Color(0xFFA4A9A7),
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
