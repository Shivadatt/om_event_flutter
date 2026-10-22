import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../domain/entities/gallery_item.dart';
import '../../../../controllers/gallery_controller.dart';
import 'lightbox/lightbox_helpers.dart';
import 'lightbox/lightbox_image_stage.dart';
import 'lightbox/lightbox_info_section.dart';
import 'lightbox/lightbox_thumbnail_strip.dart';

void showGalleryLightbox(
  BuildContext context, {
  required List<GalleryItem> items,
  required int initialIndex,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder:
        (_) => GalleryLightboxDialog(items: items, initialIndex: initialIndex),
  );
}

class GalleryLightboxDialog extends StatefulWidget {
  final List<GalleryItem> items;
  final int initialIndex;

  const GalleryLightboxDialog({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  State<GalleryLightboxDialog> createState() => _GalleryLightboxDialogState();
}

class _GalleryLightboxDialogState extends State<GalleryLightboxDialog> {
  late int _currentIndex;
  late final ScrollController _thumbScrollController;
  final FocusNode _focusNode = FocusNode();
  final Set<String> _favoriteIds = {};

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _cardBgColor = Color(0xFF091210);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      widget.items.isEmpty ? 0 : widget.items.length - 1,
    );
    _thumbScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => scrollThumbStripTo(_thumbScrollController, _currentIndex),
    );
  }

  @override
  void dispose() {
    _thumbScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectIndex(int index) {
    setState(() => _currentIndex = index);
    scrollThumbStripTo(_thumbScrollController, index);
  }

  void _next() {
    final nextIdx =
        (_currentIndex < widget.items.length - 1) ? _currentIndex + 1 : 0;
    _selectIndex(nextIdx);
  }

  void _prev() {
    final prevIdx =
        (_currentIndex > 0) ? _currentIndex - 1 : widget.items.length - 1;
    _selectIndex(prevIdx);
  }

  void _toggleFavorite(String id, String title) {
    setState(() {
      _favoriteIds.contains(id)
          ? _favoriteIds.remove(id)
          : _favoriteIds.add(id);
    });
    showLightboxFavoriteSnackBar(
      context,
      _favoriteIds.contains(id),
      title,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final item = widget.items[_currentIndex];
    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 1024;
    final isTablet = screenW >= 600 && screenW < 1024;

    final galleryCtrl =
        Get.isRegistered<GalleryController>()
            ? Get.find<GalleryController>()
            : null;
    final matchedExp = galleryCtrl?.findExperienceForGalleryItem(item);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) => handleLightboxKeyEvent(
        event,
        onNext: _next,
        onPrev: _prev,
        onClose: () => Navigator.of(context).pop(),
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 16,
          vertical: 20,
        ),
        child: Container(
          width:
              isDesktop
                  ? 880
                  : (isTablet
                      ? (screenW * 0.90).clamp(580.0, 780.0)
                      : double.infinity),
          constraints: BoxConstraints(
            maxWidth: 880,
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          decoration: BoxDecoration(
            color: _cardBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _goldColor.withValues(alpha: 0.38),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 40,
                spreadRadius: 2,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LightboxImageStage(
                    item: item,
                    currentIndex: _currentIndex,
                    totalCount: widget.items.length,
                    isFavorite: _favoriteIds.contains(item.id),
                    onToggleFavorite: () => _toggleFavorite(item.id, item.title),
                    onShare: () => copyAndShowLightboxShareSnackBar(context, item.imageUrl),
                    onClose: () => Navigator.of(context).pop(),
                    onPrev: _prev,
                    onNext: _next,
                    goldColor: _goldColor,
                  ),
                  LightboxThumbnailStrip(
                    items: widget.items,
                    currentIndex: _currentIndex,
                    scrollController: _thumbScrollController,
                    onSelectIndex: _selectIndex,
                    goldColor: _goldColor,
                  ),
                  LightboxInfoSection(
                    item: item,
                    matchedExp: matchedExp,
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                    onBookTheme: handleLightboxBookTheme,
                    onViewServiceDetails: handleLightboxViewDetails,
                    goldColor: _goldColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
