import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single metric KPI card for the Admin Dashboard.
class DashboardKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final String desc;
  final IconData icon;
  final bool isCompact;

  const DashboardKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    required this.desc,
    required this.icon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF101C16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3328), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: isCompact ? 8.5 : 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: isCompact ? 0.8 : 1.2,
                    color: Colors.white60,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: isCompact ? 24 : 28,
                height: isCompact ? 24 : 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF182820),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  icon,
                  size: isCompact ? 13 : 15,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: isCompact ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (trend != null) ...[
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    trend!,
                    style: GoogleFonts.dmSans(
                      fontSize: isCompact ? 9 : 10,
                      fontWeight: FontWeight.w600,
                      color: trend!.contains('+') || trend!.contains('▲')
                          ? const Color(0xFF22C55E)
                          : Colors.white60,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          Text(
            desc,
            style: GoogleFonts.dmSans(
              fontSize: isCompact ? 8.5 : 9.5,
              color: Colors.white38,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
