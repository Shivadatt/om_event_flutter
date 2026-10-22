import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/config/app_theme.dart';

class ServiceAreaZonesSection extends StatelessWidget {
  final bool isDesktop;
  final bool isLaptop;
  final bool isTablet;
  final bool isMobile;
  final double availableWidth;
  final Color goldColor;

  const ServiceAreaZonesSection({
    super.key,
    required this.isDesktop,
    required this.isLaptop,
    required this.isTablet,
    required this.isMobile,
    required this.availableWidth,
    required this.goldColor,
  });

  Widget _buildZoneCard({
    required IconData icon,
    required String title,
    required String locations,
    required String allowanceBadge,
    required Color badgeColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 14,
        vertical: isMobile ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: goldColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.italiana(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            locations,
            style: AppTheme.sansBody(
              fontSize: isMobile ? 10 : 10.5,
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              allowanceBadge,
              style: AppTheme.sansBody(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zone1 = _buildZoneCard(
      icon: Icons.local_shipping_outlined,
      title: "Zone 1: Primary Delivery Hubs",
      locations:
          "Kadi, Kalol, Mehsana, Nandasan, Ahmedabad Metro, Gandhinagar",
      allowanceBadge: "₹500 standard delivery",
      badgeColor: const Color(0xFF4EBA7A),
    );

    final zone2 = _buildZoneCard(
      icon: Icons.location_on_outlined,
      title: "Zone 2: Extended Gujarat Districts",
      locations:
          "Sanand, Bavla, Viramgam, Himatnagar, Vijapur, Unjha, Patan, etc.",
      allowanceBadge: "Nominal travel allowance",
      badgeColor: const Color(0xFFE2C074),
    );

    final zone3 = _buildZoneCard(
      icon: Icons.workspace_premium_outlined,
      title: "Zone 3: Royal Heritage & Destinations",
      locations:
          "Udaipur, Mount Abu, Surat, Bhavnagar, Jamnagar and heritage venues.",
      allowanceBadge: "Custom logistics & accommodation",
      badgeColor: const Color(0xFF64B5F6),
    );

    final showThreeInRow =
        isDesktop || isLaptop || (isTablet && availableWidth >= 740);
    final showTwoPlusOne = isTablet && availableWidth < 740;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Coverage Zones",
              style: GoogleFonts.italiana(
                fontSize:
                    isDesktop ? 21 : (isLaptop ? 20 : (isTablet ? 19 : 18)),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 1.5,
              decoration: BoxDecoration(
                color: goldColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (showThreeInRow)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: zone1),
                const SizedBox(width: 12),
                Expanded(child: zone2),
                const SizedBox(width: 12),
                Expanded(child: zone3),
              ],
            ),
          )
        else if (showTwoPlusOne)
          Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: zone1),
                    const SizedBox(width: 12),
                    Expanded(child: zone2),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              zone3,
            ],
          )
        else
          Column(
            children: [
              zone1,
              const SizedBox(height: 12),
              zone2,
              const SizedBox(height: 12),
              zone3,
            ],
          ),
      ],
    );
  }
}
