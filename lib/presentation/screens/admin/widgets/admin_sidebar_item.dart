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

    final Color activeBg = isDark ? const Color(0x1FDFBA73) : const Color(0x0FDFBA73); // Champagne gold accent background
    final Color hoverBg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);
    final Color activeColor = isDark ? const Color(0xFFDFBA73) : const Color(0xFFD4AF37); // Champagne Gold
    final Color inactiveColor = isDark ? const Color(0xFFAAB4AE) : const Color(0xFF6B7280);

    Widget content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 0 : 16,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment:
            widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (!widget.isCollapsed) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 3,
              height: widget.isActive ? 16 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
                
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.isActive ? 8 : 11,
            ),
          ],
          AnimatedScale(
            scale: _isHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.isActive ? activeColor : (_isHovered ? activeColor : inactiveColor),
            ),
          ),
          if (!widget.isCollapsed) ...[
            const SizedBox(width: 12),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTheme.sansBody(
                fontSize: 13,
                fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
                color: widget.isActive
                    ? (isDark ? Colors.white : const Color(0xFF090A0D))
                    : (_isHovered
                        ? (isDark ? Colors.white : const Color(0xFF090A0D))
                        : inactiveColor),
              ),
              child: Text(widget.label),
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
      margin: const EdgeInsets.only(bottom: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isActive ? activeBg : (_isHovered ? hoverBg : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isActive
                  ? activeColor.withValues(alpha: 0.15)
                  : (_isHovered ? activeColor.withValues(alpha: 0.05) : Colors.transparent),
              width: 1,
            ),
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
