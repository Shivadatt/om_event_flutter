import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../controllers/admin_controller.dart';
import '../../../../data/models/review_model.dart';

class ReviewListTile extends StatelessWidget {
  final ReviewModel review;
  final AdminController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReviewListTile({
    super.key,
    required this.review,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  ReviewModel _copyWith(
    ReviewModel r, {
    bool? isPublished,
    bool? isFeatured,
    bool? isActive,
    int? displayOrder,
  }) {
    return ReviewModel(
      id: r.id,
      customerName: r.customerName,
      eventName: r.eventName,
      rating: r.rating,
      comment: r.comment,
      imageUrl: r.imageUrl,
      isVerified: r.isVerified,
      isPublished: isPublished ?? r.isPublished,
      isFeatured: isFeatured ?? r.isFeatured,
      displayOrder: displayOrder ?? r.displayOrder,
      isActive: isActive ?? r.isActive,
      experienceId: r.experienceId,
      createdAt: r.createdAt,
    );
  }

  Widget _statusToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFA4A9A7),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          height: 30,
          child: Switch(
            value: value,
            activeColor: const Color(0xFFC8A26A),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      backgroundImage: review.imageUrl.isNotEmpty
                          ? NetworkImage(review.imageUrl)
                          : null,
                      child: review.imageUrl.isEmpty
                          ? Text(
                              review.customerName.isEmpty
                                  ? 'C'
                                  : review.customerName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFC8A26A),
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              review.customerName,
                              style: AppTheme.serifHeader(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (review.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                  Icons.verified,
                                  color: Color(0xFFC8A26A),
                                  size: 14,
                                ),
                            ],
                            if (review.isFeatured) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(200, 162, 106, 0.2),
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFFC8A26A),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Text(
                                  "FEATURED",
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Color(0xFFC8A26A),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          "${review.eventName} • Display Order: ${review.displayOrder}",
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
                Wrap(
                  spacing: 16,
                  children: [
                    _statusToggle("Published", review.isPublished, (val) {
                      final updated = _copyWith(review, isPublished: val);
                      controller.saveReview(updated, isEdit: true);
                    }),
                    _statusToggle("Featured", review.isFeatured, (val) {
                      final updated = _copyWith(review, isFeatured: val);
                      controller.saveReview(updated, isEdit: true);
                    }),
                    _statusToggle("Active", review.isActive, (val) {
                      final updated = _copyWith(review, isActive: val);
                      controller.saveReview(updated, isEdit: true);
                    }),
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
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
