import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/review_model.dart';
import 'widgets/admin_back_button.dart';

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

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Card(
              color: const Color(0xFF162822),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: Color(0xFF254235)),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF0D1915),
                              radius: 18,
                              child: Text(
                                review.customerName.isEmpty
                                    ? 'C'
                                    : review.customerName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFFC8A26A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.customerName,
                                  style: AppTheme.serifHeader(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  review.eventName,
                                  style: AppTheme.sansBody(
                                    fontSize: 11,
                                    color: const Color(0xFFA4A9A7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: List.generate(5, (starIdx) {
                            return Icon(
                              starIdx < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFC8A26A),
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review.comment,
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Published",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFA4A9A7),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Switch(
                              value: review.isPublished,
                              activeColor: const Color(0xFFC8A26A),
                              onChanged: (val) {
                                final updated = _copyWith(
                                  review,
                                  isPublished: val,
                                );
                                controller.saveReview(updated, isEdit: true);
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: Color(0xFFA4A9A7),
                              ),
                              onPressed:
                                  () => _showReviewDialog(
                                    context,
                                    review: review,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.redAccent,
                              ),
                              onPressed:
                                  () => controller.deleteReview(review.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showReviewDialog(BuildContext context, {ReviewModel? review}) {
    final isEdit = review != null;
    final nameCtrl = TextEditingController(text: review?.customerName ?? '');
    final eventCtrl = TextEditingController(text: review?.eventName ?? '');
    final commentCtrl = TextEditingController(text: review?.comment ?? '');
    double ratingVal = (review?.rating ?? 5).toDouble();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF162822),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF254235)),
        ),
        title: Text(
          isEdit ? "EDIT REVIEW" : "ADD REVIEW",
          style: const TextStyle(
            color: Color(0xFFC8A26A),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField("Customer Name", nameCtrl),
              const SizedBox(height: 12),
              _buildField("Event Name", eventCtrl),
              const SizedBox(height: 12),
              _buildField("Comment", commentCtrl, maxLines: 3),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Rating Status",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  DropdownButton<double>(
                    value: ratingVal,
                    dropdownColor: const Color(0xFF162822),
                    items:
                        [5.0, 4.0, 3.0, 2.0, 1.0].map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(
                              r.toInt().toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) ratingVal = val;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8A26A),
            ),
            onPressed: () {
              final newReview = ReviewModel(
                id:
                    review?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                customerName: nameCtrl.text,
                eventName: eventCtrl.text,
                rating: ratingVal.toInt(),
                comment: commentCtrl.text,
                imageUrl: review?.imageUrl ?? '',
                isVerified: review?.isVerified ?? true,
                isPublished: review?.isPublished ?? true,
                createdAt: review?.createdAt ?? DateTime.now(),
              );
              controller.saveReview(newReview, isEdit: isEdit);
              Get.back();
            },
            child: const Text(
              "SAVE",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFFC8A26A),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            fillColor: Color(0xFF0D1915),
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF254235)),
            ),
          ),
        ),
      ],
    );
  }

  ReviewModel _copyWith(ReviewModel r, {bool? isPublished}) {
    return ReviewModel(
      id: r.id,
      customerName: r.customerName,
      eventName: r.eventName,
      rating: r.rating,
      comment: r.comment,
      imageUrl: r.imageUrl,
      isVerified: r.isVerified,
      isPublished: isPublished ?? r.isPublished,
      experienceId: r.experienceId,
      createdAt: r.createdAt,
    );
  }
}
