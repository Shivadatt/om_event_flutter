import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RatingWidget extends StatelessWidget {
  final int rating;
  final double size;

  const RatingWidget({
    super.key,
    required this.rating,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: AppColors.secondaryAccent,
          size: size,
        );
      }),
    );
  }
}
