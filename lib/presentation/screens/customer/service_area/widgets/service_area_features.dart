import 'package:flutter/material.dart';
import '../../../../../../core/config/app_theme.dart';

class ServiceAreaFeatures extends StatelessWidget {
  final Color goldColor;
  final bool isDesktop;
  final bool isLaptop;
  final bool isTablet;
  final bool isMobile;

  const ServiceAreaFeatures({
    super.key,
    required this.goldColor,
    required this.isDesktop,
    required this.isLaptop,
    required this.isTablet,
    required this.isMobile,
  });

  Widget _buildItem({
    required IconData icon,
    required String line1,
    required String line2,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF091612),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: goldColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 16 : 18, color: goldColor),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line1,
                  style: AppTheme.sansBody(
                    fontSize: compact ? 9.5 : 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  line2,
                  style: AppTheme.sansBody(
                    fontSize: compact ? 8.5 : 9.5,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: Icons.verified_outlined,
        line1: "Verified Coverage",
        line2: "Across Gujarat",
      ),
      (
        icon: Icons.directions_car_outlined,
        line1: "Custom Travel",
        line2: "Arrangements",
      ),
      (
        icon: Icons.groups_outlined,
        line1: "Dedicated On-Site",
        line2: "Crew & Supervisor",
      ),
      (
        icon: Icons.workspace_premium_outlined,
        line1: "Palaces & Royal",
        line2: "Destinations",
      ),
    ];

    if (isDesktop || isTablet) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            items
                .map(
                  (it) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildItem(
                        icon: it.icon,
                        line1: it.line1,
                        line2: it.line2,
                      ),
                    ),
                  ),
                )
                .toList(),
      );
    } else if (isLaptop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            items
                .map(
                  (it) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _buildItem(
                        icon: it.icon,
                        line1: it.line1,
                        line2: it.line2,
                        compact: true,
                      ),
                    ),
                  ),
                )
                .toList(),
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildItem(
                  icon: items[0].icon,
                  line1: items[0].line1,
                  line2: items[0].line2,
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildItem(
                  icon: items[1].icon,
                  line1: items[1].line1,
                  line2: items[1].line2,
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildItem(
                  icon: items[2].icon,
                  line1: items[2].line1,
                  line2: items[2].line2,
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildItem(
                  icon: items[3].icon,
                  line1: items[3].line1,
                  line2: items[3].line2,
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}
