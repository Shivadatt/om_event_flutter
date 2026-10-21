import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../controllers/catalog_controller.dart';
import '../../../../../domain/entities/customer_wishlist.dart';
import '../../../../../domain/entities/experience.dart';

/// Wishlist / Inspiration Board items management view for customers.
/// Redesigned to match the compact luxury Option 1 reference design:
/// - Dashboard-style enclosed card with subtle gold border
/// - Compact header with gold label, Italiana typography, and quick divider
/// - Top toolbar: Search toggle/field, Grid/List view toggle, and Sort dropdown
/// - Responsive 3-column desktop grid (2 tablet, 1 mobile) with controlled aspect ratio
/// - Top-right dual overlay buttons (interactive Heart & Delete)
/// - Bottom metadata with Category, Italiana Title, and circular gold arrow action
class WishlistView extends StatefulWidget {
  final CustomerDashboardController controller;
  final VoidCallback? onExploreGallery;

  const WishlistView({
    super.key,
    required this.controller,
    this.onExploreGallery,
  });

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  bool _isGridView = true;
  String _currentSort = 'latest'; // 'latest', 'oldest', 'name_asc', 'name_desc'
  String _searchQuery = '';
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _darkCardBg = Color(0xFF131815);
  static const Color _darkBoardBg = Color(0xFF0C100E);
  static const Color _toolbarBg = Color(0xFF141A16);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToExperience(Experience? exp) {
    if (exp != null && exp.slug.isNotEmpty) {
      Get.toNamed('${AppRoutes.detail}/${exp.slug}');
    } else if (widget.onExploreGallery != null) {
      widget.onExploreGallery!();
    } else {
      Get.toNamed(AppRoutes.gallery);
    }
  }

  String _getSortLabel(String sortKey) {
    switch (sortKey) {
      case 'oldest':
        return 'Oldest Added';
      case 'name_asc':
        return 'Title (A–Z)';
      case 'name_desc':
        return 'Title (Z–A)';
      case 'latest':
      default:
        return 'Latest Added';
    }
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, String label) {
    final bool isSelected = _currentSort == value;
    return PopupMenuItem<String>(
      value: value,
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? _goldColor : Colors.white70,
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_rounded, size: 16, color: _goldColor),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogCtrl = Get.find<CatalogController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final bool isDesktop = availableWidth >= 1000;
        final bool isTablet = availableWidth >= 580 && availableWidth < 1000;
        final bool isMobile = availableWidth < 580;
        final bool isCompactMobile = availableWidth < 380;

        final double horizontalPadding = isDesktop ? 24 : (isTablet ? 20 : (isCompactMobile ? 10 : 14));
        final double verticalPadding = isDesktop ? 24 : 16;
        final double boardInnerPadding = isMobile ? (isCompactMobile ? 12 : 14) : 22;

        final double boardContentWidth = (availableWidth - (horizontalPadding * 2) - (boardInnerPadding * 2))
            .clamp(100.0, double.infinity);

        // Columns:
        // Desktop / wide laptop (>= 860px board content): 3 columns
        // Tablet / compact laptop (480px to 859px): 2 columns
        // Mobile / narrow (< 480px): 1 column
        final int crossAxisCount = boardContentWidth >= 860
            ? 3
            : (boardContentWidth >= 480 ? 2 : 1);

        const double gridSpacing = 16.0;
        final double cardWidth = (boardContentWidth - ((crossAxisCount - 1) * gridSpacing)) / crossAxisCount;

        // Image aspect ratio: ~1.55 on mobile, ~1.62 on desktop/tablet.
        // Footer: ~60px mobile, ~64px desktop.
        // Total card height = (cardWidth / targetImageRatio) + footerHeight.
        final double targetImageRatio = isMobile ? 1.55 : 1.62;
        final double footerHeight = isMobile ? 60.0 : 64.0;
        final double cardHeight = (cardWidth / targetImageRatio) + footerHeight;
        final double childAspectRatio = (cardWidth / cardHeight).clamp(0.6, 2.5);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(boardInnerPadding),
              decoration: BoxDecoration(
                color: _darkBoardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _goldColor.withValues(alpha: 0.24),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header & Toolbar Row ──────────────────────────────
                  _buildHeaderAndToolbar(
                    context,
                    isMobile: isMobile,
                    isCompactMobile: isCompactMobile,
                    boardContentWidth: boardContentWidth,
                  ),
                  const SizedBox(height: 14),

                  // ── Luxury Ornament Divider ──────────────────────────
                  _buildLuxuryDivider(),
                  const SizedBox(height: 20),

                  // ── Main Dynamic Wishlist Content ─────────────────────
                  Obx(() {
                    final allWishlist = widget.controller.rxWishlist.toList();

                    if (allWishlist.isEmpty) {
                      return _buildEmptyState(isSearchFiltered: false);
                    }

                    // ── Apply Search Query Filter ───────────────────────
                    final filteredWishlist = allWishlist.where((wish) {
                      if (_searchQuery.trim().isEmpty) return true;
                      final q = _searchQuery.toLowerCase().trim();
                      final exp = catalogCtrl.rxExperiences.firstWhereOrNull(
                        (e) => e.slug == wish.experienceId || e.id == wish.experienceId,
                      );
                      final title = (exp?.name ?? wish.experienceId).toLowerCase();
                      final category = (exp?.categoryName ?? "DECORATION").toLowerCase();
                      final themes = (exp?.themes ?? []).join(' ').toLowerCase();
                      final tags = (exp?.tags ?? []).join(' ').toLowerCase();
                      return title.contains(q) ||
                          category.contains(q) ||
                          themes.contains(q) ||
                          tags.contains(q);
                    }).toList();

                    if (filteredWishlist.isEmpty) {
                      return _buildEmptyState(isSearchFiltered: true);
                    }

                    // ── Apply Sorting ──────────────────────────────────
                    filteredWishlist.sort((a, b) {
                      switch (_currentSort) {
                        case 'oldest':
                          return a.addedAt.compareTo(b.addedAt);
                        case 'name_asc':
                          final titleA = (catalogCtrl.rxExperiences.firstWhereOrNull((e) => e.slug == a.experienceId || e.id == a.experienceId)?.name ?? a.experienceId).toLowerCase();
                          final titleB = (catalogCtrl.rxExperiences.firstWhereOrNull((e) => e.slug == b.experienceId || e.id == b.experienceId)?.name ?? b.experienceId).toLowerCase();
                          return titleA.compareTo(titleB);
                        case 'name_desc':
                          final titleA = (catalogCtrl.rxExperiences.firstWhereOrNull((e) => e.slug == a.experienceId || e.id == a.experienceId)?.name ?? a.experienceId).toLowerCase();
                          final titleB = (catalogCtrl.rxExperiences.firstWhereOrNull((e) => e.slug == b.experienceId || e.id == b.experienceId)?.name ?? b.experienceId).toLowerCase();
                          return titleB.compareTo(titleA);
                        case 'latest':
                        default:
                          return b.addedAt.compareTo(a.addedAt);
                      }
                    });

                    if (_isGridView) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: gridSpacing,
                          mainAxisSpacing: gridSpacing,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: filteredWishlist.length,
                        itemBuilder: (context, index) {
                          final wish = filteredWishlist[index];
                          final exp = catalogCtrl.rxExperiences.firstWhereOrNull(
                            (e) => e.slug == wish.experienceId || e.id == wish.experienceId,
                          );
                          final title = exp?.name ?? wish.experienceId;
                          final category = exp?.categoryName ?? "DECORATION";
                          final imageUrl = exp?.imageUrl ?? "";

                          return _buildGridCard(
                            wish,
                            exp,
                            title,
                            category,
                            imageUrl,
                            isMobile: isMobile,
                          );
                        },
                      );
                    } else {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredWishlist.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final wish = filteredWishlist[index];
                          final exp = catalogCtrl.rxExperiences.firstWhereOrNull(
                            (e) => e.slug == wish.experienceId || e.id == wish.experienceId,
                          );
                          final title = exp?.name ?? wish.experienceId;
                          final category = exp?.categoryName ?? "DECORATION";
                          final imageUrl = exp?.imageUrl ?? "";

                          return _buildListCard(
                            wish,
                            exp,
                            title,
                            category,
                            imageUrl,
                            isMobile: isMobile,
                            isCompactMobile: isCompactMobile,
                          );
                        },
                      );
                    }
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header & Toolbar ──────────────────────────────────────────────
  Widget _buildHeaderAndToolbar(
    BuildContext context, {
    required bool isMobile,
    required bool isCompactMobile,
    required double boardContentWidth,
  }) {
    // When boardContentWidth is spacious (>= 620px), place header and toolbar in one row
    if (boardContentWidth >= 620) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "MY FAVORITES",
                  style: GoogleFonts.dmSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _goldColor,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Inspiration Board",
                  style: GoogleFonts.italiana(
                    fontSize: boardContentWidth >= 900 ? 30 : 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          _buildToolbar(
            context,
            isMobile: false,
            isCompactMobile: false,
            boardContentWidth: boardContentWidth,
          ),
        ],
      );
    } else {
      // In smaller viewports, stack heading and toolbar cleanly
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "MY FAVORITES",
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _goldColor,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            "Inspiration Board",
            style: GoogleFonts.italiana(
              fontSize: isCompactMobile ? 22 : 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildToolbar(
            context,
            isMobile: true,
            isCompactMobile: isCompactMobile,
            boardContentWidth: boardContentWidth,
          ),
        ],
      );
    }
  }

  // ── Toolbar Controls (Search, Grid/List, Sort) ──────────────────────
  Widget _buildToolbar(
    BuildContext context, {
    required bool isMobile,
    required bool isCompactMobile,
    required double boardContentWidth,
  }) {
    final bool isSearchActive = _isSearchOpen || _searchQuery.isNotEmpty;

    // On mobile screens with active search, make the search box full width on row 1,
    // and place the toggles on row 2 without breaking Wrap constraints
    if (isMobile && isSearchActive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchWidget(isMobile: true, fullWidth: true),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildGridListToggle(),
              const SizedBox(width: 8),
              _buildSortDropdown(isCompact: isCompactMobile),
            ],
          ),
        ],
      );
    }

    return Wrap(
      spacing: isCompactMobile ? 8 : 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildSearchWidget(
          isMobile: isMobile,
          fullWidth: false,
          compactWidth: boardContentWidth < 700 ? 170 : 200,
        ),
        _buildGridListToggle(),
        _buildSortDropdown(isCompact: isCompactMobile),
      ],
    );
  }

  // ── Search Widget ─────────────────────────────────────────────────
  Widget _buildSearchWidget({
    required bool isMobile,
    bool fullWidth = false,
    double compactWidth = 200,
  }) {
    if (_isSearchOpen || _searchQuery.isNotEmpty) {
      return Container(
        height: 36,
        width: fullWidth ? double.infinity : compactWidth,
        decoration: BoxDecoration(
          color: _toolbarBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _goldColor.withValues(alpha: 0.55), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 16, color: _goldColor),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                cursorColor: _goldColor,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Search favorites...",
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            InkWell(
              onTap: () {
                _searchController.clear();
                if (mounted) {
                  setState(() {
                    _searchQuery = '';
                    _isSearchOpen = false;
                  });
                }
              },
              child: const Icon(Icons.close_rounded, size: 16, color: Colors.white60),
            ),
          ],
        ),
      );
    }

    return Tooltip(
      message: 'Search favorites',
      child: InkWell(
        onTap: () {
          if (mounted) setState(() => _isSearchOpen = true);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _toolbarBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: _goldColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.search_rounded,
            size: 17,
            color: _goldColor,
          ),
        ),
      ),
    );
  }

  // ── Grid / List View Toggle ───────────────────────────────────────
  Widget _buildGridListToggle() {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _toolbarBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _goldColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Grid View',
            child: InkWell(
              onTap: () {
                if (!_isGridView && mounted) setState(() => _isGridView = true);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _isGridView ? _goldColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  size: 15,
                  color: _isGridView ? const Color(0xFF091210) : _goldColor.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 3),
          Tooltip(
            message: 'List View',
            child: InkWell(
              onTap: () {
                if (_isGridView && mounted) setState(() => _isGridView = false);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: !_isGridView ? _goldColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.format_list_bulleted_rounded,
                  size: 16,
                  color: !_isGridView ? const Color(0xFF091210) : _goldColor.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sort Dropdown Menu ────────────────────────────────────────────
  Widget _buildSortDropdown({bool isCompact = false}) {
    return PopupMenuButton<String>(
      tooltip: 'Sort favorites',
      offset: const Offset(0, 42),
      color: const Color(0xFF141A16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _goldColor.withValues(alpha: 0.4), width: 1),
      ),
      onSelected: (val) {
        if (mounted) setState(() => _currentSort = val);
      },
      itemBuilder: (context) => [
        _buildPopupMenuItem('latest', 'Latest Added'),
        _buildPopupMenuItem('oldest', 'Oldest Added'),
        _buildPopupMenuItem('name_asc', 'Title (A–Z)'),
        _buildPopupMenuItem('name_desc', 'Title (Z–A)'),
      ],
      child: Container(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
        decoration: BoxDecoration(
          color: _toolbarBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _goldColor.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getSortLabel(_currentSort),
              style: TextStyle(
                fontSize: isCompact ? 11.5 : 12,
                fontWeight: FontWeight.w600,
                color: _goldColor,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: _goldColor,
            ),
          ],
        ),
      ),
    );
  }

  // ── Luxury Ornament Divider ───────────────────────────────────────
  Widget _buildLuxuryDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _goldColor.withValues(alpha: 0.4),
                  _goldColor.withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: _goldColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Transform.rotate(
                angle: 0.785398, // 45 deg diamond
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _goldColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: _goldColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _goldColor.withValues(alpha: 0.15),
                  _goldColor.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Grid Card ─────────────────────────────────────────────────────
  Widget _buildGridCard(
    CustomerWishlist wish,
    Experience? exp,
    String title,
    String category,
    String imageUrl, {
    required bool isMobile,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _darkCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _goldColor.withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _navigateToExperience(exp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Controlled Top Image with Overlays ──────────────
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: imageUrl.isNotEmpty
                          ? AppImage(
                              url: imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: const Color(0xFF1B231F),
                              child: const Center(
                                child: Icon(Icons.image_outlined, color: Colors.white24, size: 36),
                              ),
                            ),
                    ),
                    // Subtle bottom fade gradient to merge smoothly with card footer
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                _darkCardBg.withValues(alpha: 0.85),
                              ],
                              stops: const [0.0, 0.65, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Top-right dual overlay buttons: Heart & Delete
                    Positioned(
                      top: isMobile ? 8 : 10,
                      right: isMobile ? 8 : 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildOverlayCircleButton(
                            icon: Icons.favorite,
                            iconColor: _goldColor,
                            tooltip: 'Wishlist Item',
                            size: isMobile ? 28 : 32,
                            iconSize: isMobile ? 14 : 16,
                            onTap: () => widget.controller.removeWishlist(wish.id),
                          ),
                          SizedBox(width: isMobile ? 6 : 8),
                          _buildOverlayCircleButton(
                            icon: Icons.delete_outline_rounded,
                            iconColor: _goldColor,
                            tooltip: 'Remove',
                            size: isMobile ? 28 : 32,
                            iconSize: isMobile ? 14 : 16,
                            onTap: () => widget.controller.removeWishlist(wish.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Compact Card Footer ─────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 16,
                  isMobile ? 8 : 10,
                  isMobile ? 12 : 14,
                  isMobile ? 10 : 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: isMobile ? 8.5 : 9.5,
                              fontWeight: FontWeight.w700,
                              color: _goldColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.italiana(
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Gold circular right arrow action
                    Container(
                      width: isMobile ? 28 : 32,
                      height: isMobile ? 28 : 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _goldColor, width: 1.2),
                        color: Colors.black26,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: isMobile ? 14 : 16,
                        color: _goldColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── List Card ─────────────────────────────────────────────────────
  Widget _buildListCard(
    CustomerWishlist wish,
    Experience? exp,
    String title,
    String category,
    String imageUrl, {
    required bool isMobile,
    required bool isCompactMobile,
  }) {
    if (isMobile) {
      // Mobile-friendly List Card with stacked actions
      return Container(
        height: 110,
        decoration: BoxDecoration(
          color: _darkCardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _goldColor.withValues(alpha: 0.22),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _navigateToExperience(exp),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                  child: SizedBox(
                    width: isCompactMobile ? 90 : 105,
                    height: double.infinity,
                    child: imageUrl.isNotEmpty
                        ? AppImage(url: imageUrl, fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFF1B231F),
                            child: const Center(
                              child: Icon(Icons.image_outlined, color: Colors.white24, size: 26),
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: _goldColor,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.italiana(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildOverlayCircleButton(
                              icon: Icons.favorite,
                              iconColor: _goldColor,
                              tooltip: 'Wishlist Item',
                              size: 26,
                              iconSize: 13,
                              onTap: () => widget.controller.removeWishlist(wish.id),
                            ),
                            const SizedBox(width: 6),
                            _buildOverlayCircleButton(
                              icon: Icons.delete_outline_rounded,
                              iconColor: _goldColor,
                              tooltip: 'Remove',
                              size: 26,
                              iconSize: 13,
                              onTap: () => widget.controller.removeWishlist(wish.id),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: _goldColor, width: 1.1),
                                color: Colors.black26,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: _goldColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: _darkCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _goldColor.withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _navigateToExperience(exp),
          child: Row(
            children: [
              // Left Image
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                child: SizedBox(
                  width: 140,
                  height: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? AppImage(url: imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFF1B231F),
                          child: const Center(
                            child: Icon(Icons.image_outlined, color: Colors.white24, size: 28),
                          ),
                        ),
                ),
              ),

              // Middle Metadata
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: _goldColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.italiana(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right Actions
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOverlayCircleButton(
                      icon: Icons.favorite,
                      iconColor: _goldColor,
                      tooltip: 'Wishlist Item',
                      onTap: () => widget.controller.removeWishlist(wish.id),
                    ),
                    const SizedBox(width: 8),
                    _buildOverlayCircleButton(
                      icon: Icons.delete_outline_rounded,
                      iconColor: _goldColor,
                      tooltip: 'Remove',
                      onTap: () => widget.controller.removeWishlist(wish.id),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _goldColor, width: 1.2),
                        color: Colors.black26,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: _goldColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Overlay Circular Action Button (Heart / Delete) ───────────────
  Widget _buildOverlayCircleButton({
    required IconData icon,
    required Color iconColor,
    required String tooltip,
    required VoidCallback onTap,
    double size = 32,
    double iconSize = 16,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.65),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────
  Widget _buildEmptyState({required bool isSearchFiltered}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _toolbarBg,
              border: Border.all(color: _goldColor.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _goldColor.withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isSearchFiltered ? Icons.search_off_rounded : Icons.favorite_border_rounded,
              size: 30,
              color: _goldColor,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isSearchFiltered ? "No Matching Inspiration Found" : "Your Inspiration Board is empty.",
            textAlign: TextAlign.center,
            style: GoogleFonts.italiana(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearchFiltered
                ? "No saved favorites match '$_searchQuery'. Try a different keyword."
                : "Save themes and decorations you love from the Event Gallery.",
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          if (isSearchFiltered)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldColor,
                foregroundColor: const Color(0xFF091210),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text(
                "Clear Search",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _isSearchOpen = false;
                });
              },
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldColor,
                foregroundColor: const Color(0xFF091210),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text(
                "Explore Gallery",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
              ),
              onPressed: () {
                if (widget.onExploreGallery != null) {
                  widget.onExploreGallery!();
                } else {
                  Get.toNamed(AppRoutes.gallery);
                }
              },
            ),
        ],
      ),
    );
  }
}
