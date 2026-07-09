import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';

class AdminActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const AdminActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<AdminActionButton> createState() => _AdminActionButtonState();
}

class _AdminActionButtonState extends State<AdminActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color hoverColor = isDark ? AppColors.darkForestSecondary : AppColors.lightForestSecondary;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color labelColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color iconColor = AppColors.primaryAccent;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHovered ? hoverColor : bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? AppColors.primaryAccent.withValues(alpha: 0.6) : borderColor,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAccent.withValues(alpha: _isHovered ? 0.08 : 0.0),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: AppColors.primaryAccent.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 18, color: iconColor),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: AppTheme.sansBody(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: labelColor,
                        letterSpacing: 0.5,
                      ),
                    ),
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
