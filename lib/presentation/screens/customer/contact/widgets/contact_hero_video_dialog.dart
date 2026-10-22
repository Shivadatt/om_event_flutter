import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_video_player.dart';

void showContactHeroVideoDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder: (_) => Dialog(
      backgroundColor: const Color(0xFF091410),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.secondaryAccent, width: 1.2),
      ),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "OM EVENTS SHOWCASE",
                style: GoogleFonts.italiana(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppVideoPlayer(videoUrl: AppAssets.videoWeddingShowcase),
            ),
          ],
        ),
      ),
    ),
  );
}
