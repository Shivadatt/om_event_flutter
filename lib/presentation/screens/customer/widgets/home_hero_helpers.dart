import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';

const String fallbackPoster = 'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/gallery/images/balloon_blast_thumbnail.png';

class GrainPainter extends CustomPainter {
  const GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.012)
      ..style = PaintingStyle.fill;
    
    final math.Random random = math.Random(1337);
    for (int i = 0; i < 400; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.75, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GrainPainter old) => false;
}

class GoldGlowPainter extends CustomPainter {
  const GoldGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.25, size.height * 0.45),
        size.width * 0.45,
        [
          AppColors.secondaryAccent.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant GoldGlowPainter old) => false;
}

class CinematicBackground extends StatefulWidget {
  final bool isHovered;
  const CinematicBackground({super.key, required this.isHovered});

  @override
  State<CinematicBackground> createState() => _CinematicBackgroundState();
}

class _CinematicBackgroundState extends State<CinematicBackground>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  late AnimationController _zoomController;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      duration: const Duration(seconds: 24),
      vsync: this,
    )..repeat(reverse: true);
    _initController();
  }

  Future<void> _initController() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/gallery/Video/balloon_blast_hero_section_video.mp4'),
    );
    try {
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0.0);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.isHovered) {
          _controller!.play();
        }
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant CinematicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller == null || !_isInitialized) return;
    if (widget.isHovered) {
      _controller!.play();
    } else {
      _controller!.pause();
    }
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double b = 0.86; 
    const double c = 1.06; 
    const double sat = 1.05; 
    
    final double invSat = 1.0 - sat;
    final double rWeight = 0.213 * invSat;
    final double gWeight = 0.715 * invSat;
    final double bWeight = 0.072 * invSat;
    
    final List<double> colorMatrix = [
      (rWeight + sat) * b * c, gWeight * b * c, bWeight * b * c, 0, 0,
      rWeight * b * c, (gWeight + sat) * b * c, bWeight * b * c, 0, 0,
      rWeight * b * c, gWeight * b * c, (bWeight + sat) * b * c, 0, 0,
      0, 0, 0, 1, 0,
    ];

    return ColorFiltered(
      colorFilter: ColorFilter.matrix(colorMatrix),
      child: AnimatedBuilder(
        animation: _zoomController,
        builder: (context, child) {
          final scale = 1.0 + (_zoomController.value * 0.05);
          return Transform.scale(
            scale: scale,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(fallbackPoster, fit: BoxFit.cover),
                if (_isInitialized && _controller != null)
                  IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: widget.isHovered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 1280,
                          height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 720,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CinematicButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const CinematicButton({
    super.key,
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<CinematicButton> createState() => _CinematicButtonState();
}

class _CinematicButtonState extends State<CinematicButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFC8A96E);
    const goldLight = Color(0xFFE8CC8A);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0.0, _hovered ? -3.0 : 0.0, 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: _hovered ? [goldLight, goldColor] : [goldColor, const Color(0xFF9E7E45)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isPrimary ? null : const Color(0xFF132219).withValues(alpha: _hovered ? 0.85 : 0.55),
            border: Border.all(
              color: goldColor.withValues(alpha: widget.isPrimary ? 0.0 : 0.4),
              width: 1.5,
            ),
            boxShadow: [
              if (_hovered)
                BoxShadow(
                  color: goldColor.withValues(alpha: widget.isPrimary ? 0.45 : 0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Text(
            widget.text.toUpperCase(),
            style: AppTheme.sansBody(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: widget.isPrimary ? const Color(0xFF0F1B18) : Colors.white,
              letterSpacing: 2.2,
            ),
          ),
        ),
      ),
    );
  }
}
