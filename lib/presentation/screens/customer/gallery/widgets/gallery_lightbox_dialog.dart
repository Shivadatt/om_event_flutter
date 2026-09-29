import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../domain/entities/experience.dart';
import '../../../../../domain/entities/gallery_item.dart';
import '../../../../controllers/gallery_controller.dart';
import '../../widgets/customer_booking_dialog.dart';
import '../../widgets/home_detail_dialog.dart';

void showGalleryLightbox(
  BuildContext context, {
  required List<GalleryItem> items,
  required int initialIndex,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder: (_) => GalleryLightboxDialog(items: items, initialIndex: initialIndex),
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToThumb(_currentIndex));
  }

  @override
  void dispose() {
    _thumbScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToThumb(int index) {
    if (!_thumbScrollController.hasClients) return;
    const itemWidth = 72.0; // 64 thumbnail width + 8 spacing
    final targetOffset = (index * itemWidth) - 140;
    _thumbScrollController.animateTo(
      targetOffset.clamp(0.0, _thumbScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _selectIndex(int index) {
    setState(() => _currentIndex = index);
    _scrollToThumb(index);
  }

  void _next() {
    final nextIdx = (_currentIndex < widget.items.length - 1) ? _currentIndex + 1 : 0;
    _selectIndex(nextIdx);
  }

  void _prev() {
    final prevIdx = (_currentIndex > 0) ? _currentIndex - 1 : widget.items.length - 1;
    _selectIndex(prevIdx);
  }

  void _toggleFavorite(String id, String title) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
    final isFav = _favoriteIds.contains(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFav ? "Saved to favorites: $title" : "Removed from favorites",
          style: const TextStyle(color: Colors.white, fontSize: 12.5),
        ),
        backgroundColor: const Color(0xFF10201B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareItem(GalleryItem item) {
    Clipboard.setData(ClipboardData(text: item.imageUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Theme link copied to clipboard!",
          style: TextStyle(color: Colors.white, fontSize: 12.5),
        ),
        backgroundColor: Color(0xFF10201B),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openFullScreenViewer(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (ctx) => Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: AppImage(
                url: imageUrl,
                fit: BoxFit.contain,
              ),
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
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = months[dt.month - 1];
    return '${dt.day} $m ${dt.year}';
  }

  void _onBookTheme(BuildContext context, GalleryItem item, Experience? matchedExp) {
    Navigator.of(context).pop();
    final targetExp = matchedExp ??
        Experience(
          id: item.serviceId.isNotEmpty ? item.serviceId : 'gallery_${item.id}',
          categoryId: item.categoryId,
          categoryName: item.categoryName.isNotEmpty ? item.categoryName : 'Decor Theme',
          categorySlug: item.categoryName.toLowerCase().replaceAll(' ', '-'),
          name: item.title,
          slug: item.title.toLowerCase().replaceAll(' ', '-'),
          description: item.description,
          price: 15000,
          durationHours: 4,
          popularity: 10,
          rating: 5.0,
          reviewCount: 1,
          availability: 'available',
          tags: item.tags,
          colors: const [],
          themes: [item.title],
          imageUrl: item.imageUrl,
          videoUrl: '',
          isFeatured: false,
          isActive: true,
        );

    showCustomerBookingDialog(
      context,
      experience: targetExp,
      selectedPackage: targetExp.dynamicPackages.first,
    );
  }

  void _onViewServiceDetails(BuildContext context, GalleryItem item, Experience? matchedExp) {
    Navigator.of(context).pop();
    if (matchedExp != null) {
      if (matchedExp.slug.isNotEmpty) {
        Get.toNamed('${AppRoutes.detail}/${matchedExp.slug}');
      } else {
        showExperienceDetailDialog(context, matchedExp);
      }
    } else {
      final fallbackExp = Experience(
        id: item.serviceId.isNotEmpty ? item.serviceId : 'gallery_${item.id}',
        categoryId: item.categoryId,
        categoryName: item.categoryName.isNotEmpty ? item.categoryName : 'Decor Theme',
        categorySlug: item.categoryName.toLowerCase().replaceAll(' ', '-'),
        name: item.title,
        slug: item.title.toLowerCase().replaceAll(' ', '-'),
        description: item.description,
        price: 15000,
        durationHours: 4,
        popularity: 10,
        rating: 5.0,
        reviewCount: 1,
        availability: 'available',
        tags: item.tags,
        colors: const [],
        themes: [item.title],
        imageUrl: item.imageUrl,
        videoUrl: '',
        isFeatured: false,
        isActive: true,
      );
      showExperienceDetailDialog(context, fallbackExp);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final item = widget.items[_currentIndex];
    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 900;
    final isTablet = screenW >= 600 && screenW < 900;

    Experience? matchedExp;
    if (Get.isRegistered<GalleryController>()) {
      matchedExp = GalleryController.to.findExperienceForGalleryItem(item);
    }

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _next();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _prev();
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 14,
          vertical: isDesktop ? 20 : 16,
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          width: isDesktop ? 880.0 : (isTablet ? (screenW * 0.90).clamp(580.0, 780.0) : double.infinity),
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
                  // 1. FIXED 16:9 MAIN IMAGE VIEWPORT (Identical size for all gallery items)
                  _buildMainImageSection(context, item),

                  // 2. FIXED 16:10 THUMBNAIL STRIP (Consistent height 62px)
                  _buildThumbnailStrip(),

                  // 3. INFORMATION SECTION (Deterministic height - zero modal reflow)
                  _buildInformationSection(context, item, matchedExp, isDesktop, isTablet),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 1. MAIN IMAGE SECTION ──────────────────────────────────────────────────
  Widget _buildMainImageSection(
    BuildContext context,
    GalleryItem item,
  ) {
    final isFav = _favoriteIds.contains(item.id);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: const Color(0xFF060D0A),
        child: Stack(
          fit: StackFit.expand,
          children: [
          // 1. Background Layer: Same image, BoxFit.cover, heavily blurred and darkened to fill the 16:9 stage
          Positioned.fill(
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.scale(
                    scale: 1.15, // Scales slightly to prevent blur falloff at stage edges
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                      child: AppImage(
                        url: item.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Darkening overlay so the foreground image has crisp contrast
                  Container(
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
          ),

          // 2. Foreground Image: Complete original decoration, 100% visible, BoxFit.contain, centered
          Center(
            child: InteractiveViewer(
              key: ValueKey(item.id),
              minScale: 1.0,
              maxScale: 4.0,
              clipBehavior: Clip.hardEdge,
              child: AppImage(
                url: item.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 3. Top Subtle Vignette Gradient for Controls Legibility (IgnorePointer so image interactions pass through)
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

          // 4. Top Left Pill: Counter (e.g. 1 / 27)
          Positioned(
            top: 14,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xCC091210),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _goldColor.withValues(alpha: 0.45),
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
                "${_currentIndex + 1} / ${widget.items.length}",
                style: AppTheme.sansBody(
                  fontSize: 11.5,
                  color: _goldColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),

          // 5. Top Right Action Buttons (Favorite, Share, Close)
          Positioned(
            top: 14,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Favorite Button
                _buildCircleIconButton(
                  icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  iconColor: isFav ? Colors.redAccent : _goldColor,
                  tooltip: isFav ? "Remove Favorite" : "Add to Favorites",
                  onTap: () => _toggleFavorite(item.id, item.title),
                ),
                const SizedBox(width: 8),

                // Share Button
                _buildCircleIconButton(
                  icon: Icons.share_outlined,
                  iconColor: Colors.white,
                  tooltip: "Share Photo",
                  onTap: () => _shareItem(item),
                ),
                const SizedBox(width: 8),

                // Close Button
                _buildCircleIconButton(
                  icon: Icons.close_rounded,
                  iconColor: Colors.white,
                  tooltip: "Close Viewer (Esc)",
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // 6. Navigation Arrows (Vertically Centered with Align)
          if (widget.items.length > 1)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _buildCircleNavButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: "Previous Photo (Left Arrow)",
                  onTap: _prev,
                ),
              ),
            ),

          if (widget.items.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCircleNavButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: "Next Photo (Right Arrow)",
                  onTap: _next,
                ),
              ),
            ),

          // 7. Bottom Right Expand / Zoom Button
          Positioned(
            bottom: 12,
            right: 14,
            child: _buildCircleIconButton(
              icon: Icons.fullscreen_rounded,
              iconColor: _goldColor,
              size: 32,
              iconSize: 18,
              tooltip: "Inspect Fullscreen",
              onTap: () => _openFullScreenViewer(context, item.imageUrl),
            ),
          ),
        ],
      ),
    ),
  );
}

  // ── 2. THUMBNAIL STRIP ─────────────────────────────────────────────────────
  Widget _buildThumbnailStrip() {
    if (widget.items.length <= 1) return const SizedBox.shrink();

    return Container(
      height: 62,
      color: const Color(0xFF060D0A),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        controller: _thumbScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          final thumbItem = widget.items[index];

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _selectIndex(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 72,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? _goldColor : Colors.white12,
                    width: isSelected ? 2.2 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _goldColor.withValues(alpha: 0.35),
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
                        if (thumbItem.tags.any((t) => t.toLowerCase().contains('video')))
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
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

  // ── 3. INFORMATION SECTION ─────────────────────────────────────────────────
  Widget _buildInformationSection(
    BuildContext context,
    GalleryItem item,
    Experience? matchedExp,
    bool isDesktop,
    bool isTablet,
  ) {
    if (isDesktop) {
      // 3-Column horizontal compact layout matching Reference (Fixed Height 156px)
      return Container(
        height: 156,
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Category, Title, Description
            Expanded(
              flex: 38,
              child: _buildTitleAndDescription(item),
            ),
            const SizedBox(width: 20),

            // Middle Column: Metadata
            Expanded(
              flex: 31,
              child: _buildMetadataColumn(item, matchedExp),
            ),
            const SizedBox(width: 20),

            // Right Column: Tags & Action CTAs
            Expanded(
              flex: 31,
              child: _buildActionsColumn(context, item, matchedExp),
            ),
          ],
        ),
      );
    } else if (isTablet) {
      // 2-Column layout on tablet
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleAndDescription(item),
                  const SizedBox(height: 12),
                  _buildMetadataColumn(item, matchedExp),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              flex: 45,
              child: _buildActionsColumn(context, item, matchedExp),
            ),
          ],
        ),
      );
    } else {
      // 1-Column vertical stacked layout on mobile
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleAndDescription(item),
            const SizedBox(height: 12),
            _buildMetadataColumn(item, matchedExp),
            const SizedBox(height: 12),
            _buildActionsColumn(context, item, matchedExp),
          ],
        ),
      );
    }
  }

  // Left Section: Category, Title, Description
  Widget _buildTitleAndDescription(GalleryItem item) {
    final categoryText = item.categoryName.isNotEmpty
        ? item.categoryName.toUpperCase()
        : 'CURATED THEME';

    final descriptionText = item.description.isNotEmpty
        ? item.description
        : "Private candle aisle, illuminated letters, florals and a sparkling reveal moment.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
          decoration: BoxDecoration(
            color: _goldColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _goldColor.withValues(alpha: 0.4),
              width: 0.9,
            ),
          ),
          child: Text(
            categoryText,
            style: AppTheme.sansBody(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: _goldColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Large Display Title (Locked Single Line, Fixed Height 28px)
        SizedBox(
          height: 28,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.italiana(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.4,
                height: 1.15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Concise Description (Locked 2 Lines, Fixed Height 36px)
        SizedBox(
          height: 36,
          child: Text(
            descriptionText,
            style: AppTheme.sansBody(
              fontSize: 11.5,
              color: Colors.white70,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Middle Section: Metadata Icons & Details
  Widget _buildMetadataColumn(GalleryItem item, Experience? matchedExp) {
    final themeText = (matchedExp != null && matchedExp.themes.isNotEmpty)
        ? matchedExp.themes.first
        : (item.title.isNotEmpty ? item.title : 'Premium Green & Gold');

    final dateStr = _formatDate(item.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetadataRow(
          icon: Icons.location_on_outlined,
          text: "Ahmedabad, Gujarat",
        ),
        const SizedBox(height: 6),
        _buildMetadataRow(
          icon: Icons.calendar_today_outlined,
          text: "Event Date: $dateStr",
        ),
        const SizedBox(height: 6),
        _buildMetadataRow(
          icon: Icons.groups_outlined,
          text: "Guests: 150+",
        ),
        const SizedBox(height: 6),
        _buildMetadataRow(
          icon: Icons.diamond_outlined,
          text: "Theme: $themeText",
        ),
      ],
    );
  }

  Widget _buildMetadataRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _goldColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.sansBody(
              fontSize: 11.5,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Right Section: Tags & Themes + Booking CTAs
  Widget _buildActionsColumn(
    BuildContext context,
    GalleryItem item,
    Experience? matchedExp,
  ) {
    final tags = item.tags.isNotEmpty
        ? item.tags
        : ['proposal', 'premium', 'customizable'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags Header
        Text(
          "TAGS & THEMES",
          style: AppTheme.sansBody(
            fontSize: 9.5,
            color: _goldColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),

        // Tag Pills (Fixed Height 22px Single Row)
        SizedBox(
          height: 22,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: tags.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final tag = tags[index];
              final cleanTag = tag.startsWith('#') ? tag : '#$tag';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF13221E),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white12),
                ),
                child: Center(
                  child: Text(
                    cleanTag,
                    style: AppTheme.sansBody(
                      fontSize: 9.5,
                      color: Colors.white70,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Primary Button: Book this Theme
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _goldColor,
              foregroundColor: const Color(0xFF091210),
              elevation: 2,
              shadowColor: _goldColor.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () => _onBookTheme(context, item, matchedExp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month_outlined, size: 14, color: Color(0xFF091210)),
                const SizedBox(width: 6),
                Text(
                  "BOOK THIS THEME",
                  style: AppTheme.sansBody(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: const Color(0xFF091210),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF091210)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Secondary Button: View Service Details
        SizedBox(
          width: double.infinity,
          height: 32,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: _goldColor,
              side: BorderSide(color: _goldColor.withValues(alpha: 0.65), width: 1.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () => _onViewServiceDetails(context, item, matchedExp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.north_east_rounded, size: 12),
                const SizedBox(width: 5),
                Text(
                  "VIEW SERVICE DETAILS",
                  style: AppTheme.sansBody(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: _goldColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper: Circle Icon Button for Top Controls
  Widget _buildCircleIconButton({
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
            child: Center(
              child: Icon(icon, color: iconColor, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }

  // Helper: Circle Nav Button for Previous / Next
  Widget _buildCircleNavButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
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
              border: Border.all(color: _goldColor.withValues(alpha: 0.55), width: 1.1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: _goldColor, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
