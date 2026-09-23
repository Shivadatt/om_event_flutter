import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/constants/app_collections.dart';
import 'package:om_event/domain/entities/quotation.dart';

/// Shows the customer review submission dialog for an eligible booking.
void showCustomerReviewDialog(
  BuildContext context, {
  required Quotation quotation,
  VoidCallback? onSubmitted,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (context) => CustomerReviewDialog(
      quotation: quotation,
      onSubmitted: onSubmitted,
    ),
  );
}

class CustomerReviewDialog extends StatefulWidget {
  final Quotation quotation;
  final VoidCallback? onSubmitted;

  const CustomerReviewDialog({
    super.key,
    required this.quotation,
    this.onSubmitted,
  });

  @override
  State<CustomerReviewDialog> createState() => _CustomerReviewDialogState();
}

class _CustomerReviewDialogState extends State<CustomerReviewDialog> {
  int _rating = 5;
  late final TextEditingController _nameController;
  late final TextEditingController _serviceController;
  final TextEditingController _commentController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final defaultService = widget.quotation.items.isNotEmpty
        ? widget.quotation.items.first.name
        : 'Event Decor';
    _nameController = TextEditingController(text: widget.quotation.customerName);
    _serviceController = TextEditingController(text: defaultService);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serviceController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    final name = _nameController.text.trim();
    final service = _serviceController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = "Please enter your name.");
      return;
    }
    if (comment.length < 10) {
      setState(() => _errorMessage = "Please write at least 10 characters in your review.");
      return;
    }
    if (comment.length > 600) {
      setState(() => _errorMessage = "Review text cannot exceed 600 characters.");
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // Duplicate check: verify quotation hasn't already submitted a review
      final existingReviews = await firestore
          .collection(AppCollections.reviews)
          .where('quotation_id', isEqualTo: widget.quotation.id)
          .limit(1)
          .get();

      if (existingReviews.docs.isNotEmpty) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = "A review has already been submitted for this booking.";
        });
        return;
      }

      final now = DateTime.now();

      // Write to public reviews collection with is_published = false (moderation queue)
      await firestore.collection(AppCollections.reviews).add({
        'customer_name': name,
        'event_name': service.isNotEmpty
            ? service
            : (widget.quotation.items.isNotEmpty ? widget.quotation.items.first.name : 'Event Decor'),
        'rating': _rating,
        'comment': comment,
        'image_url': '',
        'is_verified': true,
        'is_published': false, // Requires admin moderation
        'experience_id': widget.quotation.items.isNotEmpty ? widget.quotation.items.first.experienceId : '',
        'quotation_id': widget.quotation.id,
        'public_booking_id': widget.quotation.publicId,
        'created_at': now.toIso8601String(),
        'is_featured': false,
        'display_order': 1,
        'is_active': true,
      });

      // Also record in customer reviews collection
      await firestore.collection(AppCollections.customerReviews).add({
        'customerId': widget.quotation.customerId,
        'quotationId': widget.quotation.id,
        'publicBookingId': widget.quotation.publicId,
        'customerName': name,
        'rating': _rating,
        'reviewText': comment,
        'status': 'Pending Moderation',
        'createdAt': now.toIso8601String(),
      });

      // Update quotation with hasReview flag
      await firestore.collection(AppCollections.quotations).doc(widget.quotation.id).update({
        'hasReview': true,
        'reviewRating': _rating,
        'reviewedAt': now.toIso8601String(),
      });

      if (!mounted) return;

      widget.onSubmitted?.call();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Thank you! Your review has been submitted for moderation.",
            style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1E4233),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = "Could not submit review at this moment. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = AppColors.secondaryAccent;

    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          backgroundColor: const Color(0xFF0D1B16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: goldColor.withValues(alpha: 0.3)),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.star_rounded, color: goldColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SHARE YOUR EXPERIENCE",
                            style: GoogleFonts.italiana(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Booking ${widget.quotation.publicId}",
                            style: AppTheme.sansBody(fontSize: 11, color: goldColor),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Star Rating Picker
                Text(
                  "YOUR RATING",
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _rating = starIndex;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Icon(
                          starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 32,
                          color: starIndex <= _rating ? goldColor : Colors.white30,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),

                // Name Field
                Text(
                  "CUSTOMER NAME",
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _nameController,
                  hintText: "Your Name",
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),

                // Service / Event Field
                Text(
                  "EVENT / SERVICE TYPE",
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _serviceController,
                  hintText: "e.g. Birthday Celebration, Wedding Reception",
                  icon: Icons.celebration_outlined,
                ),
                const SizedBox(height: 14),

                // Review Comment Field
                Text(
                  "YOUR REVIEW",
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF132620),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: goldColor.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 4,
                    maxLength: 600,
                    style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "How was our decor setup, team coordination, and overall celebration experience?",
                      hintStyle: AppTheme.sansBody(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                      counterStyle: AppTheme.sansBody(fontSize: 10, color: Colors.white38),
                    ),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE57373).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTheme.sansBody(fontSize: 11, color: const Color(0xFFE57373)),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        child: Text(
                          "Cancel",
                          style: AppTheme.sansBody(fontSize: 13, color: Colors.white60),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          foregroundColor: const Color(0xFF0F1B18),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0F1B18),
                                ),
                              )
                            : Text(
                                "SUBMIT REVIEW",
                                style: AppTheme.sansBody(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: const Color(0xFF0F1B18),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF132620),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTheme.sansBody(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          prefixIcon: Icon(
            icon,
            size: 16,
            color: AppColors.secondaryAccent.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
