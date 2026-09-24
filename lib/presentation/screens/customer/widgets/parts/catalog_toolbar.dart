part of '../home_catalog_section.dart';

extension _CatalogToolbarExtension on ExperiencesCatalogSection {
  Widget _buildChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return _ToolbarChip(label: label, isActive: isActive, onTap: onTap);
  }

  Widget _buildToolbar({
    required BuildContext context,
    required bool isDark,
    required double width,
    required double titleSize,
    required bool isWide,
  }) {
    final headingWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "CURATED EXPERIENCES",
          style: AppTheme.sansBody(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.8,
            color: AppColors.primaryAccent,
          ),
        ),
        const SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Colors.white, Color(0xFFE6C55A), Color(0xFFD4AF37)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            "TRANSFORMING\nMOMENTS INTO\nLASTING MEMORIES.",
            style: GoogleFonts.italiana(
              fontSize: isWide ? 28.0 : 23.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.15,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Explore signature concepts, see an honest starting price, then tune every color, material and detail.",
          style: AppTheme.sansBody(
            fontSize: 13,
            color: AppColors.muted,
            height: 1.5,
          ),
        ),
      ],
    );

    final double videoBannerHeight = isWide ? 190.0 : 160.0;
    final videoBanner = _CatalogHeroVideoBanner(height: videoBannerHeight);

    final heroRow = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: headingWidget),
              const SizedBox(width: 20),
              Expanded(flex: 5, child: videoBanner),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headingWidget,
              const SizedBox(height: 14),
              videoBanner,
            ],
          );

    final searchWidget = Container(
      height: 38,
      width: isWide ? 260 : double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2D27).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: 15,
            color: AppColors.secondaryAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (val) => controller.updateSearchQuery(val),
              style: AppTheme.sansBody(
                fontSize: 12.5,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Search a mood, theme or event…",
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 12.5,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );

    final sortWidget = Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2D27).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.sortBy.value,
            dropdownColor: const Color(0xFF1B2D27),
            icon: const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 15,
                color: AppColors.secondaryAccent,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'popular', child: Text("MOST LOVED")),
              DropdownMenuItem(value: 'latest', child: Text("LATEST")),
              DropdownMenuItem(
                value: 'price_low',
                child: Text("PRICE: LOW TO HIGH"),
              ),
              DropdownMenuItem(
                value: 'price_high',
                child: Text("PRICE: HIGH TO LOW"),
              ),
            ],
            onChanged: (val) {
              if (val != null) controller.updateSort(val);
            },
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );

    final chipsWidget = SizedBox(
      height: 38,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Obx(() {
              final isActive = controller.selectedCategorySlug.value.isEmpty;
              return _buildChip(
                label: "All",
                isActive: isActive,
                onTap: () => controller.selectCategory(''),
                isDark: isDark,
              );
            }),
            const SizedBox(width: 8),
            Obx(
              () => Row(
                children: controller.rxCategories.map((cat) {
                  final isActive = controller.selectedCategorySlug.value == cat.slug;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildChip(
                      label: cat.name.replaceFirst(" Celebrations", ""),
                      isActive: isActive,
                      onTap: () => controller.selectCategory(cat.slug),
                      isDark: isDark,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );

    final toolbar = isWide
        ? Row(
            children: [
              searchWidget,
              const SizedBox(width: 14),
              Expanded(child: chipsWidget),
              const SizedBox(width: 12),
              sortWidget,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: searchWidget),
                  const SizedBox(width: 10),
                  sortWidget,
                ],
              ),
              const SizedBox(height: 12),
              chipsWidget,
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heroRow,
        const SizedBox(height: 18),
        toolbar,
      ],
    );
  }
}

class _CatalogHeroVideoBanner extends StatefulWidget {
  final double height;
  const _CatalogHeroVideoBanner({required this.height});

  @override
  State<_CatalogHeroVideoBanner> createState() => _CatalogHeroVideoBannerState();
}

class _CatalogHeroVideoBannerState extends State<_CatalogHeroVideoBanner> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  static const String _videoUrl =
      'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/gallery/Video/balloon_blast_hero_section_video.mp4';
  static const String _posterUrl =
      'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/gallery/images/balloon_blast_thumbnail.png';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(_videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0.0);
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (_) {}
  }

  void _togglePlay() {
    if (!_isInitialized || _controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() => _isPlaying = false);
    } else {
      _controller!.play();
      setState(() => _isPlaying = true);
    }
  }

  void _onHover(bool hover) {
    if (!_isInitialized || _controller == null) return;
    if (hover) {
      _controller!.play();
      setState(() => _isPlaying = true);
    } else {
      _controller!.pause();
      setState(() => _isPlaying = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: _togglePlay,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondaryAccent.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Fallback poster image
                Image.network(
                  _posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF152621)),
                ),

                // Video player
                if (_isInitialized && _controller != null)
                  AnimatedOpacity(
                    opacity: _isPlaying ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width > 0
                            ? _controller!.value.size.width
                            : 1280,
                        height: _controller!.value.size.height > 0
                            ? _controller!.value.size.height
                            : 720,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),

                // Subtle dark vignette gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),

                // Center Play Button & "Watch Our Decoration Video"
                AnimatedOpacity(
                  opacity: _isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.55),
                            border: Border.all(
                              color: AppColors.secondaryAccent.withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryAccent.withValues(alpha: 0.25),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 26,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Watch Our Decoration Video",
                          style: AppTheme.sansBody(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
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

class _ToolbarChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ToolbarChip> createState() => _ToolbarChipState();
}

class _ToolbarChipState extends State<_ToolbarChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeGradient = const LinearGradient(
      colors: [AppColors.highlight, AppColors.secondaryAccent, AppColors.primaryAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: widget.isActive ? activeGradient : null,
            color: widget.isActive ? null : const Color(0xFF14241F).withValues(alpha: 0.5),
            border: Border.all(
              color: widget.isActive
                  ? Colors.transparent
                  : (_isHovered ? AppColors.primaryAccent : AppColors.primaryAccent.withValues(alpha: 0.2)),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.isActive && _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primaryAccent.withValues(alpha: 0.25),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: AppTheme.sansBody(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: widget.isActive ? const Color(0xFF0F1B18) : AppColors.muted,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
