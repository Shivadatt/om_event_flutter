import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../widgets/app_page_container.dart';
import '../../../controllers/gallery_controller.dart';
import '../../../controllers/catalog_controller.dart';
import '../widgets/booking_tracker_dialog.dart';
import 'widgets/gallery_lightbox_dialog.dart';

/// Redesigned Public Gallery Screen matching the reference design:
/// - Compact, cinematic dark emerald + champagne gold aesthetics
/// - Atmospheric golden curve trails in Hero background
/// - Centered search pill with gold submit arrow
/// - Circular category filter row with horizontal scrolling & desktop arrow buttons
/// - Responsive 4-column Grid for gallery cards (4 desktop, 2 tablet, 1 mobile)
class PublicGalleryScreen extends StatefulWidget {
  const PublicGalleryScreen({super.key});

  @override
  State<PublicGalleryScreen> createState() => _PublicGalleryScreenState();
}

class _PublicGalleryScreenState extends State<PublicGalleryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _categoryScrollCtrl = ScrollController();
  late final GalleryController _controller;

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _darkBgColor = Color(0xFF08110E);
  static const Color _headerBgColor = Color(0xF2091411);

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<GalleryController>()
        ? Get.find<GalleryController>()
        : Get.put(GalleryController());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _categoryScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;
    final isTablet = width >= 650 && width < 1000;
    final hPad = AppPageContainer.horizontalPadding(context);

    return Scaffold(
      backgroundColor: _darkBgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. COMPACT LUXURY HEADER ──────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: _headerBgColor,
            elevation: 0,
            toolbarHeight: 64,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: _goldColor.withValues(alpha: 0.12),
              ),
            ),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: _headerBgColor,
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: AppPageContainer.maxContentWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Back button + OE Logo + Title block
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white70),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              tooltip: "Back",
                              onPressed: () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  Get.offAllNamed(AppRoutes.home);
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            // Circular OE Brand Emblem
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: _goldColor, width: 1.2),
                                gradient: RadialGradient(
                                  colors: [
                                    _goldColor.withValues(alpha: 0.22),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "OE",
                                  style: GoogleFonts.italiana(
                                    fontSize: 12,
                                    color: _goldColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Brand Title & Eyebrow Subtitle
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "PORTFOLIO GALLERY",
                                  style: GoogleFonts.italiana(
                                    fontSize: isDesktop ? 17 : 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "EXPERIENCES CRAFTED WITH PASSION",
                                  style: AppTheme.sansBody(
                                    fontSize: isDesktop ? 8.5 : 7.5,
                                    fontWeight: FontWeight.w600,
                                    color: _goldColor.withValues(alpha: 0.85),
                                    letterSpacing: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Right: Actions (Service Area & Track Booking)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (width >= 560) ...[
                              TextButton.icon(
                                icon: const Icon(Icons.travel_explore_outlined, size: 15, color: _goldColor),
                                label: Text(
                                  "SERVICE AREA",
                                  style: AppTheme.sansBody(
                                    fontSize: 11,
                                    color: _goldColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                onPressed: () => Get.toNamed(AppRoutes.serviceArea),
                              ),
                              const SizedBox(width: 12),
                              TextButton.icon(
                                icon: const Icon(Icons.track_changes_rounded, size: 15, color: Colors.white70),
                                label: Text(
                                  "TRACK BOOKING",
                                  style: AppTheme.sansBody(
                                    fontSize: 11,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                onPressed: () => showBookingTrackerDialog(context),
                              ),
                            ] else ...[
                              IconButton(
                                icon: const Icon(Icons.travel_explore_outlined, size: 18, color: _goldColor),
                                tooltip: "Service Area",
                                onPressed: () => Get.toNamed(AppRoutes.serviceArea),
                              ),
                              IconButton(
                                icon: const Icon(Icons.track_changes_rounded, size: 18, color: Colors.white70),
                                tooltip: "Track Booking",
                                onPressed: () => showBookingTrackerDialog(context),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 2. HERO / STUDIO PORTFOLIO + SEARCH + CATEGORY FILTER ─────────
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Atmospheric Golden Ribbon Trails
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AtmosphericGoldenSwirlPainter(),
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: AppPageContainer.maxContentWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),

                          // Small Gold Eyebrow
                          Text(
                            "STUDIO PORTFOLIO",
                            style: AppTheme.sansBody(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: _goldColor,
                              letterSpacing: 3.5,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Large Elegant Heading
                          Text(
                            "Curated Moments of Grandeur & Artistry",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.italiana(
                              fontSize: isDesktop ? 34 : (isTablet ? 28 : 22),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Short Description
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 680),
                            child: Text(
                              "Explore our real-world event installations across Gujarat — from opulent weddings and magnificent receptions to whimsical birthdays and bespoke stage decor.",
                              textAlign: TextAlign.center,
                              style: AppTheme.sansBody(
                                fontSize: isDesktop ? 13 : 12,
                                color: Colors.white60,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── SEARCH BAR PILL ───────────────────────────────
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0E1C18),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: _goldColor.withValues(alpha: 0.38),
                                  width: 1.1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Icon(Icons.search_rounded, color: _goldColor, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchCtrl,
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                      cursorColor: _goldColor,
                                      onChanged: (val) => _controller.setSearchQuery(val),
                                      onSubmitted: (val) => _controller.setSearchQuery(val),
                                      decoration: const InputDecoration(
                                        hintText: "Search themes (e.g., Royal Wedding, Stage, Floral, Pastel)...",
                                        hintStyle: TextStyle(color: Colors.white38, fontSize: 12.5),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  // Clear button if searching
                                  Obx(() {
                                    if (_controller.rxSearchQuery.value.isNotEmpty) {
                                      return IconButton(
                                        icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        onPressed: () {
                                          _searchCtrl.clear();
                                          _controller.clearSearch();
                                        },
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }),
                                  const SizedBox(width: 4),
                                  // Circular Gold Submit Action Pill Button
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: InkWell(
                                      onTap: () => _controller.setSearchQuery(_searchCtrl.text),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _goldColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x40D4AF37),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                            color: Color(0xFF08110E),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── CIRCULAR CATEGORY FILTER ROW ──────────────────
                          Obx(() {
                            final categories = _controller.rxCategories;
                            final activeCat = _controller.rxSelectedCategory.value;
                            final allItems = _controller.rxGalleryItems;

                            return Container(
                              constraints: BoxConstraints(maxWidth: AppPageContainer.maxContentWidth),
                              child: Row(
                                children: [
                                  // Desktop Left Scroll Arrow
                                  if (isDesktop) ...[
                                    _buildScrollArrow(
                                      icon: Icons.chevron_left_rounded,
                                      onTap: () {
                                        _categoryScrollCtrl.animateTo(
                                          (_categoryScrollCtrl.offset - 260).clamp(0.0, _categoryScrollCtrl.position.maxScrollExtent),
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeOutCubic,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                  ],

                                  // Scrollable Category Item Row
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: _categoryScrollCtrl,
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: categories.map((cat) {
                                          final isSelected = activeCat.toUpperCase() == cat.toUpperCase();
                                          final isAll = cat.toUpperCase() == 'ALL';
                                          final imageUrl = isAll ? '' : _getCategoryImageUrl(cat, allItems);
                                          final displayLabel = _formatCategoryLabel(cat);

                                          return _buildCategoryCircleItem(
                                            label: displayLabel,
                                            isSelected: isSelected,
                                            isAll: isAll,
                                            imageUrl: imageUrl,
                                            onTap: () => _controller.setCategory(cat),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),

                                  // Desktop Right Scroll Arrow
                                  if (isDesktop) ...[
                                    const SizedBox(width: 8),
                                    _buildScrollArrow(
                                      icon: Icons.chevron_right_rounded,
                                      onTap: () {
                                        _categoryScrollCtrl.animateTo(
                                          (_categoryScrollCtrl.offset + 260).clamp(0.0, _categoryScrollCtrl.position.maxScrollExtent),
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeOutCubic,
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 3. RESPONSIVE GALLERY CARDS GRID (NEVER HORIZONTAL) ───────────
          Obx(() {
            if (_controller.rxIsLoading.value && _controller.rxGalleryItems.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: _goldColor),
                ),
              );
            }

            final items = _controller.filteredItems;

            if (items.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 56, color: _goldColor.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          "No celebration photos match your criteria",
                          style: GoogleFonts.italiana(fontSize: 20, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try searching for another keyword or switch category filters.",
                          style: AppTheme.sansBody(fontSize: 12, color: Colors.white38),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text("RESET ALL FILTERS"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _goldColor,
                            side: const BorderSide(color: _goldColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            _searchCtrl.clear();
                            _controller.resetFilters();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Strict responsive column layout:
            // Desktop (>= 1000px): 4 columns
            // Tablet (650px - 999px): 2 columns
            // Mobile (< 650px): 1 column
            final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);
            final childAspectRatio = isDesktop ? 1.12 : (isTablet ? 1.22 : 1.32);

            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: AppPageContainer.maxContentWidth),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _GalleryCard(
                          item: item,
                          onTap: () => showGalleryLightbox(
                            context,
                            items: items,
                            initialIndex: index,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          }),

          // Footer spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 60),
          ),
        ],
      ),
    );
  }

  // ── HELPERS: Category Image, Label Formatting & Scroll Arrows ─────────────

  String _getCategoryImageUrl(String catName, List<dynamic> allItems) {
    if (Get.isRegistered<CatalogController>()) {
      final catalog = Get.find<CatalogController>();
      final matchedCat = catalog.rxCategories.firstWhereOrNull(
        (c) => c.name.trim().toLowerCase() == catName.trim().toLowerCase(),
      );
      if (matchedCat != null && matchedCat.imageUrl.isNotEmpty) {
        return matchedCat.imageUrl;
      }
    }
    final matchedItem = allItems.firstWhereOrNull(
      (i) => i.categoryName.trim().toLowerCase() == catName.trim().toLowerCase() && i.imageUrl.isNotEmpty,
    );
    if (matchedItem != null) return matchedItem.imageUrl;
    return '';
  }

  String _formatCategoryLabel(String raw) {
    if (raw.toUpperCase() == 'ALL') return 'ALL';
    final words = raw.split(' ').where((w) => w.isNotEmpty).map((w) {
      if (w.length <= 1) return w.toUpperCase();
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).toList();

    if (words.length <= 1) return words.first;
    if (words.length == 2) return '${words[0]}\n${words[1]}';
    if (words.contains('&')) {
      final idx = words.indexOf('&');
      final firstPart = words.sublist(0, idx + 1).join(' ');
      final secondPart = words.sublist(idx + 1).join(' ');
      return '$firstPart\n$secondPart';
    }
    final mid = (words.length / 2).ceil();
    return '${words.sublist(0, mid).join(' ')}\n${words.sublist(mid).join(' ')}';
  }

  Widget _buildScrollArrow({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF101E1A),
            border: Border.all(color: _goldColor.withValues(alpha: 0.35), width: 1.0),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(icon, color: _goldColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildCategoryCircleItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? imageUrl,
    bool isAll = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        hoverColor: Colors.transparent,
        splashColor: _goldColor.withValues(alpha: 0.15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _goldColor : _goldColor.withValues(alpha: 0.3),
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _goldColor.withValues(alpha: 0.45),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : [
                        const BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: ClipOval(
                child: isAll
                    ? Container(
                        color: isSelected ? const Color(0xFF152621) : const Color(0xFF0F1B18),
                        child: Center(
                          child: Icon(
                            Icons.grid_view_rounded,
                            size: 22,
                            color: isSelected ? _goldColor : Colors.white70,
                          ),
                        ),
                      )
                    : (imageUrl != null && imageUrl.isNotEmpty)
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              AppImage(url: imageUrl, fit: BoxFit.cover),
                              Container(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.black.withValues(alpha: 0.25),
                              ),
                            ],
                          )
                        : Container(
                            color: const Color(0xFF12221E),
                            child: Icon(
                              Icons.celebration_outlined,
                              size: 22,
                              color: isSelected ? _goldColor : Colors.white60,
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 78,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.sansBody(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? _goldColor : Colors.white70,
                  height: 1.15,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 4. GALLERY CARD (MATCHING REFERENCE IMAGE 1) ───────────────────────────

class _GalleryCard extends StatefulWidget {
  final dynamic item;
  final VoidCallback onTap;

  const _GalleryCard({required this.item, required this.onTap});

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
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
          transform: _isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: const Color(0xFF101E1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? _goldColor : _goldColor.withValues(alpha: 0.22),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? _goldColor.withValues(alpha: 0.22) : Colors.black45,
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full Cover Image
                AppImage(
                  url: item.imageUrl,
                  fit: BoxFit.cover,
                ),

                // Top Vignette Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        stops: const [0.0, 0.4],
                      ),
                    ),
                  ),
                ),

                // Bottom Rich Vignette Gradient for Typography & Action Button
                Positioned.fill(
                  child: Container(
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

                // Top-Left Category Badge Pill
                if (item.categoryName.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xD908110E),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _goldColor.withValues(alpha: 0.45), width: 0.9),
                      ),
                      child: Text(
                        item.categoryName.toUpperCase(),
                        style: AppTheme.sansBody(
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                          color: _goldColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),

                // Top-Right Favorite / Wishlist Button Pill
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () {
                      setState(() => _isFavorite = !_isFavorite);
                    },
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
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 15,
                          color: _isFavorite ? _goldColor : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Content Bar: Title + Description on left, Circular Gold Button on right
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Title & Subtitle/Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.italiana(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                            if (item.description.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                item.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.sansBody(
                                  fontSize: 10.5,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Circular Gold Action Button (Arrow ->)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _goldColor,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33D4AF37),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: Color(0xFF08110E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 5. ATMOSPHERIC GOLDEN SWIRL PAINTER ────────────────────────────────────

class _AtmosphericGoldenSwirlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const goldColor = Color(0xFFD4AF37);

    // Soft Ambient Top-Right Radial Glow
    final glowPaintRight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.75, -0.7),
        radius: 0.9,
        colors: [
          goldColor.withValues(alpha: 0.08),
          goldColor.withValues(alpha: 0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaintRight);

    // Soft Ambient Bottom-Left Radial Glow
    final glowPaintLeft = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.85, 0.3),
        radius: 0.8,
        colors: [
          goldColor.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaintLeft);

    // Delicate Golden Fluid Ribbon Path 1
    final strokePaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          goldColor.withValues(alpha: 0.22),
          goldColor.withValues(alpha: 0.35),
          goldColor.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.22, 0.52, 0.82, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path1 = Path();
    path1.moveTo(-60, size.height * 0.28);
    path1.cubicTo(
      size.width * 0.28, size.height * 0.75,
      size.width * 0.68, size.height * -0.15,
      size.width + 60, size.height * 0.42,
    );
    canvas.drawPath(path1, strokePaint1);

    // Delicate Golden Fluid Ribbon Path 2
    final strokePaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          goldColor.withValues(alpha: 0.12),
          goldColor.withValues(alpha: 0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path2 = Path();
    path2.moveTo(-40, size.height * 0.58);
    path2.cubicTo(
      size.width * 0.32, size.height * 0.88,
      size.width * 0.78, size.height * 0.12,
      size.width + 50, size.height * 0.62,
    );
    canvas.drawPath(path2, strokePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
