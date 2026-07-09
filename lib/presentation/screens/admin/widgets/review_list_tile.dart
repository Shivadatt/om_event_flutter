import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
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

  Widget _statusToggle(BuildContext context, String label, bool value, ValueChanged<bool> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color labelColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 10,
            color: labelColor,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          height: 24,
          width: 32,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Switch(
              value: value,
              activeColor: AppColors.primaryAccent,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final Color activeColor = AppColors.primaryAccent;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Customer portrait & Rating
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: activeColor.withValues(alpha: 0.1),
                  radius: 22,
                  backgroundImage: review.imageUrl.isNotEmpty
                      ? NetworkImage(review.imageUrl)
                      : null,
                  child: review.imageUrl.isEmpty
                      ? Text(
                          review.customerName.isEmpty
                              ? 'C'
                              : review.customerName[0].toUpperCase(),
                          style: TextStyle(
                            color: activeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              review.customerName,
                              style: AppTheme.serifHeader(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (review.isVerified) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.verified_rounded,
                              color: activeColor,
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        review.eventName.toUpperCase(),
                        style: AppTheme.sansBody(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: activeColor,
                          letterSpacing: 1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 14),

            // Stars
            Row(
              children: List.generate(5, (starIdx) {
                return Icon(
                  starIdx < review.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: activeColor,
                  size: 16,
                );
              }),
            ),
            
            const SizedBox(height: 12),

            // Editorial Quote Comment
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "\"${review.comment}\"",
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    color: subtitleColor,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const Divider(height: 20),

            // Toggle Switches & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 12,
                  children: [
                    _statusToggle(context, "Featured", review.isFeatured, (val) {
                      final updated = _copyWith(review, isFeatured: val);
                      controller.saveReview(updated, isEdit: true);
                    }),
                    _statusToggle(context, "Active", review.isActive, (val) {
                      final updated = _copyWith(review, isActive: val);
                      controller.saveReview(updated, isEdit: true);
                    }),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_note_rounded, size: 20, color: textColor),
                      onPressed: onEdit,
                      tooltip: "Edit Review",
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_sweep_outlined,
                        size: 20,
                        color: AppColors.error,
                      ),
                      onPressed: onDelete,
                      tooltip: "Delete Review",
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
