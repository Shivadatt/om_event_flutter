import 'package:flutter/material.dart';
import '../../../../core/utils/navigation_helper.dart';
import 'admin_layout.dart';

class AdminBackButton extends StatefulWidget {
  final Color? color;
  const AdminBackButton({super.key, this.color});

  @override
  State<AdminBackButton> createState() => _AdminBackButtonState();
}

class _AdminBackButtonState extends State<AdminBackButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // If the back button is loaded inside AdminLayout (where the AdminSidebar drawer is visible),
    // we do not show the back button.
    final bool isInsideDrawer = AdminLayoutScope.of(context);
    if (isInsideDrawer) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0x7311141A) : const Color(0xB5FFFFFF);
    final Color hoverColor = isDark ? const Color(0xFF1C1F26) : const Color(0xFFFAFAFB);
    final Color borderColor = isDark ? const Color(0x1AFFFFFF) : const Color(0x1F000000);
    final Color iconColor = widget.color ?? const Color(0xFFD4AF37); // Luxury Gold

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _isHovered ? hoverColor : bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: InkWell(
            onTap: () => NavigationHelper.safeBack(context),
            customBorder: const CircleBorder(),
            child: Center(
              child: Icon(
                Icons.arrow_back_rounded,
                size: 16,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
