import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:om_event/core/constants/app_colors.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../domain/entities/review.dart';
import 'rating_widget.dart';
import 'verified_badge.dart';

class ReviewCard extends StatefulWidget {
  final Review review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.review.imageUrl.isNotEmpty;
    final initials = widget.review.customerName.isEmpty
        ? 'C'
        : widget.review.customerName[0].toUpperCase();

    final borderActive = AppColors.secondaryAccent.withValues(alpha: 0.4);
    final borderInactive = AppColors.primaryAccent.withValues(alpha: 0.12);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isHovered
                ? [const Color(0xFF213830), const Color(0xFF1B2D27)] // Elevated Card -> Card Background
                : [const Color(0xFF1B2D27), const Color(0xFF0F1B18)], // Card Background -> Primary Background
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? borderActive : borderInactive,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.secondaryAccent.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: _isHovered ? 20 : 10,
              offset: _isHovered ? const Offset(0, 6) : const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Testimonial Background Quote Mark
            Positioned(
              right: -4,
              top: -4,
              child: Opacity(
                opacity: _isHovered ? 0.12 : 0.06,
                child: const Icon(
                  Icons.format_quote,
                  color: AppColors.secondaryAccent,
                  size: 48,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Star Rating & Verified Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RatingWidget(rating: widget.review.rating, size: 14),
                    if (widget.review.isVerified) const VerifiedBadge(),
                  ],
                ),
                const SizedBox(height: 12),
                // Review Text
                Expanded(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Text(
                      widget.review.comment,
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        color: AppColors.muted.withValues(alpha: 0.9),
                        height: 1.5,
                      ).copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Divider line
                Container(
                  height: 1,
                  color: AppColors.primaryAccent.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 10),
                // Customer Profile Details
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryAccent.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: const Color(0xFF0F1B18), // Primary Background
                        backgroundImage: hasImage
                            ? CachedNetworkImageProvider(
                                widget.review.imageUrl,
                                maxWidth: 68,
                                maxHeight: 68,
                              )
                            : null,
                        child: !hasImage
                            ? Text(
                                initials,
                                style: AppTheme.sansBody(
                                  fontSize: 12,
                                  color: AppColors.secondaryAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.review.customerName,
                                  style: AppTheme.serifHeader(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.review.isFeatured) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryAccent.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: AppColors.secondaryAccent.withValues(alpha: 0.35),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    "FEATURED",
                                    style: AppTheme.sansBody(
                                      fontSize: 6.5,
                                      color: AppColors.secondaryAccent,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.review.eventName,
                            style: AppTheme.sansBody(
                              fontSize: 10.5,
                              color: AppColors.muted.withValues(alpha: 0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
