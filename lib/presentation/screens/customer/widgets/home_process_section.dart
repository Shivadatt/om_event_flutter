import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';

// ─── Background painter ────────────────────────────────────────────────────
class _ProcessBgPainter extends CustomPainter {
  final double animValue;
  const _ProcessBgPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF122018);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final double r = animValue * 2 * math.pi;

    final golds = [
      Offset(size.width * 0.15 + math.sin(r) * 60, size.height * 0.8),
      Offset(size.width * 0.85 - math.cos(r) * 60, size.height * 0.2),
    ];
    for (final c in golds) {
      final p = Paint()
        ..shader = ui.Gradient.radial(
          c, size.width * 0.35,
          [AppColors.secondaryAccent.withValues(alpha: 0.07), Colors.transparent],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant _ProcessBgPainter old) => old.animValue != animValue;
}

class _ProcessBackground extends StatefulWidget {
  final Widget child;
  const _ProcessBackground({required this.child});

  @override
  State<_ProcessBackground> createState() => _ProcessBackgroundState();
}

class _ProcessBackgroundState extends State<_ProcessBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(duration: const Duration(seconds: 20), vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _ProcessBgPainter(animValue: _c.value),
          child: widget.child,
        ),
      );
}

// ─── Step data ─────────────────────────────────────────────────────────────
class _StepData {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  const _StepData(this.number, this.title, this.description, this.icon, this.accentColor);
}

const _steps = [
  _StepData(
    "01",
    "Choose Your Canvas",
    "Browse our event collections and add the designs that speak to you.",
    Icons.palette_outlined,
    Color(0xFFC8A96E),
  ),
  _StepData(
    "02",
    "Make It Personal",
    "Tune colors, themes and quantities. Tell us your custom wishes.",
    Icons.tune_outlined,
    Color(0xFF7EC8A4),
  ),
  _StepData(
    "03",
    "Know Your Number",
    "See every cost itemized clearly and download your polished quotation.",
    Icons.receipt_long_outlined,
    Color(0xFF85B4FF),
  ),
  _StepData(
    "04",
    "We Bring The Wonder",
    "Our crew handles production and setup. You simply stay in the moment.",
    Icons.auto_awesome_outlined,
    Color(0xFFFFB085),
  ),
];

// ─── Step Card widget ──────────────────────────────────────────────────────
class _StepCard extends StatefulWidget {
  final _StepData step;
  final bool isLast;
  const _StepCard({required this.step, required this.isLast});

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.step;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _hovered ? -6.0 : 0.0),
        child: Stack(
          children: [
            // Card body
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF152A22),
                border: Border.all(
                  color: _hovered
                      ? s.accentColor.withValues(alpha: 0.55)
                      : s.accentColor.withValues(alpha: 0.15),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: s.accentColor.withValues(alpha: _hovered ? 0.18 : 0.06),
                    blurRadius: _hovered ? 24 : 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number + icon row
                  Row(
                    children: [
                      // Step number badge
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              s.accentColor.withValues(alpha: 0.25),
                              s.accentColor.withValues(alpha: 0.06),
                            ],
                          ),
                          border: Border.all(
                            color: s.accentColor.withValues(alpha: 0.45),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: s.accentColor.withValues(alpha: 0.25),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.number,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: s.accentColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Step icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: s.accentColor.withValues(alpha: 0.10),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          s.icon,
                          size: 18,
                          color: s.accentColor.withValues(alpha: 0.80),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Title
                  Text(
                    s.title,
                    style: GoogleFonts.italiana(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      height: 1.2,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Accent divider line
                  Container(
                    width: 36,
                    height: 1.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      gradient: LinearGradient(
                        colors: [s.accentColor, s.accentColor.withValues(alpha: 0.0)],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Description
                  Text(
                    s.description,
                    style: AppTheme.sansBody(
                      fontSize: 12.5,
                      color: AppColors.muted,
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Main section ──────────────────────────────────────────────────────────
class ProcessSection extends StatelessWidget {
  final bool isDesktop;
  const ProcessSection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final double pH = isDesktop ? 64.0 : 24.0;
    final double pV = isDesktop ? 80.0 : 48.0;

    return _ProcessBackground(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: pH, vertical: pV),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Eyebrow ──────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 1.5,
                      color: AppColors.secondaryAccent,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "EASY BY DESIGN",
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.5,
                        color: AppColors.secondaryAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Headline ──────────────────────────────────
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFFFE8A3), Color(0xFFF3D37A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(b),
                  child: Text(
                    "YOUR CELEBRATION,\nWITHOUT THE CHAOS.",
                    style: GoogleFonts.italiana(
                      fontSize: isDesktop ? 42 : 30,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1.2,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Four seamless steps from vision to reality.",
                  style: AppTheme.sansBody(
                    fontSize: 13.5,
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 52),

                // ── Step cards ────────────────────────────────
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < _steps.length; i++) ...[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: (i == 1 || i == 3) ? 28.0 : 0.0,
                            ),
                            child: _StepCard(
                              step: _steps[i],
                              isLast: i == _steps.length - 1,
                            ),
                          ),
                        ),
                        if (i < _steps.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 22),
                            child: _ConnectorArrow(
                              color: _steps[i].accentColor,
                            ),
                          ),
                      ],
                    ],
                  )
                else
                  Column(
                    children: [
                      for (int i = 0; i < _steps.length; i++) ...[
                        _StepCard(step: _steps[i], isLast: i == _steps.length - 1),
                        if (i < _steps.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                            child: _VerticalConnector(color: _steps[i].accentColor),
                          ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal dashed arrow connector (desktop)
class _ConnectorArrow extends StatelessWidget {
  final Color color;
  const _ConnectorArrow({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 44,
      child: Center(
        child: CustomPaint(
          painter: _DashArrowPainter(color: color),
          size: const Size(28, 2),
        ),
      ),
    );
  }
}

class _DashArrowPainter extends CustomPainter {
  final Color color;
  const _DashArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Dashed line
    double x = 0;
    while (x < size.width - 6) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
      x += 7;
    }
    // Arrow head
    final arrowPaint = Paint()
      ..color = color.withValues(alpha: 0.65)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width - 7, -4), Offset(size.width, 0), arrowPaint);
    canvas.drawLine(Offset(size.width - 7, 4), Offset(size.width, 0), arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _DashArrowPainter old) => old.color != color;
}

/// Vertical connector (mobile)
class _VerticalConnector extends StatelessWidget {
  final Color color;
  const _VerticalConnector({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.5,
      height: 24,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0.05)],
        ),
      ),
    );
  }
}
