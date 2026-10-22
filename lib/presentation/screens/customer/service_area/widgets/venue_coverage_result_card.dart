import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/config/app_theme.dart';

class VenueCoverageResultCard extends StatelessWidget {
  final Map<String, dynamic> checkResult;
  final Color goldColor;
  final VoidCallback onClearResult;

  const VenueCoverageResultCard({
    super.key,
    required this.checkResult,
    required this.goldColor,
    required this.onClearResult,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = checkResult['color'] as Color;
    final statusText = checkResult['status'] as String;
    final zoneText = checkResult['zone'] as String;
    final detailsText = checkResult['details'] as String;
    final feeText = checkResult['fee'] as String;
    final leadTimeText = checkResult['leadTime'] as String;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 15,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  statusText,
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              InkWell(
                onTap: onClearResult,
                child: const Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            zoneText,
            style: GoogleFonts.italiana(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detailsText,
            style: AppTheme.sansBody(
              fontSize: 11,
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 12,
                color: goldColor,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  feeText,
                  style: AppTheme.sansBody(
                    fontSize: 10.5,
                    color: goldColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 12,
                color: Colors.white54,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  leadTimeText,
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
