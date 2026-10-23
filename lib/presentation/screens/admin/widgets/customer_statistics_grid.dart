import 'package:flutter/material.dart';
import 'customer_kpi_card.dart';
import 'customer_stats_calculator.dart';

/// Responsive 4-card statistics section for the Customer Directory.
/// Renders 1 row on Desktop/Laptop, and an adaptive 2x2 grid on Tablet and Mobile.
class CustomerStatisticsGrid extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final int totalClients;
  final int vipClients;
  final int corporateClients;
  final double totalRevenue;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryAccent;

  const CustomerStatisticsGrid({
    super.key,
    required this.isMobile,
    required this.isTablet,
    required this.totalClients,
    required this.vipClients,
    required this.corporateClients,
    required this.totalRevenue,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      CustomerKpiCard(
        icon: Icons.people_alt_rounded,
        title: '$totalClients',
        subtitle: 'Total Clients',
        cardColor: cardColor,
        borderColor: borderColor,
        textColor: textColor,
        subtitleColor: subtitleColor,
        primaryAccent: primaryAccent,
      ),
      CustomerKpiCard(
        icon: Icons.workspace_premium_rounded,
        title: '$vipClients',
        subtitle: 'VIP Clients',
        cardColor: cardColor,
        borderColor: borderColor,
        textColor: textColor,
        subtitleColor: subtitleColor,
        primaryAccent: primaryAccent,
      ),
      CustomerKpiCard(
        icon: Icons.business_center_rounded,
        title: '$corporateClients',
        subtitle: 'Corporate Clients',
        cardColor: cardColor,
        borderColor: borderColor,
        textColor: textColor,
        subtitleColor: subtitleColor,
        primaryAccent: primaryAccent,
      ),
      CustomerKpiCard(
        icon: Icons.account_balance_wallet_rounded,
        title: CustomerStatsCalculator.formatRevenueCompact(totalRevenue),
        subtitle: 'Total Revenue',
        cardColor: cardColor,
        borderColor: borderColor,
        textColor: textColor,
        subtitleColor: subtitleColor,
        primaryAccent: primaryAccent,
      ),
    ];

    if (isMobile || isTablet) {
      // 2x2 Grid on Tablet and Mobile matching reference design
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              SizedBox(width: isMobile ? 10 : 14),
              Expanded(child: cards[1]),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 14),
          Row(
            children: [
              Expanded(child: cards[2]),
              SizedBox(width: isMobile ? 10 : 14),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    }

    // 1 Row on Desktop / Laptop
    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 16),
        Expanded(child: cards[1]),
        const SizedBox(width: 16),
        Expanded(child: cards[2]),
        const SizedBox(width: 16),
        Expanded(child: cards[3]),
      ],
    );
  }
}
