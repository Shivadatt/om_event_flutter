import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../dashboard_chart.dart';

/// Chart display widget rendering historical inquiry statistics.
class InquiriesTrendChart extends StatelessWidget {
  /// Creates a [InquiriesTrendChart] widget instance.
  const InquiriesTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF254235), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "INQUIRIES TREND",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: const Color(0xFFC8A26A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF11211C),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Last 6 Months",
                  style: AppTheme.sansBody(
                    fontSize: 9,
                    color: const Color(0xFFA4A9A7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SizedBox(
            height: 180,
            child: DashboardLineChart(
              dataPoints: [12.0, 19.0, 15.0, 24.0, 18.0, 31.0],
              labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
              lineColor: Color(0xFFC8A26A),
              gradientColor: Color(0xFFC8A26A),
            ),
          ),
        ],
      ),
    );
  }
}
