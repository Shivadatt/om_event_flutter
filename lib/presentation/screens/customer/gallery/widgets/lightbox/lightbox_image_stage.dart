import 'package:flutter/material.dart';
import '../../../../../../core/config/app_theme.dart';
import '../../../../../../core/widgets/app_image.dart';
import '../../../../../../domain/entities/gallery_item.dart';
import 'lightbox_control_buttons.dart';
import 'lightbox_helpers.dart';

class LightboxImageStage extends StatelessWidget {
  final GalleryItem item;
  final int currentIndex;
  final int totalCount;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShare;
  final VoidCallback onClose;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Color goldColor;

  const LightboxImageStage({
    super.key,
    required this.item,
    required this.currentIndex,
    required this.totalCount,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onShare,
    required this.onClose,
    required this.onPrev,
    required this.onNext,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: const Color(0xFF060D0A),
        child: Stack(
          fit: StackFit.expand,
          children: [
            buildLightboxBlurredBackground(item.imageUrl),
            Center(
              child: InteractiveViewer(
                key: ValueKey(item.id),
                minScale: 1.0,
                maxScale: 4.0,
                clipBehavior: Clip.hardEdge,
                child: AppImage(url: item.imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 75,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC091210),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: goldColor.withValues(alpha: 0.45),
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "${currentIndex + 1} / $totalCount",
                  style: AppTheme.sansBody(
                    fontSize: 11.5,
                    color: goldColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LightboxControlButtons.buildCircleIconButton(
                    icon: isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: isFavorite ? Colors.redAccent : goldColor,
                    tooltip:
                        isFavorite ? "Remove Favorite" : "Add to Favorites",
                    onTap: onToggleFavorite,
                  ),
                  const SizedBox(width: 8),
                  LightboxControlButtons.buildCircleIconButton(
                    icon: Icons.share_outlined,
                    iconColor: Colors.white,
                    tooltip: "Share Photo",
                    onTap: onShare,
                  ),
                  const SizedBox(width: 8),
                  LightboxControlButtons.buildCircleIconButton(
                    icon: Icons.close_rounded,
                    iconColor: Colors.white,
                    tooltip: "Close Viewer (Esc)",
                    onTap: onClose,
                  ),
                ],
              ),
            ),
            if (totalCount > 1) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: LightboxControlButtons.buildCircleNavButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: "Previous Photo (Left Arrow)",
                    onTap: onPrev,
                    goldColor: goldColor,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: LightboxControlButtons.buildCircleNavButton(
                    icon: Icons.chevron_right_rounded,
                    tooltip: "Next Photo (Right Arrow)",
                    onTap: onNext,
                    goldColor: goldColor,
                  ),
                ),
              ),
            ],
            Positioned(
              bottom: 12,
              right: 14,
              child: LightboxControlButtons.buildCircleIconButton(
                icon: Icons.fullscreen_rounded,
                iconColor: goldColor,
                size: 32,
                iconSize: 18,
                tooltip: "Inspect Fullscreen",
                onTap:
                    () => LightboxControlButtons.openFullScreenViewer(
                      context,
                      item.imageUrl,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
