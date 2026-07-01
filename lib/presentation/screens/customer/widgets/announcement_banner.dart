import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

/// A banner displayed at the top of the Customer home screen for studio announcements.
class AnnouncementBanner extends StatelessWidget {
  final bool isDesktop;

  /// Creates an [AnnouncementBanner] configured for desktop or mobile layout spacing.
  const AnnouncementBanner({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: double.infinity,
      color: const Color(0xFFB88957),
      alignment: Alignment.center,
      child: Text(
        "NOW ACCEPTING CELEBRATIONS FOR JULY–DECEMBER 2026    •    GUJARAT & BEYOND",
        style: AppTheme.sansBody(
          fontSize: isDesktop ? 10 : 8,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: isDesktop ? 2.0 : 1.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
