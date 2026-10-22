import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class QuoteSuccessDetailsCard extends StatelessWidget {
  final dynamic quote;
  final bool isDark;
  final Color goldColor;

  const QuoteSuccessDetailsCard({
    super.key,
    required this.quote,
    required this.isDark,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "BOOKING REFERENCE ID",
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quote.publicId,
                    style: AppTheme.serifHeader(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: goldColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                color: goldColor,
                tooltip: "Copy Reference ID",
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: quote.publicId));
                  Get.snackbar(
                    "Copied to Clipboard",
                    "Reference ID ${quote.publicId} copied.",
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
            ],
          ),
          const Divider(height: 24),
          _detailRow(
            "EVENT SERVICE",
            quote.items.firstOrNull?.name ?? "Event Decor",
            isDark,
          ),
          const SizedBox(height: 8),
          _detailRow(
            "EVENT DATE",
            AppFormatters.formatDate(quote.eventDate),
            isDark,
          ),
          const SizedBox(height: 8),
          _detailRow("VENUE LOCATION", quote.location, isDark),
          const SizedBox(height: 8),
          _detailRow(
            "ESTIMATED TOTAL",
            AppFormatters.formatCurrency(quote.grandTotal),
            isDark,
            isBold: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4EBA7A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF4EBA7A).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 14, color: Color(0xFF4EBA7A)),
                const SizedBox(width: 8),
                Text(
                  "1 EVENT PER DAY POLICY: Slot Reserved For Review",
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4EBA7A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
            letterSpacing: 1,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTheme.sansBody(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
