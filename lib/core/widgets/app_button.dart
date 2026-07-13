import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';
import '../../core/constants/app_colors.dart';

/// Centralized primary/secondary button component with Awwwards-level transitions.
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.borderRadius = 30,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _isHovered = false;
  late AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() {
      _isHovered = isHovered;
      _scale = isHovered ? 1.02 : 1.0;
    });
    if (isHovered) {
      _shineController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryGradient = const LinearGradient(
      colors: [AppColors.highlight, AppColors.secondaryAccent, AppColors.primaryAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final foregroundColor = widget.isPrimary
        ? const Color(0xFF0F1B18)
        : AppColors.primaryAccent;

    // Glowing border styling
    final borderGradient = widget.isPrimary
        ? Colors.transparent
        : (_isHovered ? AppColors.secondaryAccent : AppColors.primaryAccent.withValues(alpha: 0.4));

    List<BoxShadow>? shadows;
    if ((widget.onPressed != null) && !widget.isLoading) {
      if (widget.isPrimary) {
        shadows = [
          BoxShadow(
            color: AppColors.secondaryAccent.withValues(alpha: _isHovered ? 0.45 : 0.20),
            blurRadius: _isHovered ? 24 : 12,
            spreadRadius: _isHovered ? 1 : -1,
            offset: Offset(0, _isHovered ? 8 : 4),
          )
        ];
      } else if (_isHovered) {
        // Outlined button gold glow on hover
        shadows = [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          )
        ];
      }
    }

    return FocusableActionDetector(
      enabled: widget.onPressed != null && !widget.isLoading,
      onShowFocusHighlight: (_) {},  // focus highlight not used visually
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            if (widget.onPressed != null && !widget.isLoading) {
              widget.onPressed!();
            }
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        label: widget.text,
        enabled: widget.onPressed != null && !widget.isLoading,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _scale = 0.96),
            onTapUp: (_) => setState(() => _scale = _isHovered ? 1.02 : 1.0),
            onTapCancel: () => setState(() => _scale = 1.0),
            onTap: widget.isLoading ? null : widget.onPressed,
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 200),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                transform: Matrix4.translationValues(0.0, _isHovered ? -3.5 : 0.0, 0.0),
                decoration: BoxDecoration(
                  gradient: widget.isPrimary ? primaryGradient : null,
                  color: widget.isPrimary
                      ? null
                      : (_isHovered ? Colors.white.withValues(alpha: 0.05) : Colors.transparent),
                  border: Border.all(
                    color: borderGradient,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: shadows,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shine sweep effect on Hover
                      if (_isHovered)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _shineController,
                            builder: (context, child) {
                              return FractionalTranslation(
                                translation: Offset(-1.5 + (_shineController.value * 3.0), 0.0),
                                child: child,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: widget.isPrimary ? 0.40 : 0.15),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // Button content
                      widget.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  foregroundColor,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.text.toUpperCase(),
                                  style: AppTheme.sansBody(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: foregroundColor,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                if (widget.icon != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    widget.icon,
                                    size: 14,
                                    color: foregroundColor,
                                  ),
                                ] else ...[
                                  // Animated slide-in arrow icon
                                  ClipRect(
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: _isHovered ? 20 : 0,
                                      child: OverflowBox(
                                        maxWidth: 20,
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(width: 6),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 13,
                                              color: foregroundColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ]
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
