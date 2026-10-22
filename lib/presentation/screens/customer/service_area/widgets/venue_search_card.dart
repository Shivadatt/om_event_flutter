import 'package:flutter/material.dart';
import '../../../../../../core/config/app_theme.dart';
import 'venue_coverage_result_card.dart';

class VenueSearchCard extends StatelessWidget {
  final TextEditingController pincodeCtrl;
  final Map<String, dynamic>? checkResult;
  final VoidCallback onCheck;
  final VoidCallback onClearResult;
  final Color goldColor;
  final bool isMobile;

  const VenueSearchCard({
    super.key,
    required this.pincodeCtrl,
    required this.checkResult,
    required this.onCheck,
    required this.onClearResult,
    required this.goldColor,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1713),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: goldColor.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pin_drop_outlined, color: goldColor, size: 14),
              const SizedBox(width: 6),
              Text(
                "Check Venue Coverage",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: pincodeCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    cursorColor: goldColor,
                    onSubmitted: (_) => onCheck(),
                    decoration: InputDecoration(
                      hintText: "e.g. Kadi, 382715, Ahmedabad...",
                      hintStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11.5,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF060F0C),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: goldColor.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: goldColor, width: 1.2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: goldColor,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onCheck,
                  child: Container(
                    height: 38,
                    width: 38,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF091210),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (checkResult != null) ...[
            const SizedBox(height: 12),
            VenueCoverageResultCard(
              checkResult: checkResult!,
              goldColor: goldColor,
              onClearResult: onClearResult,
            ),
          ],
        ],
      ),
    );
  }
}
