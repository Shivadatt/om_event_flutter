import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../config/app_theme.dart';
import '../utils/app_logger.dart';

/// Centralized, production-grade Video Player with Flutter Web autoplay compliance,
/// responsive luxury controls, error recovery, and robust lifecycle management.
class AppVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool initialMuted;
  final double? customAspectRatio;

  const AppVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
    this.looping = true,
    this.showControls = true,
    this.initialMuted = false,
    this.customAspectRatio,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _controlsVisible = true;
  Timer? _hideControlsTimer;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.initialMuted;
    _initController();
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initController();
    }
  }

  Future<void> _initController() async {
    _disposeController();

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _isInitialized = false;
    });

    try {
      AppLogger.info(
        "Initializing video player for URL: ${widget.videoUrl}",
        layer: LogLayer.ui,
        className: "AppVideoPlayer",
        methodName: "_initController",
      );

      final options = VideoPlayerOptions(mixWithOthers: true);
      if (widget.videoUrl.startsWith('http://') ||
          widget.videoUrl.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: options,
        );
      } else {
        _controller = VideoPlayerController.asset(
          widget.videoUrl,
          videoPlayerOptions: options,
        );
      }

      await _controller!.initialize();
      if (!mounted || _controller == null) return;

      await _controller!.setLooping(widget.looping);

      if (_isMuted) {
        await _controller!.setVolume(0.0);
      } else {
        await _controller!.setVolume(1.0);
      }

      _controller!.addListener(_videoListener);

      if (widget.autoPlay) {
        try {
          await _controller!.play();
          _isPlaying = true;
        } catch (e) {
          AppLogger.warning(
            "Unmuted autoplay blocked by browser policy, falling back to muted autoplay: $e",
            layer: LogLayer.ui,
            className: "AppVideoPlayer",
            methodName: "_initController",
          );
          try {
            await _controller!.setVolume(0.0);
            _isMuted = true;
            await _controller!.play();
            _isPlaying = true;
          } catch (e2) {
            AppLogger.error("Failed to autoplay video muted: $e2", e2);
          }
        }
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _hasError = false;
          _duration = _controller!.value.duration;
          _position = _controller!.value.position;
          _isPlaying = _controller!.value.isPlaying;
        });
        _scheduleHideControls();
      }
    } catch (e, stack) {
      AppLogger.errorDetailed(
        "Error initializing video player: $e",
        layer: LogLayer.ui,
        className: "AppVideoPlayer",
        methodName: "_initController",
        error: e,
        stack: stack,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = false;
          _hasError = true;
          _errorMessage = "Unable to load this video right now.";
        });
      }
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    final val = _controller!.value;

    if (val.hasError) {
      AppLogger.error("Video player runtime error: ${val.errorDescription}");
      if (!_hasError) {
        setState(() {
          _hasError = true;
          _errorMessage = "Unable to load this video right now.";
        });
      }
      return;
    }

    final newPos = val.position;
    final newDur = val.duration;
    final newPlaying = val.isPlaying;

    if (newPos != _position || newDur != _duration || newPlaying != _isPlaying) {
      setState(() {
        _position = newPos;
        _duration = newDur;
        _isPlaying = newPlaying;
      });
    }
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    if (_isPlaying && widget.showControls) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() => _controlsVisible = false);
        }
      });
    }
  }

  void _showControls() {
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
    }
    _scheduleHideControls();
  }

  Future<void> _togglePlay() async {
    if (_controller == null || !_isInitialized) return;
    if (_isPlaying) {
      await _controller!.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _controlsVisible = true;
        });
      }
      _hideControlsTimer?.cancel();
    } else {
      try {
        await _controller!.play();
        if (mounted) {
          setState(() => _isPlaying = true);
        }
        _scheduleHideControls();
      } catch (e) {
        AppLogger.warning("Error during play toggle: $e");
        try {
          await _controller!.setVolume(0.0);
          _isMuted = true;
          await _controller!.play();
          if (mounted) {
            setState(() {
              _isMuted = true;
              _isPlaying = true;
            });
          }
          _scheduleHideControls();
        } catch (_) {}
      }
    }
  }

  Future<void> _toggleMute() async {
    if (_controller == null || !_isInitialized) return;
    if (_isMuted) {
      await _controller!.setVolume(1.0);
      if (mounted) setState(() => _isMuted = false);
    } else {
      await _controller!.setVolume(0.0);
      if (mounted) setState(() => _isMuted = true);
    }
    _showControls();
  }

  Future<void> _seekTo(double relativePosition) async {
    if (_controller == null || !_isInitialized || _duration == Duration.zero) return;
    final targetMs = (relativePosition * _duration.inMilliseconds).clamp(0, _duration.inMilliseconds.toDouble()).toInt();
    final target = Duration(milliseconds: targetMs);
    await _controller!.seekTo(target);
    _showControls();
  }

  void _disposeController() {
    _hideControlsTimer?.cancel();
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    // 1. Loading State
    if (_isLoading) {
      return Container(
        height: 360,
        width: double.infinity,
        color: const Color(0xFF070E0B),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(goldColor),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Loading video...",
                style: TextStyle(
                  color: Color(0xFFE8CC8A),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Error State (Exact format per spec)
    if (_hasError || !_isInitialized || _controller == null) {
      return Container(
        height: 360,
        width: double.infinity,
        color: const Color(0xFF070E0B),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: goldColor.withValues(alpha: 0.1),
                  border: Border.all(color: goldColor.withValues(alpha: 0.35)),
                ),
                child: const Icon(
                  Icons.videocam_off_outlined,
                  color: goldColor,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Video unavailable",
                style: GoogleFonts.italiana(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage.isNotEmpty
                    ? _errorMessage
                    : "Unable to load this video right now.",
                textAlign: TextAlign.center,
                style: AppTheme.sansBody(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _initController,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8CC8A), Color(0xFFC8A96E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: goldColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF070E0B)),
                      const SizedBox(width: 8),
                      Text(
                        "Retry",
                        style: AppTheme.sansBody(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF070E0B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Active Playback State
    final rawRatio = _controller!.value.aspectRatio;
    final aspectRatio = widget.customAspectRatio ?? (rawRatio > 0.1 ? rawRatio : 16 / 9);

    return MouseRegion(
      onHover: (_) => _showControls(),
      child: GestureDetector(
        onTap: _showControls,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              // Real HTML/Canvas Video Player
              VideoPlayer(_controller!),

              // Click-to-toggle play surface
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _togglePlay,
                child: Container(color: Colors.transparent),
              ),

              // Controls Overlay
              if (widget.showControls)
                AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: Stack(
                      children: [
                        // Center Play / Pause Pulsing Button
                        Center(
                          child: GestureDetector(
                            onTap: _togglePlay,
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF091410).withValues(alpha: 0.78),
                                border: Border.all(
                                  color: goldColor.withValues(alpha: 0.65),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 30,
                                  color: const Color(0xFFE8CC8A),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bottom Gradient Bar with Scrub & Audio Controls
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(14, 20, 14, 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.92),
                                  Colors.black.withValues(alpha: 0.65),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Scrubber Progress Bar
                                SizedBox(
                                  height: 18,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3.5,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 12,
                                      ),
                                      activeTrackColor: goldColor,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: const Color(0xFFE8CC8A),
                                      overlayColor: goldColor.withValues(alpha: 0.2),
                                    ),
                                    child: Slider(
                                      value: _duration.inMilliseconds > 0
                                          ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
                                          : 0.0,
                                      onChanged: (val) => _seekTo(val),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),

                                // Bottom Row: Play/Pause, Timestamps, Mute/Unmute
                                Row(
                                  children: [
                                    // Play / Pause Icon
                                    IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        _isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: const Color(0xFFE8CC8A),
                                      ),
                                      onPressed: _togglePlay,
                                    ),
                                    const SizedBox(width: 12),

                                    // Time Indicator
                                    Text(
                                      "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
                                      style: AppTheme.sansBody(
                                        fontSize: 11,
                                        color: Colors.white70,
                                        letterSpacing: 0.3,
                                      ),
                                    ),

                                    const Spacer(),

                                    // Volume / Mute Toggle Button
                                    GestureDetector(
                                      onTap: _toggleMute,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _isMuted
                                              ? const Color(0xFFE8CC8A).withValues(alpha: 0.2)
                                              : Colors.white10,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _isMuted
                                                ? goldColor.withValues(alpha: 0.6)
                                                : Colors.white24,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _isMuted
                                                  ? Icons.volume_off_rounded
                                                  : Icons.volume_up_rounded,
                                              size: 15,
                                              color: _isMuted
                                                  ? const Color(0xFFE8CC8A)
                                                  : Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _isMuted ? "MUTED" : "SOUND ON",
                                              style: AppTheme.sansBody(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: _isMuted
                                                    ? const Color(0xFFE8CC8A)
                                                    : Colors.white70,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
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
            ],
          ),
        ),
      ),
    );
  }
}
