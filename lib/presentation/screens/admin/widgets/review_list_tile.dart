import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/review_model.dart';
import '../../../controllers/admin_controller.dart';

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

  static const Color goldColor = Color(0xFFECC24A);
  static const Color cardBg = Color(0xFF0C1914);

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── 1. Top Section: Header + Rating + Comment ───────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar + Name + Event
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF142921),
                      border: Border.all(
                        color: goldColor.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                    ),
                    child: ClipOval(
                      child: review.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: review.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _buildInitial(),
                            )
                          : _buildInitial(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                review.customerName.isNotEmpty
                                    ? review.customerName
                                    : "Client",
                                style: GoogleFonts.montserrat(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (review.isVerified) ...[
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.verified,
                                color: goldColor,
                                size: 13.5,
                              ),
                            ],
                          ],
                        ),
                        if (review.eventName.isNotEmpty) ...[
                          const SizedBox(height: 1),
                          Text(
                            review.eventName.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: goldColor,
                              letterSpacing: 0.8,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Star Rating
              Row(
                children: List.generate(5, (index) {
                  final isFilled = index < review.rating;
                  return Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFilled ? goldColor : Colors.white24,
                      size: 14.0,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 5),

              // Quoted Review Text (Matches Image 1 multi-line compact typography)
              Text(
                "\"${review.comment}\"",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 11.5,
                  color: Colors.white70,
                  height: 1.35,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),

          // ── 2. Bottom Section: Divider + Controls ──────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 1,
                margin: const EdgeInsets.only(bottom: 9),
                color: Colors.white.withValues(alpha: 0.08),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Featured",
                        style: GoogleFonts.montserrat(
                          fontSize: 10.0,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                      _CompactPillSwitch(
                        value: review.isFeatured,
                        onChanged: (val) {
                          final updated = _copyWith(review, isFeatured: val);
                          controller.saveReview(updated, isEdit: true);
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Active",
                        style: GoogleFonts.montserrat(
                          fontSize: 10.0,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                      _CompactPillSwitch(
                        value: review.isActive,
                        onChanged: (val) {
                          final updated = _copyWith(review, isActive: val);
                          controller.saveReview(updated, isEdit: true);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(5),
                        child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Icon(
                            Icons.edit_note_rounded,
                            size: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(5),
                        child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Color(0xFFE55353),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitial() {
    final initial = review.customerName.isNotEmpty
        ? review.customerName[0].toUpperCase()
        : 'C';
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.montserrat(
          color: goldColor,
          fontWeight: FontWeight.bold,
          fontSize: 13.5,
        ),
      ),
    );
  }
}

/// Compact pill switch matching IMAGE 1 reference toggle design
class _CompactPillSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CompactPillSwitch({
    required this.value,
    required this.onChanged,
  });

  static const Color goldColor = Color(0xFFECC24A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 28,
        height: 15,
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: value ? goldColor : const Color(0xFF10201A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? goldColor : Colors.white24,
            width: 0.9,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? const Color(0xFF0C1914) : Colors.white60,
            ),
          ),
        ),
      ),
    );
  }
}
