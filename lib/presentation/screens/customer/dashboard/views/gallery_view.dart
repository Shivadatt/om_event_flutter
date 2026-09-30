import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../controllers/catalog_controller.dart';
import '../../../../../domain/entities/experience.dart';
import '../../../../../core/utils/asset_downloader.dart';

/// Customer/Client Lounge "Event Gallery" View.
/// Restructured to match the modern Option 2 reference design:
/// - Compact 2-column desktop gallery grid (1 column on mobile)
/// - Proportional 16:9 landscape image cards
/// - Floating luxury bottom overlay bar with icon, title, category, and photo count
/// - Dynamic category filters with theme icons
/// - Responsive layout for desktop (sidebar-docked) and mobile
class GalleryView extends StatefulWidget {
  final CustomerDashboardController controller;

  const GalleryView({
    super.key,
    required this.controller,
  });

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  String selectedFilter = 'ALL';

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _darkBg = Color(0xFF070E0B);

  @override
  Widget build(BuildContext context) {
    final catalogCtrl = Get.find<CatalogController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 640;

    return Obx(() {
      final availableFilters = _getAvailableFilters(catalogCtrl);

      final experiences = catalogCtrl.rxExperiences.where((exp) {
        if (selectedFilter == 'ALL') return true;
        final f = selectedFilter.toLowerCase();
        final c = exp.categoryName.toLowerCase();
        final id = exp.categoryId.toLowerCase();
        return c.contains(f) || id.contains(f) || f.contains(c);
      }).toList();

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. Page Header & Category Filters ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 24,
                isMobile ? 16 : 24,
                isMobile ? 16 : 24,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isMobile, experiences),
                  const SizedBox(height: 20),
                  _buildCategoryFilters(availableFilters),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── 2. Gallery Grid (2 Columns Desktop/Tablet, 1 Column Mobile) ────
          if (experiences.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 48,
                        color: _goldColor.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "No event gallery collections found for this category.",
                        style: AppTheme.sansBody(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 24,
                0,
                isMobile ? 16 : 24,
                32,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 16 / 9,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exp = experiences[index];
                    return _buildGalleryCard(context, exp, isMobile);
                  },
                  childCount: experiences.length,
                ),
              ),
            ),
        ],
      );
    });
  }

  // ── Header (Title, Subtitle, Description & Download Button) ────────────────
  Widget _buildHeader(BuildContext context, bool isMobile, List<Experience> experiences) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "STUDIO PORTFOLIO",
            style: AppTheme.sansBody(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: _goldColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Luxury Event Gallery",
            style: GoogleFonts.italiana(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "High-quality event setups, curated by our expert designers at OM Events & Decorators.",
            style: AppTheme.sansBody(
              fontSize: 11.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text("Download All Assets"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldColor,
                foregroundColor: const Color(0xFF091210),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
                elevation: 0,
              ),
              onPressed: () => _handleDownloadAll(experiences),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "STUDIO PORTFOLIO",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _goldColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Luxury Event Gallery",
                style: GoogleFonts.italiana(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "High-quality event setups, curated by our expert designers at OM Events & Decorators.",
                style: AppTheme.sansBody(
                  fontSize: 12.5,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.download_rounded, size: 16),
          label: const Text("Download All Assets"),
          style: ElevatedButton.styleFrom(
            backgroundColor: _goldColor,
            foregroundColor: const Color(0xFF091210),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
            elevation: 0,
          ),
          onPressed: () => _handleDownloadAll(experiences),
        ),
      ],
    );
  }

  // ── Category Filters Row with Matching Icons ──────────────────────────────
  Widget _buildCategoryFilters(List<String> categories) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = categories[index];
          final isActive = selectedFilter == filter;
          final icon = _getCategoryIcon(filter);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => selectedFilter = filter),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? _goldColor : const Color(0xFF101914),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? _goldColor : _goldColor.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isActive ? const Color(0xFF091210) : _goldColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatFilterLabel(filter),
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive ? const Color(0xFF091210) : _goldColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Gallery Card (16:9 Landscape with Floating Overlay Pill) ───────────────
  Widget _buildGalleryCard(BuildContext context, Experience exp, bool isMobile) {
    final alignment = _getThemeImageAlignment(exp.name, exp.categoryName, exp.imageUrl);
    final photoCount = _getPhotoCountString(exp);

    return Container(
      decoration: BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _goldColor.withValues(alpha: 0.2),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Full-bleed background image with intelligent focal framing & Card Tap Navigation ──
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (exp.slug.isNotEmpty) {
                    Get.toNamed('${AppRoutes.detail}/${exp.slug}');
                  } else {
                    Get.snackbar("Event Gallery", "Viewing ${exp.name} collection.");
                  }
                },
                child: exp.imageUrl.isNotEmpty
                    ? (exp.imageUrl.startsWith('assets/')
                        ? Image.asset(
                            exp.imageUrl,
                            fit: BoxFit.cover,
                            alignment: alignment,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF101914),
                              child: const Icon(Icons.celebration, color: _goldColor, size: 32),
                            ),
                          )
                        : AppImage(
                            url: exp.imageUrl,
                            fit: BoxFit.cover,
                            alignment: alignment,
                          ))
                    : Container(
                        color: const Color(0xFF101914),
                        child: const Icon(Icons.image_outlined, color: Colors.white24, size: 36),
                      ),
              ),
            ),
          ),

          // ── 2. Cinematic luxury gradient overlay for text readability ──
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── 3. Top-Right Action Buttons (Download Asset & Wishlist Favorite) ──
          Positioned(
            top: 10,
            right: 10,
            child: Obx(() {
              final isFavorite = widget.controller.isExperienceInWishlist(exp.slug, exp.id);

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Single Asset Download Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (exp.imageUrl.isNotEmpty) {
                          final fileName = AssetDownloader.resolveFileName(
                            exp.imageUrl,
                            fallbackTitle: exp.name,
                          );
                          Get.snackbar(
                            "Download Started",
                            "Downloading $fileName...",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF171411),
                            colorText: _goldColor,
                            duration: const Duration(seconds: 2),
                          );
                          await AssetDownloader.download(
                            exp.imageUrl,
                            fileName: fileName,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(17),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.65),
                          border: Border.all(
                            color: _goldColor.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.download_rounded,
                            size: 16,
                            color: _goldColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Wishlist Favorite Heart Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await widget.controller.toggleWishlist(exp, context: context);
                      },
                      borderRadius: BorderRadius.circular(17),
                      child: AnimatedScale(
                        scale: isFavorite ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFavorite
                                ? _goldColor.withValues(alpha: 0.28)
                                : Colors.black.withValues(alpha: 0.65),
                            border: Border.all(
                              color: _goldColor.withValues(alpha: isFavorite ? 0.85 : 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 16,
                              color: _goldColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),

          // ── 4. Bottom Modern Floating Bar ──
          Positioned(
            left: isMobile ? 8 : 12,
            right: isMobile ? 8 : 12,
            bottom: isMobile ? 8 : 12,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (exp.slug.isNotEmpty) {
                    Get.toNamed('${AppRoutes.detail}/${exp.slug}');
                  } else {
                    Get.snackbar("Event Gallery", "Viewing ${exp.name} collection.");
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 12,
                    vertical: isMobile ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070E0B).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Gold Icon Box
                      Container(
                        width: isMobile ? 30 : 34,
                        height: isMobile ? 30 : 34,
                        decoration: BoxDecoration(
                          color: _goldColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _goldColor.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.photo_library_outlined,
                            size: isMobile ? 15 : 17,
                            color: _goldColor,
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 10),

                      // Title + Category & Photos
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              exp.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.sansBody(
                                fontSize: isMobile ? 11.5 : 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${exp.categoryName.isNotEmpty ? exp.categoryName : 'Portfolio'} • $photoCount",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.sansBody(
                                fontSize: isMobile ? 9.5 : 10.5,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Gold Circle Forward Action Button
                      Container(
                        width: isMobile ? 26 : 28,
                        height: isMobile ? 26 : 28,
                        decoration: const BoxDecoration(
                          color: _goldColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: isMobile ? 11 : 12,
                            color: const Color(0xFF091210),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: Dynamic Filter List ───────────────────────────────────────────
  List<String> _getAvailableFilters(CatalogController catalogCtrl) {
    final Set<String> filters = {'ALL'};
    if (catalogCtrl.rxCategories.isNotEmpty) {
      for (var cat in catalogCtrl.rxCategories) {
        if (cat.name.trim().isNotEmpty) {
          filters.add(cat.name.trim().toUpperCase());
        }
      }
    } else if (catalogCtrl.rxExperiences.isNotEmpty) {
      for (var exp in catalogCtrl.rxExperiences) {
        if (exp.categoryName.trim().isNotEmpty) {
          filters.add(exp.categoryName.trim().toUpperCase());
        }
      }
    } else {
      filters.addAll(['WEDDINGS', 'BIRTHDAYS', 'RECEPTIONS']);
    }
    return filters.toList();
  }

  // ── Helper: Category Icons ────────────────────────────────────────────────
  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower == 'all') return Icons.grid_view_rounded;
    if (lower.contains('wedding')) return Icons.favorite_outline_rounded;
    if (lower.contains('birthday')) return Icons.cake_outlined;
    if (lower.contains('reception')) return Icons.celebration_outlined;
    if (lower.contains('baby')) return Icons.child_friendly_outlined;
    if (lower.contains('balloon')) return Icons.bubble_chart_outlined;
    if (lower.contains('pujan') || lower.contains('cultural')) return Icons.temple_hindu_outlined;
    return Icons.auto_awesome_outlined;
  }

  // ── Helper: Format Filter Label ───────────────────────────────────────────
  String _formatFilterLabel(String filter) {
    if (filter.toUpperCase() == 'ALL') return 'All';
    return filter.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // ── Helper: Intelligent Focal Alignment ───────────────────────────────────
  Alignment _getThemeImageAlignment(String title, String category, String imageUrl) {
    final key = "${title.toLowerCase()} ${category.toLowerCase()} ${imageUrl.toLowerCase()}";
    if (key.contains("chhath") || key.contains("pujan") || key.contains("chhathhi")) {
      return const Alignment(0.0, -0.2);
    }
    if (key.contains("birthday")) {
      return const Alignment(0.0, -0.1);
    }
    return Alignment.center;
  }

  // ── Helper: Photo Count String ────────────────────────────────────────────
  String _getPhotoCountString(Experience exp) {
    final count = (exp.popularity > 0
            ? exp.popularity * 15
            : (exp.reviewCount > 0 ? exp.reviewCount * 12 : 60))
        .clamp(40, 150);
    return "$count+ Photos";
  }

  // ── Action: Download All Assets ───────────────────────────────────────────
  Future<void> _handleDownloadAll([List<Experience>? experiences]) async {
    final list = experiences?.where((e) => e.imageUrl.trim().isNotEmpty).toList() ?? [];
    if (list.isEmpty) {
      Get.snackbar(
        "No Assets",
        "No gallery assets available to download.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF171411),
        colorText: _goldColor,
      );
      return;
    }

    Get.snackbar(
      "Downloading Assets",
      "Starting download for ${list.length} high-resolution event setup assets...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF171411),
      colorText: _goldColor,
      duration: const Duration(seconds: 3),
    );

    for (int i = 0; i < list.length; i++) {
      final exp = list[i];
      final fileName = AssetDownloader.resolveFileName(
        exp.imageUrl,
        fallbackTitle: exp.name,
      );
      await AssetDownloader.download(
        exp.imageUrl,
        fileName: fileName,
      );
      if (i < list.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }
}
