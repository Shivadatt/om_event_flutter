import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

class AdminSidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const AdminSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isActive ? const Color(0xFF1B332B) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color:
                      isActive
                          ? const Color(0xFFC8A26A)
                          : const Color(0xFFA4A9A7),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTheme.sansBody(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color:
                        isActive
                            ? const Color(0xFFF4F4F4)
                            : const Color(0xFFA4A9A7),
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 3,
                    height: 16,
                    color: const Color(0xFFC8A26A),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
