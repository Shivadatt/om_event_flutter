import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/utils/app_logger.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/domain/entities/settings_entities.dart';
import 'package:om_event/presentation/widgets/app_page_container.dart';

class VideoStoriesSection extends StatefulWidget {
  final GlobalKey storiesKey;
  final bool isDesktop;
  final GlobalKey catalogKey;

  const VideoStoriesSection({
    super.key,
    required this.storiesKey,
    required this.isDesktop,
    required this.catalogKey,
  });

  @override
  State<VideoStoriesSection> createState() => _VideoStoriesSectionState();
}

class _VideoStoriesSectionState extends State<VideoStoriesSection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1200;
    final bool isLaptop = screenWidth >= 1024 && screenWidth < 1200;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isMobile = screenWidth < 600;
    final bool isTwoColumn = screenWidth >= 1024;

    final double sectionPaddingVertical = isDesktop
        ? 40.0
        : (isLaptop ? 32.0 : (isTablet ? 28.0 : 20.0));

    final EdgeInsets cardPadding = isDesktop
        ? const EdgeInsets.all(36.0)
        : (isLaptop
            ? const EdgeInsets.symmetric(horizontal: 28.0, vertical: 26.0)
            : (isTablet
                ? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0)
                : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0)));

    return Container(
      key: widget.storiesKey,
      width: double.infinity,
      color: const Color(0xFF152621), // Secondary Background matching home page
      padding: EdgeInsets.symmetric(
        horizontal: AppPageContainer.horizontalPadding(context),
        vertical: sectionPaddingVertical,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppPageContainer.maxContentWidth),
          child: Obx(() {
            final videoSettings = AppConfigService.to.rxVideoSettings.value;
            final defaultList = VideoSettings.defaultVal().videosList;
            final rawList = videoSettings.videosList.isNotEmpty
                ? videoSettings.videosList
                : defaultList;

            // Audit and deduplicate videos by videoAsset URL/path
            final seenUrls = <String>{};
            final List<dynamic> activeList = [];
            for (final item in rawList) {
              final map = Map<String, dynamic>.from(item);
              final url = (map['videoAsset'] ?? '').toString().trim();
              if (url.isNotEmpty && !seenUrls.contains(url)) {
                seenUrls.add(url);
                activeList.add(item);
              }
              if (activeList.length == 3) break;
            }

            // If fewer than 3 unique videos found, backfill from defaults without introducing duplicates
            if (activeList.length < 3) {
              for (final defItem in defaultList) {
                final map = Map<String, dynamic>.from(defItem);
                final url = (map['videoAsset'] ?? '').toString().trim();
                if (url.isNotEmpty && !seenUrls.contains(url)) {
                  seenUrls.add(url);
                  activeList.add(defItem);
                }
                if (activeList.length == 3) break;
              }
            }

            if (activeList.isEmpty) {
              return const SizedBox.shrink();
            }

            final clampedIndex = _selectedIndex.clamp(0, activeList.length - 1);
            final activeItem = Map<String, dynamic>.from(activeList[clampedIndex]);

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF091613), // Deep luxury dark emerald
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.secondaryAccent.withValues(alpha: 0.4),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: AppColors.secondaryAccent.withValues(alpha: 0.05),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Subtle ambient golden glows
                  Positioned(
                    top: -60,
                    left: -60,
                    child: IgnorePointer(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.secondaryAccent.withValues(alpha: 0.09),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    right: -50,
                    child: IgnorePointer(
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.secondaryAccent.withValues(alpha: 0.07),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Golden dot matrix accent: Desktop/Laptop (upper left-center)
                  if (isTwoColumn)
                    Positioned(
                      top: 36,
                      left: isDesktop ? 300 : 250,
                      child: IgnorePointer(
                        child: _DotMatrixAccent(
                          rows: 4,
                          cols: 4,
                          color: AppColors.secondaryAccent.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                  // Golden dot matrix accents: Tablet (both top-left and top-right matching reference)
                  if (isTablet) ...[
                    Positioned(
                      top: 24,
                      left: 28,
                      child: IgnorePointer(
                        child: _DotMatrixAccent(
                          rows: 4,
                          cols: 4,
                          color: AppColors.secondaryAccent.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 24,
                      right: 28,
                      child: IgnorePointer(
                        child: _DotMatrixAccent(
                          rows: 4,
                          cols: 4,
                          color: AppColors.secondaryAccent.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                  ],
                  // Main Content Layout
                  Padding(
                    padding: cardPadding,
                    child: isTwoColumn
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left content (~42% desktop, ~48% laptop)
                              Expanded(
                                flex: isDesktop ? 9 : 10,
                                child: _buildLeftContent(
                                  activeItem: activeItem,
                                  isDesktop: isDesktop,
                                  isLaptop: isLaptop,
                                ),
                              ),
                              SizedBox(width: isDesktop ? 36 : 24),
                              // Right video + 3 thumbnails (~58% desktop, ~52% laptop)
                              Expanded(
                                flex: isDesktop ? 12 : 11,
                                child: _buildRightVideoContent(
                                  activeItem: activeItem,
                                  activeList: activeList,
                                  selectedIndex: clampedIndex,
                                  isDesktop: true,
                                  isMobile: false,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Brand logo (centered)
                              _buildBrandLogo(isCentered: true),
                              SizedBox(height: isTablet ? 16 : 12),
                              // Eyebrow label (centered)
                              _buildEyebrow(textAlign: TextAlign.center),
                              SizedBox(height: isTablet ? 8 : 6),
                              // Editorial heading (centered)
                              _buildHeading(
                                isDesktop: false,
                                isLaptop: false,
                                isTablet: isTablet,
                                isMobile: isMobile,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: isTablet ? 12 : 10),
                              // Description (centered with clean line wrapping)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isTablet ? 580 : double.infinity,
                                ),
                                child: _buildDescription(
                                  activeItem: activeItem,
                                  isDesktop: false,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: isTablet ? 22 : 16),
                              // 3 Highlights (centered row matching tablet/mobile reference)
                              _buildHighlights(
                                activeItem: activeItem,
                                isTwoColumn: false,
                                isTablet: isTablet,
                                isMobile: isMobile,
                              ),
                              SizedBox(height: isTablet ? 24 : 18),
                              // CTA Button (centered on tablet, prominent on mobile)
                              _buildCtaButton(
                                isFullWidth: isMobile,
                                isCentered: true,
                              ),
                              SizedBox(height: isTablet ? 28 : 22),
                              // Main Video Player + 3 Thumbnails below CTA!
                              _buildRightVideoContent(
                                activeItem: activeItem,
                                activeList: activeList,
                                selectedIndex: clampedIndex,
                                isDesktop: false,
                                isMobile: isMobile,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── LEFT COLUMN FULL (DESKTOP / LAPTOP) ────────────────────────────────────
  Widget _buildLeftContent({
    required Map<String, dynamic> activeItem,
    required bool isDesktop,
    required bool isLaptop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBrandLogo(isCentered: false),
        SizedBox(height: isDesktop ? 18 : 14),
        _buildEyebrow(textAlign: TextAlign.start),
        SizedBox(height: isDesktop ? 8 : 6),
        _buildHeading(
          isDesktop: isDesktop,
          isLaptop: isLaptop,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: isDesktop ? 14 : 10),
        _buildDescription(
          activeItem: activeItem,
          isDesktop: isDesktop,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: isDesktop ? 22 : 16),
        _buildHighlights(
          activeItem: activeItem,
          isTwoColumn: true,
        ),
        SizedBox(height: isDesktop ? 26 : 20),
        _buildCtaButton(isFullWidth: false, isCentered: false),
      ],
    );
  }

  // ── BRAND LOGO ─────────────────────────────────────────────────────────────
  Widget _buildBrandLogo({bool isCentered = false}) {
    final logoWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.secondaryAccent.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondaryAccent,
                width: 1.5,
              ),
              gradient: RadialGradient(
                colors: [
                  AppColors.secondaryAccent.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              "OE",
              style: GoogleFonts.italiana(
                fontSize: 14,
                color: AppColors.secondaryAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "OM EVENTS",
              style: GoogleFonts.italiana(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryAccent,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "AND DECORATORS",
              style: AppTheme.sansBody(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryAccent.withValues(alpha: 0.85),
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
      ],
    );

    if (isCentered) {
      return Center(child: logoWidget);
    }
    return logoWidget;
  }

  // ── EYEBROW ────────────────────────────────────────────────────────────────
  Widget _buildEyebrow({TextAlign textAlign = TextAlign.start}) {
    return Text(
      "LIVE FROM THE SETUP",
      textAlign: textAlign,
      style: AppTheme.sansBody(
        fontSize: 10,
        color: AppColors.secondaryAccent, // Champagne Gold
        fontWeight: FontWeight.bold,
        letterSpacing: 2.2,
      ),
    );
  }

  // ── EDITORIAL HEADING ──────────────────────────────────────────────────────
  Widget _buildHeading({
    required bool isDesktop,
    bool isLaptop = false,
    bool isTablet = false,
    bool isMobile = false,
    TextAlign textAlign = TextAlign.start,
  }) {
    final double fontSize = isDesktop
        ? 33.0
        : (isLaptop ? 28.0 : (isTablet ? 27.0 : 22.0));

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: GoogleFonts.italiana(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.w400,
          height: 1.05,
          letterSpacing: 0.5,
        ),
        children: [
          const TextSpan(text: "REAL MOMENTS\n"),
          TextSpan(
            text: "BEAUTIFUL\nCELEBRATIONS.",
            style: GoogleFonts.italiana(
              color: AppColors.secondaryAccent, // Champagne Gold
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── DESCRIPTION ────────────────────────────────────────────────────────────
  Widget _buildDescription({
    required Map<String, dynamic> activeItem,
    required bool isDesktop,
    TextAlign textAlign = TextAlign.start,
  }) {
    final text = (activeItem['description'] != null &&
            activeItem['description'].toString().isNotEmpty)
        ? activeItem['description'].toString()
        : "From decor setups to grand entries, every detail is crafted with love and perfection. Watch behind the scenes and see how we create unforgettable events.";

    return Text(
      text,
      textAlign: textAlign,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.sansBody(
        fontSize: isDesktop ? 13.0 : 12.0,
        color: AppColors.muted,
        height: 1.55,
      ),
    );
  }

  // ── 3 HIGHLIGHTS ───────────────────────────────────────────────────────────
  Widget _buildHighlights({
    required Map<String, dynamic> activeItem,
    required bool isTwoColumn,
    bool isTablet = false,
    bool isMobile = false,
  }) {
    final List<String> rawFacts = List<String>.from(activeItem['facts'] ?? []);

    final String fact1 = rawFacts.isNotEmpty ? rawFacts[0] : "Decor Setup Walk";
    final String fact2 = rawFacts.length > 1 ? rawFacts[1] : "Premium Venue Styling";
    final String fact3 = rawFacts.length > 2 ? rawFacts[2] : "Quality Inspection";

    final highlights = [
      _HighlightData(
        icon: Icons.shopping_bag_outlined,
        line1: _splitFact(fact1)[0],
        line2: _splitFact(fact1)[1],
      ),
      _HighlightData(
        icon: Icons.storefront_outlined,
        line1: _splitFact(fact2)[0],
        line2: _splitFact(fact2)[1],
      ),
      _HighlightData(
        icon: Icons.verified_outlined,
        line1: _splitFact(fact3)[0],
        line2: _splitFact(fact3)[1],
      ),
    ];

    Widget buildItem(_HighlightData h, {required bool isCentered}) {
      return Column(
        crossAxisAlignment:
            isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10231E),
              border: Border.all(
                color: AppColors.secondaryAccent.withValues(alpha: 0.65),
                width: 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              h.icon,
              size: isMobile ? 15 : 17,
              color: AppColors.secondaryAccent,
            ),
          ),
          SizedBox(height: isMobile ? 5 : 7),
          Text(
            h.line1,
            textAlign: isCentered ? TextAlign.center : TextAlign.start,
            style: AppTheme.sansBody(
              fontSize: isMobile ? 9.5 : 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          Text(
            h.line2,
            textAlign: isCentered ? TextAlign.center : TextAlign.start,
            style: AppTheme.sansBody(
              fontSize: isMobile ? 9.5 : 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.15,
            ),
          ),
        ],
      );
    }

    if (isTwoColumn) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: highlights.map((h) => buildItem(h, isCentered: false)).toList(),
      );
    }

    if (isTablet) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildItem(highlights[0], isCentered: true),
          const SizedBox(width: 48),
          buildItem(highlights[1], isCentered: true),
          const SizedBox(width: 48),
          buildItem(highlights[2], isCentered: true),
        ],
      );
    }

    // Mobile: evenly distributed in a compact horizontal row
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: highlights.map((h) => buildItem(h, isCentered: true)).toList(),
    );
  }

  List<String> _splitFact(String fact) {
    if (fact.toLowerCase().contains("walk") || fact.toLowerCase().contains("decor")) {
      return ["Decor", "Setup Walk"];
    }
    if (fact.toLowerCase().contains("venue") || fact.toLowerCase().contains("hotel") || fact.toLowerCase().contains("styling")) {
      return ["Premium", "Venue Styling"];
    }
    if (fact.toLowerCase().contains("inspection") || fact.toLowerCase().contains("quality")) {
      return ["Quality", "Inspection"];
    }
    final words = fact.split(' ');
    if (words.length <= 1) return [fact, ""];
    if (words.length == 2) return [words[0], words[1]];
    return [words[0], words.sublist(1).join(' ')];
  }

  // ── CTA BUTTON ─────────────────────────────────────────────────────────────
  Widget _buildCtaButton({bool isFullWidth = false, bool isCentered = false}) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final ctx = widget.catalogKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        },
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.secondaryAccent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryAccent.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "EXPLORE DESIGN COLLECTION",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F1B18),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: Color(0xFF0F1B18),
              ),
            ],
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Center(child: button),
      );
    }
    if (isCentered) {
      return Center(child: button);
    }
    return button;
  }

  // ── RIGHT VIDEO CONTENT (FEATURED VIDEO + 3 THUMBNAILS) ────────────────────
  Widget _buildRightVideoContent({
    required Map<String, dynamic> activeItem,
    required List<dynamic> activeList,
    required int selectedIndex,
    required bool isDesktop,
    required bool isMobile,
  }) {
    final videoAsset = activeItem['videoAsset'] ?? '';
    final posterAsset = activeItem['posterAsset'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Featured Video
        _FeaturedVideoPlayer(
          key: ValueKey("video_$videoAsset"),
          videoAsset: videoAsset,
          posterAsset: posterAsset,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: 14),
        // 3-Thumbnails Strip
        _ThumbnailStrip(
          items: activeList,
          selectedIndex: selectedIndex,
          onSelect: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          isMobile: isMobile,
        ),
      ],
    );
  }
}

class _HighlightData {
  final IconData icon;
  final String line1;
  final String line2;

  const _HighlightData({
    required this.icon,
    required this.line1,
    required this.line2,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// FEATURED VIDEO PLAYER
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturedVideoPlayer extends StatefulWidget {
  final String videoAsset;
  final String posterAsset;
  final bool isDesktop;

  const _FeaturedVideoPlayer({
    super.key,
    required this.videoAsset,
    required this.posterAsset,
    required this.isDesktop,
  });

  @override
  State<_FeaturedVideoPlayer> createState() => _FeaturedVideoPlayerState();
}

class _FeaturedVideoPlayerState extends State<_FeaturedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isHovered = false;
  bool _hasStarted = false;
  bool _isMuted = true;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Video initialized on demand (hover on desktop or tap on mobile)
  }

  @override
  void didUpdateWidget(covariant _FeaturedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoAsset != widget.videoAsset) {
      _disposeController();
      _isInitialized = false;
      _isLoading = false;
      _isPlaying = false;
      _hasStarted = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    }
  }

  void _disposeController() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
      _controller = null;
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    final pos = _controller!.value.position;
    final dur = _controller!.value.duration;
    final playing = _controller!.value.isPlaying;
    if (pos != _position || dur != _duration || playing != _isPlaying) {
      setState(() {
        _position = pos;
        _duration = dur;
        _isPlaying = playing;
      });
    }
  }

  Future<void> _initController() async {
    if (_controller != null || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (widget.videoAsset.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoAsset),
        );
      } else {
        _controller = VideoPlayerController.asset(widget.videoAsset);
      }
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      _controller!.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _duration = _controller!.value.duration;
        });
      }
    } catch (e) {
      AppLogger.error("Error initializing featured video", e);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (!_isInitialized) {
      await _initController();
    }
    if (_controller == null || !_isInitialized) return;

    if (_isPlaying) {
      await _controller!.pause();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      await _controller!.play();
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _hasStarted = true;
        });
      }
    }
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) async {
        if (!widget.isDesktop) return;
        setState(() => _isHovered = true);
        if (!_isInitialized) {
          await _initController();
        }
        if (_isInitialized && !_isPlaying && _controller != null) {
          await _controller!.play();
          if (mounted) {
            setState(() {
              _isPlaying = true;
              _hasStarted = true;
            });
          }
        }
      },
      onExit: (_) {
        if (!widget.isDesktop) return;
        setState(() => _isHovered = false);
        if (_isInitialized && _isPlaying && _controller != null) {
          _controller!.pause();
          if (mounted) {
            setState(() => _isPlaying = false);
          }
        }
      },
      child: GestureDetector(
        onTap: _togglePlay,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondaryAccent.withValues(alpha: 0.65),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.secondaryAccent.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                // Video player or Poster image
                Positioned.fill(
                  child: _isInitialized && _hasStarted && _controller != null
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.size.width > 0
                                ? _controller!.value.size.width
                                : 1600,
                            height: _controller!.value.size.height > 0
                                ? _controller!.value.size.height
                                : 1000,
                            child: VideoPlayer(_controller!),
                          ),
                        )
                      : (widget.posterAsset.startsWith('http')
                          ? Image.network(
                              widget.posterAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF13221E),
                                child: const Icon(
                                  Icons.movie_creation_outlined,
                                  color: AppColors.secondaryAccent,
                                  size: 40,
                                ),
                              ),
                            )
                          : Image.asset(
                              widget.posterAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF13221E),
                                child: const Icon(
                                  Icons.movie_creation_outlined,
                                  color: AppColors.secondaryAccent,
                                  size: 40,
                                ),
                              ),
                            )),
                ),
                // Top Left Sample HD badge
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1B18).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.secondaryAccent.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      "SAMPLE EVENT FILM · HD",
                      style: AppTheme.sansBody(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                // Loading indicator in center if buffering/initializing
                if (_isLoading)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F1B18).withValues(alpha: 0.75),
                      ),
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondaryAccent,
                        ),
                      ),
                    ),
                  ),
                // Bottom player controls bar matching Image 2
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    opacity: (_isHovered || _isPlaying || !widget.isDesktop) ? 1.0 : 0.75,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                            Colors.black.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Thin progress track
                          if (_isInitialized && _duration > Duration.zero)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final progress = (_position.inMilliseconds /
                                          _duration.inMilliseconds)
                                      .clamp(0.0, 1.0);
                                  return Container(
                                    width: double.infinity,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: constraints.maxWidth * progress,
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryAccent,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          Row(
                            children: [
                              Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${_formatDuration(_position)} / ${_duration > Duration.zero ? _formatDuration(_duration) : '0:45'}",
                                style: AppTheme.sansBody(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _toggleMute,
                                child: Icon(
                                  _isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.settings_outlined,
                                color: Colors.white70,
                                size: 15,
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.fullscreen_rounded,
                                color: Colors.white70,
                                size: 17,
                              ),
                            ],
                          ),
                        ],
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// THUMBNAILS STRIP (EXACTLY 3 THUMBNAILS NATURALLY DISTRIBUTED)
// ─────────────────────────────────────────────────────────────────────────────
class _ThumbnailStrip extends StatelessWidget {
  final List<dynamic> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isMobile;

  const _ThumbnailStrip({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final gap = isMobile ? 8.0 : 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Distribute all 3 thumbnails evenly when at least 230px wide
        if (availableWidth >= 230) {
          return Row(
            children: List.generate(items.length, (index) {
              final item = Map<String, dynamic>.from(items[index]);
              final posterAsset = item['posterAsset'] ?? '';
              final isSelected = index == selectedIndex;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < items.length - 1 ? gap : 0.0,
                  ),
                  child: _ThumbnailCard(
                    posterAsset: posterAsset,
                    isSelected: isSelected,
                    onTap: () => onSelect(index),
                  ),
                ),
              );
            }),
          );
        }

        // Horizontal scrolling fallback for ultra-narrow screens (< 230px)
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = Map<String, dynamic>.from(items[index]);
              final posterAsset = item['posterAsset'] ?? '';
              final isSelected = index == selectedIndex;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < items.length - 1 ? 8.0 : 0.0,
                ),
                child: SizedBox(
                  width: 85,
                  child: _ThumbnailCard(
                    posterAsset: posterAsset,
                    isSelected: isSelected,
                    onTap: () => onSelect(index),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _ThumbnailCard extends StatefulWidget {
  final String posterAsset;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThumbnailCard({
    required this.posterAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ThumbnailCard> createState() => _ThumbnailCardState();
}

class _ThumbnailCardState extends State<_ThumbnailCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.secondaryAccent
                  : (_isHovered
                      ? AppColors.secondaryAccent.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.2)),
              width: widget.isSelected ? 2.2 : 1.0,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.secondaryAccent.withValues(alpha: 0.55),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: widget.isSelected ? 1.0 : (_isHovered ? 0.95 : 0.72),
              child: widget.posterAsset.startsWith('http')
                  ? Image.network(
                      widget.posterAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF13221E),
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.secondaryAccent,
                          size: 20,
                        ),
                      ),
                    )
                  : Image.asset(
                      widget.posterAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF13221E),
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.secondaryAccent,
                          size: 20,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBTLE GOLD DOT MATRIX ACCENT
// ─────────────────────────────────────────────────────────────────────────────
class _DotMatrixAccent extends StatelessWidget {
  final int rows;
  final int cols;
  final Color color;

  const _DotMatrixAccent({
    required this.rows,
    required this.cols,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(cols, (c) {
              return Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Container(
                  width: 2.5,
                  height: 2.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
