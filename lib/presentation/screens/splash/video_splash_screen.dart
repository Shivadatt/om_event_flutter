import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Full-screen Video Splash Screen.
///
/// Features:
/// - Full-screen event decoration video covering the entire viewport
/// - Muted autoplay compliant with all browser autoplay policies
/// - Seamless looping
/// - Preserves the luxury OM Events atmosphere with zero simple/intermediate logo flash
class VideoSplashScreen extends StatefulWidget {
  final bool isBootstrapGate;
  const VideoSplashScreen({super.key, this.isBootstrapGate = true});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  static const String _remoteVideoUrl =
      'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/gallery/Video/splash_screen.mp4';
  static const String _localVideoPath = 'splash_screen.mp4';

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final options = VideoPlayerOptions(mixWithOthers: true);

    try {
      final remoteCtrl = VideoPlayerController.networkUrl(
        Uri.parse(_remoteVideoUrl),
        videoPlayerOptions: options,
      );
      await remoteCtrl.initialize();
      if (!mounted) {
        remoteCtrl.dispose();
        return;
      }
      _controller = remoteCtrl;
    } catch (_) {
      try {
        final localCtrl = VideoPlayerController.networkUrl(
          Uri.parse(_localVideoPath),
          videoPlayerOptions: options,
        );
        await localCtrl.initialize();
        if (!mounted) {
          localCtrl.dispose();
          return;
        }
        _controller = localCtrl;
      } catch (_) {}
    }

    if (_controller != null && _controller!.value.isInitialized) {
      await _controller!.setLooping(true);
      await _controller!.setVolume(0.0);
      await _controller!.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D0B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen video cover
          if (_isInitialized && _controller != null)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
        ],
      ),
    );
  }
}
