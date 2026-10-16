import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

/// A banner displayed at the top of the Customer home screen for studio announcements.
class AnnouncementBanner extends StatelessWidget {
  final bool isDesktop;

  /// Creates an [AnnouncementBanner] configured for desktop or mobile layout spacing.
  const AnnouncementBanner({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isVerySmall = width < 420;
    final isNarrowMobile = width <= 370;

    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      width: double.infinity,
      color: const Color(0xFFB88957),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : (isNarrowMobile ? 8 : 12),
        vertical: isVerySmall ? 6 : 4,
      ),
      child: Text(
        "NOW ACCEPTING CELEBRATIONS FOR JULY–DECEMBER 2026    •    GUJARAT & BEYOND",
        style: AppTheme.sansBody(
          fontSize: isDesktop ? 10 : (isNarrowMobile ? 7.6 : (isVerySmall ? 8.0 : 8.8)),
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: isDesktop ? 2.0 : (isNarrowMobile ? 0.8 : 1.2),
          height: 1.35,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

