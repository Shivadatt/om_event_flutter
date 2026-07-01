import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

class AdminActionButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF162822),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF254235), width: 1),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, size: 16, color: const Color(0xFFC8A26A)),
      label: Text(
        label,
        style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
