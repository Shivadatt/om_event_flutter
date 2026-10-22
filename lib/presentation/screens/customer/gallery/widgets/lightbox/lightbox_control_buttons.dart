import 'package:flutter/material.dart';
import '../../../../../../core/widgets/app_image.dart';

class LightboxControlButtons {
  static Widget buildCircleIconButton({
    required IconData icon,
    required Color iconColor,
    required String tooltip,
    required VoidCallback onTap,
    double size = 34,
    double iconSize = 16,
  }) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xD9091210),
              border: Border.all(color: Colors.white24, width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: Icon(icon, color: iconColor, size: iconSize)),
          ),
        ),
      ),
    );
  }

  static Widget buildCircleNavButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color goldColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xCC070F0C),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.55),
                width: 1.1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: Icon(icon, color: goldColor, size: 24)),
          ),
        ),
      ),
    );
  }

  static void openFullScreenViewer(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder:
          (ctx) => Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: AppImage(url: imageUrl, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 24,
                right: 24,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
    );
  }
}
