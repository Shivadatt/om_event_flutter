import 'package:flutter/material.dart';
import 'package:om_event/core/config/app_theme.dart';

class AnimatedStatsBand extends StatelessWidget {
  final bool isDesktop;
  const AnimatedStatsBand({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final forestColor =
        isDark ? const Color(0xFF131D1A) : const Color(0xFFF4F0E8);
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = width >= 1000 ? 64.0 : 24.0;

    if (width >= 700) {
      return Container(
        decoration: BoxDecoration(
          color: forestColor,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
              width: 1,
            ),
            bottom: BorderSide(
              color: isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: 62,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              children: const [
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 650,
                    label: "celebrations styled",
                    showLeftBorder: false,
                  ),
                ),
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 38,
                    label: "creative specialists",
                  ),
                ),
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 4.9,
                    label: "average rating",
                    hasPlus: false,
                    decimals: 1,
                  ),
                ),
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 12,
                    label: "cities served",
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: forestColor,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
              width: 1,
            ),
            bottom: BorderSide(
              color: isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 650,
                    label: "celebrations styled",
                    showLeftBorder: false,
                  ),
                ),
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 38,
                    label: "creative specialists",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: const [
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 4.9,
                    label: "average rating",
                    hasPlus: false,
                    decimals: 1,
                    showLeftBorder: false,
                  ),
                ),
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 12,
                    label: "cities served",
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}

class _AnimatedStatTile extends StatefulWidget {
  final double targetValue;
  final String label;
  final bool hasPlus;
  final int decimals;
  final bool showLeftBorder;

  const _AnimatedStatTile({
    required this.targetValue,
    required this.label,
    this.hasPlus = true,
    this.decimals = 0,
    this.showLeftBorder = true,
  });

  @override
  State<_AnimatedStatTile> createState() => _AnimatedStatTileState();
}

class _AnimatedStatTileState extends State<_AnimatedStatTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.targetValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor =
        isDark ? const Color(0xFFE3C89F) : const Color(0xFF9C7A4E);
    final labelColor =
        isDark ? const Color(0xFFE8ECE9) : const Color(0xFF1A2823);
    final double paddingLeft =
        MediaQuery.of(context).size.width >= 700 ? 28 : 15;
    final double fontSize = MediaQuery.of(context).size.width >= 700 ? 56 : 38;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        String numStr = _animation.value.toStringAsFixed(widget.decimals);
        if (widget.hasPlus) {
          numStr += "+";
        }
        return Container(
          padding: EdgeInsets.only(left: widget.showLeftBorder ? paddingLeft : 0),
          decoration: BoxDecoration(
            border: widget.showLeftBorder
                ? Border(
                    left: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                numStr,
                style: AppTheme.serifHeader(
                  fontSize: fontSize,
                  color: goldColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label.toUpperCase(),
                style: AppTheme.sansBody(
                  fontSize: 9,
                  color: labelColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
