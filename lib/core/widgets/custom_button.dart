import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = widget.isPrimary
        ? (isDark ? AppTheme.darkGold : AppTheme.lightGold)
        : Colors.transparent;

    final foregroundColor = widget.isPrimary
        ? Colors.white
        : (isDark ? AppTheme.darkInk : AppTheme.lightInk);

    final borderColor = widget.isPrimary
        ? Colors.transparent
        : (isDark ? AppTheme.darkLine : AppTheme.lightLine);

    return GestureDetector(
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
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
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
                        Icon(widget.icon, size: 14, color: foregroundColor),
                      ]
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
