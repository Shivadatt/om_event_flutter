import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';

class AdminMetricCard extends StatefulWidget {
  final String label;
  final String value;
  final String desc;
  final IconData icon;
  final Color color;

  const AdminMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.desc,
    required this.icon,
    required this.color,
  });

  @override
  State<AdminMetricCard> createState() => _AdminMetricCardState();
}

class _AdminMetricCardState extends State<AdminMetricCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color valueColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color labelColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        transform: _isHovered ? (Matrix4.identity()..translate(0, -6, 0)) : Matrix4.identity(),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? AppColors.primaryAccent.withValues(alpha: 0.3)
                : borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.02),
              blurRadius: _isHovered ? 24 : 12,
              offset: _isHovered ? const Offset(0, 10) : const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label.toUpperCase(),
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    color: labelColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? widget.color.withValues(alpha: 0.2)
                        : widget.color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 18, color: widget.color),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.value,
                    style: AppTheme.serifHeader(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.desc,
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          color: labelColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
