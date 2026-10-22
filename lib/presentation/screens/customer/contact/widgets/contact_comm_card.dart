import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';

class ContactCommCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String line1;
  final String line2;
  final Color goldColor;
  final bool isMobile;
  final VoidCallback onTap;

  const ContactCommCard({
    super.key,
    required this.icon,
    required this.title,
    required this.line1,
    required this.line2,
    required this.goldColor,
    required this.isMobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 10,
              vertical: isMobile ? 10 : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: goldColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(icon, size: 13, color: goldColor),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: isMobile ? 10.5 : 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  line1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.sansBody(
                    fontSize: isMobile ? 9 : 9.5,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  line2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.sansBody(
                    fontSize: isMobile ? 9 : 9.5,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
