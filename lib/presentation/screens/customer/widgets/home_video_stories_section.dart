import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/utils/app_logger.dart';
import 'package:om_event/core/widgets/custom_button.dart';

class VideoStoriesSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      key: storiesKey,
      width: double.infinity,
      color: const Color(0xFF16201D),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 100.0 : 60.0,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              _VideoStoryRow(
                isDesktop: isDesktop,
                eyebrow: "Celebrate in style",
                titlePart1: "A glimpse before",
                titlePart2: "the big day.",
                description:
                    "From elegant balloon styling to personalized backdrops and thoughtful details, we create celebrations that feel joyful, memorable, and uniquely yours. Every setup is crafted to make your special day unforgettable.",
                facts: const [
                  "Theme & Planning",
                  "Production & styling",
                  "Celebrate & Capture Memories",
                ],
                videoAsset: "assets/videos/Birthday.mp4",
                posterAsset: "assets/images/birthday.jpg",
                onCtaPressed: () {
                  final ctx = catalogKey.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(
                      ctx,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              SizedBox(height: isDesktop ? 100 : 60),
              _VideoStoryRow(
                isDesktop: isDesktop,
                eyebrow: "Experience the excitement",
                titlePart1: "Balloon Blast",
                titlePart2: "the perfect surprise.",
                description:
                    "A single pop transforms the atmosphere into a shower of colors, confetti, and unforgettable smiles. Designed to create the perfect reveal for birthdays, proposals, anniversaries, baby showers, and every celebration worth remembering.",
                facts: const [
                  "Suspense & Countdown",
                  "Balloon Blast Moment",
                  "Cheers & Celebration",
                ],
                videoAsset: "assets/videos/Balloonblast.mp4",
                posterAsset: "assets/images/BaloonBlast.jpg",
                onCtaPressed: () {
                  final ctx = catalogKey.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(
                      ctx,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoStoryRow extends StatelessWidget {
  final bool isDesktop;
  final String eyebrow;
  final String titlePart1;
  final String titlePart2;
  final String description;
  final List<String> facts;
  final String videoAsset;
  final String posterAsset;
  final VoidCallback onCtaPressed;

  const _VideoStoryRow({
    required this.isDesktop,
    required this.eyebrow,
    required this.titlePart1,
    required this.titlePart2,
    required this.description,
    required this.facts,
    required this.videoAsset,
    required this.posterAsset,
    required this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double titleSize =
        isDesktop ? (width * 0.045).clamp(42.0, 76.0) : 34.0;

    final copyWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: AppTheme.sansBody(
            fontSize: 10,
            color: const Color(0xFFD6B080),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            style: GoogleFonts.italiana(
              fontSize: titleSize,
              color: Colors.white,
              height: 0.98,
            ),
            children: [
              TextSpan(text: "$titlePart1\n"),
              TextSpan(
                text: titlePart2,
                style: GoogleFonts.italiana(
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFD6B080),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          description,
          style: AppTheme.sansBody(
            fontSize: 14,
            color: const Color(0xFFF4F0E8).withValues(alpha: 0.65),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(facts.length, (index) {
            final numStr = "0${index + 1}";
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      numStr,
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        color: const Color(0xFFD6B080),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      facts[index].toUpperCase(),
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        color: const Color(0xFFF4F0E8),
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: "Build your celebration ↗",
          isPrimary: false,
          onPressed: onCtaPressed,
        ),
      ],
    );

    final videoWidget = _VideoStoryFrame(
      videoAsset: videoAsset,
      posterAsset: posterAsset,
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 8, child: copyWidget),
          const SizedBox(width: 80),
          Expanded(flex: 12, child: videoWidget),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [copyWidget, const SizedBox(height: 40), videoWidget],
      );
    }
  }
}

class _VideoStoryFrame extends StatefulWidget {
  final String videoAsset;
  final String posterAsset;

  const _VideoStoryFrame({required this.videoAsset, required this.posterAsset});

  @override
  State<_VideoStoryFrame> createState() => _VideoStoryFrameState();
}

class _VideoStoryFrameState extends State<_VideoStoryFrame> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _controller = VideoPlayerController.asset(widget.videoAsset);
    try {
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0.0);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      AppLogger.error("Error initializing video", e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        if (_isInitialized && !_isPlaying) {
          _controller!.play();
          setState(() => _isPlaying = true);
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        if (_isInitialized && _isPlaying) {
          _controller!.pause();
          setState(() => _isPlaying = false);
        }
      },
      child: GestureDetector(
        onTap: _togglePlay,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 80,
                offset: const Offset(0, 28),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: _isInitialized && _isPlaying
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          )
                        : Image.asset(
                            widget.posterAsset,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    color: const Color(0xC70F1815),
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
                Center(
                  child: AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
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
