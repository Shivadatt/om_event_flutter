import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/presentation/screens/customer/helpers/customer_dialog_helper.dart';

// Fallback poster image URL
const String _fallbackPoster = 'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/gallery/images/balloon_blast_thumbnail.png';

// ─── Grain Noise Custom Painter (Layer 4) ─────────────────────────────────
class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.012)
      ..style = PaintingStyle.fill;
    
    final math.Random random = math.Random(1337); // stable noise seed
    for (int i = 0; i < 400; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.75, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => false;
}

// ─── Gold Radial Glow Painter (Layer 3) ───────────────────────────────────
class _GoldGlowPainter extends CustomPainter {
  const _GoldGlowPainter();

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
  bool shouldRepaint(covariant _GoldGlowPainter old) => false;
}

// ─── Video Player (Plays only on Hover) ──────────────────────────────────
class _CinematicBackground extends StatefulWidget {
  final bool isHovered;
  const _CinematicBackground({required this.isHovered});

  @override
  State<_CinematicBackground> createState() => _CinematicBackgroundState();
}

class _CinematicBackgroundState extends State<_CinematicBackground>
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
  void didUpdateWidget(covariant _CinematicBackground oldWidget) {
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
    // Brand custom cinematic color matrix (Reduced brightness, contrast scale, saturation +5%)
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
          final scale = 1.0 + (_zoomController.value * 0.05); // Slow zoom 1.0 -> 1.05
          return Transform.scale(
            scale: scale,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Fallback / Idle Poster (shown when not hovered)
                Image.network(
                  _fallbackPoster,
                  fit: BoxFit.cover,
                ),
                
                // Video Player (always mounted, but opacity changes based on hover)
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

// ─── Luxury Premium Custom Button ─────────────────────────────────────────
class _CinematicButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _CinematicButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_CinematicButton> createState() => _CinematicButtonState();
}

class _CinematicButtonState extends State<_CinematicButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFC8A96E);
    final goldLight = const Color(0xFFE8CC8A);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..translate(0.0, _hovered ? -3.0 : 0.0),
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
            color: widget.isPrimary
                ? null
                : const Color(0xFF132219).withValues(alpha: _hovered ? 0.85 : 0.55),
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

// ─── Main Hero Section ────────────────────────────────────────────────────
class HeroSection extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isDesktop;

  const HeroSection({
    super.key,
    required this.scaffoldKey,
    required this.isDesktop,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    // Trigger animations instantly
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    // Luxury layout padding & heights
    final double pH = widget.isDesktop ? 80.0 : 24.0;
    final double titleSize = width >= 700 ? (width * 0.055).clamp(42.0, 76.0) : 34.0;
    
    // Lock hero height to screen height (min 660, max 920)
    final double heroHeight = height.clamp(660.0, 920.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: double.infinity,
        height: heroHeight,
        color: const Color(0xFF0D1915),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background Video Layer ──────────────────────────────
            Positioned.fill(child: _CinematicBackground(isHovered: _isHovered)),

          // ── Layer 1: Black transparent overlay ──────────────────
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),

          // ── Layer 2: Dark emerald gradient ──────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF080A08).withValues(alpha: 0.88),
                    const Color(0xFF0A120E).withValues(alpha: 0.65),
                    const Color(0xFF000000).withValues(alpha: 0.20),
                  ],
                  stops: const [0.0, 0.40, 1.0],
                ),
              ),
            ),
          ),

          // ── Layer 3: Soft gold radial glow behind heading ────────
          const Positioned.fill(child: CustomPaint(painter: _GoldGlowPainter())),

          // ── Layer 4: Subtle film grain overlay ───────────────────
          const Positioned.fill(child: CustomPaint(painter: _GrainPainter())),

          // ── Content Layout ───────────────────────────────────────
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pH),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Obx(() {
                    final homepage = AppConfigService.to.rxHomepageSettings.value;
                    final stats = AppConfigService.to.rxStatisticsSettings.value;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                          widget.isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 72), // push content slightly below transparent navbar
                        
                        // ── Eyebrow label ─────────────────────────────
                        AnimatedBuilder(
                          animation: _fadeController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeController.value,
                              child: child,
                            );
                          },
                          child: Text(
                            "BESPOKE EVENT DESIGN • AHMEDABAD",
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4.0,
                              color: AppColors.secondaryAccent,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 18),

                        // ── Luxury Large Heading ───────────────────────
                        AnimatedBuilder(
                          animation: _slideController,
                          builder: (context, child) {
                            final double slide = (1.0 - _slideController.value) * 36;
                            return Opacity(
                              opacity: _slideController.value,
                              child: Transform.translate(
                                offset: Offset(0, slide),
                                child: child,
                              ),
                            );
                          },
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [
                                  Color(0xFFFAF8F3), // Warm White
                                  Color(0xFFFFE8A3), // Soft Gold
                                  Color(0xFFF3D37A), // Champagne Gold
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: Text(
                              "CELEBRATIONS,\nTHOUGHTFULLY\nCOMPOSED.",
                              style: GoogleFonts.italiana(
                                fontSize: titleSize,
                                color: Colors.white,
                                height: 0.96,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 1.5,
                              ),
                              textAlign:
                                  widget.isDesktop ? TextAlign.start : TextAlign.center,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── Subtitle ──────────────────────────────────
                        AnimatedBuilder(
                          animation: _fadeController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeController.value,
                              child: child,
                            );
                          },
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 580),
                            child: Text(
                              homepage.heroSubtitle,
                              style: AppTheme.sansBody(
                                fontSize: 15.5,
                                color: AppColors.muted.withValues(alpha: 0.85),
                                height: 1.7,
                              ),
                              textAlign:
                                  widget.isDesktop ? TextAlign.start : TextAlign.center,
                            ),
                          ),
                        ),

                        const SizedBox(height: 38),

                        // ── CTA Buttons ────────────────────────────────
                        AnimatedBuilder(
                          animation: _slideController,
                          builder: (context, child) {
                            final double slide = (1.0 - _slideController.value) * 24;
                            return Opacity(
                              opacity: _slideController.value,
                              child: Transform.translate(
                                offset: Offset(0, slide),
                                child: child,
                              ),
                            );
                          },
                          child: widget.isDesktop
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _CinematicButton(
                                      text: "Design Your Event",
                                      isPrimary: true,
                                      onPressed: () {
                                        widget.scaffoldKey.currentState?.openEndDrawer();
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                    _CinematicButton(
                                      text: "Plan With An Expert",
                                      isPrimary: false,
                                      onPressed: () =>
                                          CustomerDialogHelper.openLeadDialog(context),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _CinematicButton(
                                      text: "Design Your Event",
                                      isPrimary: true,
                                      onPressed: () {
                                        widget.scaffoldKey.currentState?.openEndDrawer();
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _CinematicButton(
                                      text: "Plan With An Expert",
                                      isPrimary: false,
                                      onPressed: () =>
                                          CustomerDialogHelper.openLeadDialog(context),
                                    ),
                                  ],
                                ),
                        ),

                        const SizedBox(height: 60),

                        // ── Trust & Stats Band ────────────────────────
                        AnimatedBuilder(
                          animation: _fadeController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeController.value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            alignment: widget.isDesktop
                                ? Alignment.centerLeft
                                : Alignment.center,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _statItem("4.9 Google Rating"),
                                _dotSeparator(),
                                _statItem("${stats.completedEvents}+ Celebrations"),
                                _dotSeparator(),
                                _statItem("${stats.years} Years Experience"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _statItem(String label) {
    return Text(
      label.toUpperCase(),
      style: AppTheme.sansBody(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppColors.muted.withValues(alpha: 0.65),
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _dotSeparator() {
    return Text(
      "•",
      style: TextStyle(
        color: AppColors.secondaryAccent.withValues(alpha: 0.4),
        fontSize: 12,
      ),
    );
  }
}
