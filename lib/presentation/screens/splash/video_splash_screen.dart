import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/utils/app_logger.dart';

/// Explicit video splash playback and loading states.
enum SplashVideoState {
  loading,
  ready,
  error,
}

/// Full-screen Video Splash Screen.
///
/// Features:
/// - Immediate first-frame presentation (luxury obsidian base + crisp splash poster)
/// - Multi-tiered video initialization with strict per-source timeouts:
///   1. Local bundled asset (`assets/videos/splash_screen.mp4`)
///   2. Local web root asset (`/splash_screen.mp4`)
///   3. Remote CDN fallback
/// - Muted autoplay compliant with all modern browser autoplay restrictions
/// - Zero indefinite spinner: when video is buffering or in fallback, branded visual is seamlessly shown
/// - Preserved luxury radial vignette overlay and bottom-right OM Events circular badge
/// - No duplicate center branding text
class VideoSplashScreen extends StatefulWidget {
  final bool isBootstrapGate;
  final VoidCallback? onVideoReady;
  final VoidCallback? onSplashComplete;

  const VideoSplashScreen({
    super.key,
    this.isBootstrapGate = true,
    this.onVideoReady,
    this.onSplashComplete,
  });

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  VideoPlayerController? _controller;
  SplashVideoState _videoState = SplashVideoState.loading;
  bool _isInitializing = false;
  bool _isDisposed = false;

  static const String _localAssetPath = 'assets/videos/splash_screen.mp4';
  static const String _localWebPath = 'splash_screen.mp4';
  static const String _remoteVideoUrl =
      'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/gallery/Video/splash_screen.mp4';

  @override
  void initState() {
    super.initState();
    AppLogger.info(
      'Mounting VideoSplashScreen (isBootstrapGate: ${widget.isBootstrapGate})',
      className: 'VideoSplashScreen',
      methodName: 'initState',
    );
    _initVideo();
  }

  /// Attempts to initialize a candidate video player controller with a strict timeout.
  Future<bool> _tryInitializeCandidate(
    VideoPlayerController candidate,
    String candidateName,
  ) async {
    if (_isDisposed) {
      candidate.dispose();
      return false;
    }

    try {
      AppLogger.info(
        'Attempting candidate initialization: $candidateName',
        className: 'VideoSplashScreen',
        methodName: '_tryInitializeCandidate',
      );

      // Strict 3.5s timeout per candidate to prevent indefinite hanging
      await candidate.initialize().timeout(const Duration(milliseconds: 3500));

      if (!mounted || _isDisposed) {
        candidate.dispose();
        return false;
      }

      await candidate.setLooping(true);
      await candidate.setVolume(0.0); // Muted autoplay required by modern web browsers

      try {
        await candidate.play();
      } catch (playErr) {
        AppLogger.warning(
          'Video candidate play() notice (browser policy may require mute): $playErr',
          className: 'VideoSplashScreen',
          methodName: '_tryInitializeCandidate',
        );
      }

      _controller = candidate;
      AppLogger.success(
        'Splash video initialized & playing successfully via $candidateName',
        className: 'VideoSplashScreen',
        methodName: '_tryInitializeCandidate',
      );
      return true;
    } catch (e) {
      AppLogger.warning(
        'Splash video candidate failed ($candidateName): $e',
        className: 'VideoSplashScreen',
        methodName: '_tryInitializeCandidate',
      );
      try {
        await candidate.dispose();
      } catch (_) {}
      return false;
    }
  }

  /// Initializes video asynchronously without blocking first-frame display.
  Future<void> _initVideo() async {
    if (_isInitializing || _controller != null || _isDisposed) return;
    _isInitializing = true;

    final options = VideoPlayerOptions(mixWithOthers: true);

    // 1. Attempt local bundled asset
    bool initialized = await _tryInitializeCandidate(
      VideoPlayerController.asset(
        _localAssetPath,
        videoPlayerOptions: options,
      ),
      'local_asset ($_localAssetPath)',
    );

    // 2. Fallback to web root served file
    if (!initialized && mounted && !_isDisposed) {
      initialized = await _tryInitializeCandidate(
        VideoPlayerController.networkUrl(
          Uri.parse(_localWebPath),
          videoPlayerOptions: options,
        ),
        'web_root ($_localWebPath)',
      );
    }

    // 3. Fallback to remote Supabase CDN URL
    if (!initialized && mounted && !_isDisposed) {
      initialized = await _tryInitializeCandidate(
        VideoPlayerController.networkUrl(
          Uri.parse(_remoteVideoUrl),
          videoPlayerOptions: options,
        ),
        'remote_supabase',
      );
    }

    if (!mounted || _isDisposed) {
      _controller?.dispose();
      _controller = null;
      return;
    }

    if (initialized && _controller != null && _controller!.value.isInitialized) {
      setState(() {
        _videoState = SplashVideoState.ready;
      });
      widget.onVideoReady?.call();
    } else {
      AppLogger.error(
        'All splash video sources failed; falling back gracefully to branded splash visual',
      );
      setState(() {
        _videoState = SplashVideoState.error;
      });
    }

    _isInitializing = false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D0B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base Luxury Background — always rendered, eliminating any blank black frame
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.25,
                colors: [
                  Color(0xFF1E1A16), // Warm obsidian / deep bronze
                  Color(0xFF0F0D0B), // Canonical luxury black
                ],
              ),
            ),
          ),

          // 2. Instant First-Frame Splash Poster — renders synchronously, zero blank wait
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_poster.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // 3. Full-screen Video Cover (when initialized and ready to paint)
          if (_videoState == SplashVideoState.ready &&
              _controller != null &&
              _controller!.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller!.value.size.width > 0
                      ? _controller!.value.size.width
                      : 1920,
                  height: _controller!.value.size.height > 0
                      ? _controller!.value.size.height
                      : 1080,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),

          // 4. Luxury Dark Radial Vignette Overlay (always layered for visual depth)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.15,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),

          // 5. Preserved Bottom-Right OM Events Circular Badge (no duplicate center text, NO spinner)
          Positioned(
            right: 28,
            bottom: 28,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
                  width: 1.5,
                ),
                color: const Color(0xFF0F0D0B).withValues(alpha: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'OE',
                  style: TextStyle(
                    fontFamily: 'Italiana',
                    fontSize: 20,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
