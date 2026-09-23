import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../controllers/gallery_controller.dart';
import '../widgets/booking_tracker_dialog.dart';
import 'widgets/gallery_lightbox_dialog.dart';

class PublicGalleryScreen extends StatefulWidget {
  const PublicGalleryScreen({super.key});

  @override
  State<PublicGalleryScreen> createState() => _PublicGalleryScreenState();
}

class _PublicGalleryScreenState extends State<PublicGalleryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late final GalleryController _controller;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final goldColor = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFF091210),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF0F1B18).withValues(alpha: 0.95),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white70),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Get.offAllNamed(AppRoutes.home);
                }
              },
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: goldColor, width: 1.2),
                    gradient: LinearGradient(
                      colors: [goldColor.withValues(alpha: 0.2), Colors.transparent],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "OE",
                      style: GoogleFonts.italiana(fontSize: 12, color: goldColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "PORTFOLIO GALLERY",
                  style: GoogleFonts.italiana(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                icon: Icon(Icons.travel_explore_outlined, size: 16, color: goldColor),
                label: Text(
                  "SERVICE AREA",
                  style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.bold),
                ),
                onPressed: () => Get.toNamed(AppRoutes.serviceArea),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.track_changes_rounded, size: 16, color: Colors.white70),
                label: Text(
                  "TRACK BOOKING",
                  style: AppTheme.sansBody(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                onPressed: () => showBookingTrackerDialog(context),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Hero Intro Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 20,
                vertical: isDesktop ? 40 : 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1B18), Color(0xFF091210)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "STUDIO PORTFOLIO",
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: goldColor,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Curated Moments of Grandeur & Artistry",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.italiana(
                      fontSize: isDesktop ? 36 : 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Text(
                      "Explore our real-world event installations across Gujarat — from opulent weddings and magnificent receptions to whimsical birthdays and bespoke stage decor.",
                      textAlign: TextAlign.center,
                      style: AppTheme.sansBody(
                        fontSize: 13.5,
                        color: Colors.white60,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Search Box
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      cursorColor: goldColor,
                      onChanged: (val) => controller.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: "Search themes (e.g., Royal Wedding, Stage, Floral, Pastel)...",
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: goldColor, size: 20),
                        suffixIcon: Obx(() {
                          if (controller.rxSearchQuery.value.isNotEmpty) {
                            return IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                controller.clearSearch();
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        filled: true,
                        fillColor: const Color(0xFF152621),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: goldColor.withValues(alpha: 0.25)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: goldColor, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Filters
                  Obx(() {
                    final categories = controller.rxCategories;
                    final activeCat = controller.rxSelectedCategory.value;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: categories.map((cat) {
                          final isSelected = activeCat == cat;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ChoiceChip(
                              label: Text(
                                cat,
                                style: AppTheme.sansBody(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? const Color(0xFF091210) : goldColor,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: goldColor,
                              backgroundColor: const Color(0xFF152621),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? goldColor : goldColor.withValues(alpha: 0.3),
                                ),
                              ),
                              onSelected: (_) => controller.setCategory(cat),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Gallery Grid Section
          Obx(() {
            if (controller.rxIsLoading.value && controller.rxGalleryItems.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                ),
              );
            }

            final items = controller.filteredItems;

            if (items.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 56, color: goldColor.withValues(alpha: 0.4)),
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
                            foregroundColor: goldColor,
                            side: BorderSide(color: goldColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            _searchCtrl.clear();
                            controller.resetFilters();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Calculate responsive crossAxisCount
            final screenWidth = MediaQuery.of(context).size.width;
            final crossAxisCount = screenWidth >= 1200
                ? 4
                : screenWidth >= 800
                    ? 3
                    : screenWidth >= 550
                        ? 2
                        : 1;

            return SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 16,
                vertical: 24,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
                  childCount: items.length,
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
}

class _GalleryCard extends StatefulWidget {
  final dynamic item;
  final VoidCallback onTap;

  const _GalleryCard({required this.item, required this.onTap});

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);
    final item = widget.item;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: _isHovered ? Matrix4.translationValues(0, -5, 0) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: const Color(0xFF152621),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? goldColor : goldColor.withValues(alpha: 0.18),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? goldColor.withValues(alpha: 0.2) : Colors.black45,
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
                // Image
                AppImage(
                  url: item.imageUrl,
                  fit: BoxFit.cover,
                ),

                // Gradient Overlay for Title
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.92),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Top Category Pill
                if (item.categoryName.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xCC091210),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: goldColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        item.categoryName.toUpperCase(),
                        style: AppTheme.sansBody(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                // Hover Inspection Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: goldColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fullscreen, size: 16, color: Color(0xFF091210)),
                    ),
                  ),
                ),

                // Bottom Content
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.italiana(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
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
