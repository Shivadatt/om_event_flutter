import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Centralized primary/secondary button component.
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
    this.borderRadius = 10,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  double _scale = 1.0;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor =
        widget.isPrimary
            ? (isDark ? AppTheme.darkGold : AppTheme.lightGold)
            : Colors.transparent;

    final foregroundColor =
        widget.isPrimary
            ? Colors.white
            : (isDark ? AppTheme.darkInk : AppTheme.lightInk);

    final borderColor =
        _isFocused
            ? (isDark ? AppTheme.darkGold : AppTheme.lightGold)
            : (widget.isPrimary
                ? Colors.transparent
                : (isDark ? AppTheme.darkLine : AppTheme.lightLine));

    return FocusableActionDetector(
      enabled: widget.onPressed != null && !widget.isLoading,
      onShowFocusHighlight: (value) => setState(() => _isFocused = value),
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
        child: GestureDetector(
          onTapDown: (_) => setState(() => _scale = 0.96),
          onTapUp: (_) => setState(() => _scale = 1.0),
          onTapCancel: () => setState(() => _scale = 1.0),
          onTap: widget.isLoading ? null : widget.onPressed,
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 150),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(
                  color: borderColor,
                  width: _isFocused ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow:
                    _isFocused
                        ? [
                          BoxShadow(
                            color: (isDark
                                    ? AppTheme.darkGold
                                    : AppTheme.lightGold)
                                .withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ]
                        : null,
              ),
              child: Center(
                child:
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
                          children: [
                            Text(
                              widget.text.toUpperCase(),
                              style: AppTheme.sansBody(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: foregroundColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            if (widget.icon != null) ...[
                              const SizedBox(width: 32),
                              Icon(
                                widget.icon,
                                size: 14,
                                color: foregroundColor,
                              ),
                            ],
                          ],
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
