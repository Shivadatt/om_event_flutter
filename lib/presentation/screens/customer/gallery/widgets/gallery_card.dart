import 'package:flutter/material.dart';
import '../../../../../../core/widgets/app_image.dart';
import 'gallery_card_overlays.dart';

class GalleryCard extends StatefulWidget {
  final dynamic item;
  final VoidCallback onTap;

  const GalleryCard({super.key, required this.item, required this.onTap});

  @override
  State<GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<GalleryCard> {
  bool _isHovered = false;
  bool _isFavorite = false;

  static const Color _goldColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform:
              _isHovered
                  ? Matrix4.translationValues(0, -4, 0)
                  : Matrix4.identity(),
          decoration: BoxDecoration(
            color: const Color(0xFF101E1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  _isHovered ? _goldColor : _goldColor.withValues(alpha: 0.22),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    _isHovered
                        ? _goldColor.withValues(alpha: 0.22)
                        : Colors.black.withValues(alpha: 0.45),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: AppImage(
                    url: item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.98),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.45, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                GalleryCardCategoryBadge(
                  categoryName: (item.categoryName as String?) ?? '',
                  goldColor: _goldColor,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xCC091210),
                        border: Border.all(
                          color: _isFavorite ? _goldColor : Colors.white24,
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 15,
                          color:
                              _isFavorite
                                  ? const Color(0xFFEF4444)
                                  : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
                GalleryCardBottomOverlay(
                  title: (item.title as String?) ?? '',
                  description: (item.description as String?) ?? '',
                  goldColor: _goldColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
