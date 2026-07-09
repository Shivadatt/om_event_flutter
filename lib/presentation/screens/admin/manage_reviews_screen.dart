import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/review_model.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/review_list_tile.dart';
import 'widgets/review_form_dialog.dart';

class ManageReviewsScreen extends GetView<AdminController> {
  const ManageReviewsScreen({super.key});

  int _getCrossAxisCount(double width) {
    if (width > 1100) return 3; // Desktop
    if (width > 700) return 2;  // Laptop/Tablet
    return 1;                   // Mobile
  }

  double _getChildAspectRatio(int crossAxisCount, double width) {
    final double cardWidth = (width - 64 - (crossAxisCount - 1) * 24) / crossAxisCount;
    return cardWidth / 240; // Aspect ratio for review testimonials
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B);
    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text(
          "CUSTOMER REVIEWS",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24, color: Color(0xFFD4AF37)),
            onPressed: () => _showReviewDialog(context),
          ),
          const SizedBox(width: 12),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoadingReviews.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
        }

        final reviews = controller.rxReviews;
        if (reviews.isEmpty) {
          return const Center(
            child: Text(
              "No customer reviews registered yet.",
              style: TextStyle(color: Colors.grey),
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
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
            final aspect = _getChildAspectRatio(crossAxisCount, constraints.maxWidth);

            return GridView.builder(
              padding: const EdgeInsets.all(32),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: aspect > 0 ? aspect : 1.2,
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
            );
          },
        );
      }),
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
