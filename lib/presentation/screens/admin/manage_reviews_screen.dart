import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/review_model.dart';
import '../../controllers/admin_controller.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/review_form_dialog.dart';
import 'widgets/review_list_tile.dart';

class ManageReviewsScreen extends GetView<AdminController> {
  const ManageReviewsScreen({super.key});

  static const Color goldColor = Color(0xFFECC24A);

  @override
  Widget build(BuildContext context) {
    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isInsideDrawer
          ? null
          : AppBar(
              leading: const AdminBackButton(),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: Stack(
        children: [
          // ── Subtle Gold Luxury Flowing Waves Background ───────────────
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ReviewsGoldWavesPainter(),
              ),
            ),
          ),

          // ── Main Content ─────────────────────────────────────────────
          Obx(() {
            if (controller.isLoadingReviews.value) {
              return const Center(
                child: CircularProgressIndicator(color: goldColor),
              );
            }

            final reviews = controller.rxReviews;
            if (reviews.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                    constraints: const BoxConstraints(maxWidth: 420),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1914),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: goldColor.withValues(alpha: 0.20),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: goldColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: goldColor.withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Icon(
                            Icons.rate_review_outlined,
                            color: goldColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Customer Reviews",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "No reviews registered yet. Click + above to add a client review.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Sort reviews by displayOrder first, then createdAt desc
            final sortedReviews = List<ReviewModel>.from(reviews);
            sortedReviews.sort((a, b) {
              final orderCompare = a.displayOrder.compareTo(b.displayOrder);
              if (orderCompare != 0) return orderCompare;
              return b.createdAt.compareTo(a.createdAt);
            });

            return LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth = constraints.maxWidth;
                final bool isMobile = maxWidth < 750;
                // Reference IMAGE 1: 2 columns on desktop/tablet, 1 column on mobile
                final int crossAxisCount = isMobile ? 1 : 2;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 16 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Page Header Row: Title (Left) + Add Review Button (Right) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "CUSTOMER REVIEWS",
                            style: GoogleFonts.montserrat(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          // Compact Gold Rounded Square Add Button matching IMAGE 1 (~40px)
                          InkWell(
                            onTap: () => _showReviewDialog(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: goldColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: goldColor.withValues(alpha: 0.28),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 24,
                                color: Color(0xFF0C1914),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── 2-Column Compact Review Cards Grid ──────────────
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: isMobile ? 172 : 168,
                        ),
                        itemCount: sortedReviews.length,
                        itemBuilder: (context, index) {
                          final review = sortedReviews[index];
                          return ReviewListTile(
                            review: review,
                            controller: controller,
                            onEdit: () => _showReviewDialog(context, review: review),
                            onDelete: () => controller.deleteReview(review.id),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, {ReviewModel? review}) {
    Get.dialog(
      ReviewFormDialog(
        review: review,
        controller: controller,
      ),
    );
  }
}

/// Subtle luxury gold flowing waves painter across the background matching IMAGE 1
class _ReviewsGoldWavesPainter extends CustomPainter {
  const _ReviewsGoldWavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const goldColor = Color(0xFFECC24A);

    final w = size.width;
    final h = size.height;

    // Top-right radiating luxury golden wave ribbon fan
    for (int i = 0; i < 7; i++) {
      final double offset = i * 0.032;
      final double opacity = 0.04 + (i % 3) * 0.035;
      final paint = Paint()
        ..color = goldColor.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85 + (i % 2) * 0.25;

      final path = Path()
        ..moveTo(w * (0.36 + offset), 0)
        ..cubicTo(
          w * (0.56 + offset),
          h * (0.09 + offset * 0.5),
          w * (0.76 + offset * 0.8),
          h * (0.03 + offset * 0.4),
          w,
          h * (0.19 + offset * 1.1),
        );
      canvas.drawPath(path, paint);
    }

    // Bottom-left subtle luxury golden curves
    for (int i = 0; i < 5; i++) {
      final double offset = i * 0.038;
      final double opacity = 0.035 + (i % 3) * 0.03;
      final paint = Paint()
        ..color = goldColor.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8 + (i % 2) * 0.25;

      final path = Path()
        ..moveTo(0, h * (0.83 + offset * 0.5))
        ..cubicTo(
          w * (0.16 + offset),
          h * (0.76 + offset * 0.4),
          w * (0.33 + offset * 0.8),
          h * (0.91 + offset * 0.3),
          w * (0.52 + offset),
          h,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
