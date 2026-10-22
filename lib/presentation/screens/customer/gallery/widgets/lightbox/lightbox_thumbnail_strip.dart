import 'package:flutter/material.dart';
import '../../../../../../core/widgets/app_image.dart';
import '../../../../../../domain/entities/gallery_item.dart';

class LightboxThumbnailStrip extends StatelessWidget {
  final List<GalleryItem> items;
  final int currentIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onSelectIndex;
  final Color goldColor;

  const LightboxThumbnailStrip({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.scrollController,
    required this.onSelectIndex,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    if (items.length <= 1) return const SizedBox.shrink();

    return Container(
      height: 62,
      color: const Color(0xFF060D0A),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == currentIndex;
          final thumbItem = items[index];

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelectIndex(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 72,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? goldColor : Colors.white12,
                    width: isSelected ? 2.2 : 1.0,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: goldColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 1),
                            ),
                          ]
                          : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.5),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: isSelected ? 1.0 : 0.65,
                          child: AppImage(
                            url: thumbItem.effectiveThumbnail,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (thumbItem.tags.any(
                          (t) => t.toLowerCase().contains('video'),
                        ))
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
