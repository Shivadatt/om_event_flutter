import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

/// Reusable Admin Empty results state panel.
class AdminEmptyState extends StatelessWidget {
  final String title;
  final String message;

  const AdminEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Color(0xFFC8A26A),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.serifHeader(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.sansBody(
                fontSize: 14,
                color: const Color(0xFFAAB4AE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
