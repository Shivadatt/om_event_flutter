import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

class AdminSidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  const AdminSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.isCollapsed = false,
    required this.onTap,
  });

  @override
  State<AdminSidebarItem> createState() => _AdminSidebarItemState();
}

class _AdminSidebarItemState extends State<AdminSidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color activeBg = const Color(0xFFC8A26A); // Warm gold pill
    final Color hoverBg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);
    final Color activeColor = const Color(0xFF0C1410); // Dark text on gold pill
    final Color inactiveColor = isDark ? const Color(0xFFAAB4AE) : const Color(0xFF6B7280);

    Widget content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 0 : 12,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment:
            widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(
            widget.icon,
            size: 17,
            color: widget.isActive ? activeColor : (_isHovered ? const Color(0xFFD4AF37) : inactiveColor),
          ),
          if (!widget.isCollapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.label,
                style: AppTheme.sansBody(
                  fontSize: 12,
                  fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
                  color: widget.isActive
                      ? activeColor
                      : (_isHovered ? Colors.white : inactiveColor),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );

    if (widget.isCollapsed) {
      content = Tooltip(
        message: widget.label,
        preferBelow: false,
        textStyle: AppTheme.sansBody(fontSize: 12, color: isDark ? Colors.white : Colors.black),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161920) : const Color(0xFFFAFAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? const Color(0x1AFFFFFF) : const Color(0x0F000000)),
        ),
        child: content,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.isActive ? activeBg : (_isHovered ? hoverBg : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(10),
              hoverColor: Colors.transparent,
              splashColor: activeColor.withValues(alpha: 0.1),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
