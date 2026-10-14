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
/// - Full-screen event decoration video covering the entire viewport (`BoxFit.cover`)
/// - Multi-tiered video initialization: local bundled asset -> local web asset -> remote fallback
/// - Muted autoplay compliant with all modern browser autoplay restrictions
/// - Seamless looping with non-blocking first-frame presentation
/// - Luxury Obsidian & Warm Gold branded background (eliminates any black void while initializing)
/// - Subtle dark luxury radial vignette overlay
/// - Preserved bottom-right OM Events circular badge without duplicate center text
class VideoSplashScreen extends StatefulWidget {
  final bool isBootstrapGate;
  const VideoSplashScreen({super.key, this.isBootstrapGate = true});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  VideoPlayerController? _controller;
  SplashVideoState _videoState = SplashVideoState.loading;
  bool _isInitializing = false;

  static const String _localAssetPath = 'assets/videos/splash_screen.mp4';
  static const String _localWebPath = 'splash_screen.mp4';
  static const String _remoteVideoUrl =
      'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/gallery/Video/splash_screen.mp4';

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  /// Attempts to initialize a candidate video player controller.
  Future<bool> _tryInitializeCandidate(
    VideoPlayerController candidate,
    String candidateName,
  ) async {
    try {
      await candidate.initialize();
      if (!mounted) {
        candidate.dispose();
        return false;
      }
      await candidate.setLooping(true);
      await candidate.setVolume(0.0); // Muted autoplay required for web
      await candidate.play();
      _controller = candidate;
      AppLogger.info(
        'Splash video initialized successfully via $candidateName',
        className: 'VideoSplashScreen',
        methodName: '_tryInitializeCandidate',
      );
      return true;
    } catch (e) {
      AppLogger.warning(
        'Splash video candidate failed ($candidateName)',
        className: 'VideoSplashScreen',
        methodName: '_tryInitializeCandidate',
        error: e,
      );
      try {
        await candidate.dispose();
      } catch (_) {}
      return false;
    }
  }

  /// Initializes video asynchronously without blocking the initial visible frame.
  Future<void> _initVideo() async {
    if (_isInitializing || _controller != null) return;
    _isInitializing = true;

    final options = VideoPlayerOptions(mixWithOthers: true);

    // 1. Attempt local bundled asset (0ms network overhead)
    bool initialized = await _tryInitializeCandidate(
      VideoPlayerController.asset(
        _localAssetPath,
        videoPlayerOptions: options,
      ),
      'local_asset ($_localAssetPath)',
    );

    // 2. Fallback to local web-root served file
    if (!initialized && mounted) {
      initialized = await _tryInitializeCandidate(
        VideoPlayerController.networkUrl(
          Uri.parse(_localWebPath),
          videoPlayerOptions: options,
        ),
        'local_web ($_localWebPath)',
      );
    }

    // 3. Fallback to remote Supabase URL as last resort
    if (!initialized && mounted) {
      initialized = await _tryInitializeCandidate(
        VideoPlayerController.networkUrl(
          Uri.parse(_remoteVideoUrl),
          videoPlayerOptions: options,
        ),
        'remote_supabase',
      );
    }

    if (!mounted) {
      _controller?.dispose();
      _controller = null;
      return;
    }

    if (initialized && _controller != null && _controller!.value.isInitialized) {
      setState(() {
        _videoState = SplashVideoState.ready;
      });
    } else {
      AppLogger.error(
        'All splash video sources failed; falling back to branded splash UI',
      );
      setState(() {
        _videoState = SplashVideoState.error;
      });
    }

    _isInitializing = false;
  }

  @override
  void dispose() {
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

          // 3. Full-screen Video Cover (when ready)
          if (_videoState == SplashVideoState.ready &&
              _controller != null &&
              _controller!.value.isInitialized)
            FittedBox(
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

          // 3. Luxury Dark Radial Vignette Overlay (always layered for visual depth)
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

          // 4. Subtle Loading Indicator (only during initial video decoding phase)
          if (_videoState == SplashVideoState.loading)
            const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                  strokeWidth: 2,
                ),
              ),
            ),

          // 5. Preserved Bottom-Right OM Events Circular Badge (no duplicate center text)
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
