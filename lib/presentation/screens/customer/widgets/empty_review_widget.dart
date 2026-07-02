import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

class EmptyReviewWidget extends StatelessWidget {
  const EmptyReviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rate_review_outlined,
              color: const Color.fromRGBO(201, 167, 126, 0.3),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "No customer reviews available yet.",
              style: AppTheme.sansBody(
                fontSize: 14,
                color: Colors.white30,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
