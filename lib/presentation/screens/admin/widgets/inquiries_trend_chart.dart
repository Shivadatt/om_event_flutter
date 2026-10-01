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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101C16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3328), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "BOOKING TREND",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF182820),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Last 6 Months",
                      style: AppTheme.sansBody(
                        fontSize: 9.5,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 12, color: Color(0xFFD4AF37)),
                  ],
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
