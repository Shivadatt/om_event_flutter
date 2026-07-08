import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/review_model.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/review_list_tile.dart';
import 'widgets/review_form_dialog.dart';

class ManageReviewsScreen extends GetView<AdminController> {
  const ManageReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1714),
      appBar: AppBar(
        leading: const AdminBackButton(),
        title: Text(
          "CUSTOMER REVIEWS",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showReviewDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingReviews.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFFC8A26A)),
            ),
          );
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

        return ListView.builder(
          padding: const EdgeInsets.all(24),
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
