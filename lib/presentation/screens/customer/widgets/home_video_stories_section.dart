import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/utils/app_logger.dart';
import 'package:om_event/core/widgets/custom_button.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/domain/entities/settings_entities.dart';

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
      color: const Color(0xFF152621), // Secondary Background
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 72.0 : 48.0,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Obx(() {
            final videoSettings = AppConfigService.to.rxVideoSettings.value;
            final videos = videoSettings.videosList.isNotEmpty
                ? videoSettings.videosList
                : VideoSettings.defaultVal().videosList;

            if (videos.isEmpty) {
              return const SizedBox.shrink();
            }

            final activeList = videos;

            return Column(
              children: List.generate(activeList.length, (index) {
                final map = Map<String, dynamic>.from(activeList[index]);
                return Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        index < activeList.length - 1
                            ? (isDesktop ? 72 : 48)
                            : 0,
                  ),
                  child: _VideoStoryRow(
                    isDesktop: isDesktop,
                    eyebrow: map['eyebrow'] ?? '',
                    titlePart1: map['titlePart1'] ?? '',
                    titlePart2: map['titlePart2'] ?? '',
                    description: map['description'] ?? '',
                    facts: List<String>.from(map['facts'] ?? []),
                    videoAsset: map['videoAsset'] ?? '',
                    posterAsset: map['posterAsset'] ?? '',
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
                );
              }),
            );
          }),
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
            color: AppColors.secondaryAccent, // Champagne Gold
            fontWeight: FontWeight.bold,
            letterSpacing: 2.2,
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
                  color: AppColors.secondaryAccent, // Champagne Gold
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          description,
          style: AppTheme.sansBody(
            fontSize: 14.5,
            color: AppColors.muted,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 28),
        // Stated facts
        ...facts.map((fact) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Icon(
                      Icons.star_border,
                      size: 14,
                      color: AppColors.secondaryAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fact,
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        color: AppColors.muted.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 36),
        CustomButton(
          text: "EXPLORE DESIGN COLLECTION",
          isPrimary: true,
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
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    if (widget.videoAsset.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoAsset),
      );
    } else {
      _controller = VideoPlayerController.asset(widget.videoAsset);
    }
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
        _hasStarted = true;
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
          setState(() {
            _isPlaying = true;
            _hasStarted = true;
          });
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
                    child:
                        _isInitialized && _hasStarted
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 1600,
                                  height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 1000,
                                  child: VideoPlayer(_controller!),
                                ),
                              )
                            : (widget.posterAsset.startsWith('http')
                                ? Image.network(
                                    widget.posterAsset,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    widget.posterAsset,
                                    fit: BoxFit.cover,
                                  )),
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
                    color: const Color(0xFF0F1B18).withValues(alpha: 0.8), // Primary Background Glass
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
