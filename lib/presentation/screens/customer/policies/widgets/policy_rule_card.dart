import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';

class PolicySectionHeader extends StatelessWidget {
  final String subtitle;
  final String title;
  final Color goldColor;

  const PolicySectionHeader({
    super.key,
    required this.subtitle,
    required this.title,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: AppTheme.sansBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: goldColor,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.italiana(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class PolicyRuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const PolicyRuleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF152621),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: accentColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.italiana(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTheme.sansBody(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
