import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../controllers/quotation_controller.dart';

class QuoteSuccessScreen extends StatelessWidget {
  const QuoteSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quoteController = Get.find<QuotationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quote = quoteController.rxCreatedQuotation.value;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isDark
                          ? AppTheme.darkGold.withValues(alpha: 0.1)
                          : AppTheme.lightGold.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 40,
                  color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Your quotation is ready.",
                textAlign: TextAlign.center,
                style: AppTheme.serifHeader(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "An itemized proposal has been saved and is ready for download.",
                textAlign: TextAlign.center,
                style: AppTheme.sansBody(
                  fontSize: 13,
                  color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                  height: 1.5,
                ),
              ),
              if (quote != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
                  child: Column(
                    children: [
                      _detailRow(
                        "PROPOSAL ID",
                        quote.publicId.toUpperCase(),
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _detailRow(
                        "EVENT DATE",
                        AppFormatters.formatDate(quote.eventDate),
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _detailRow(
                        "GRAND TOTAL",
                        AppFormatters.formatCurrency(quote.grandTotal),
                        isDark,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 48),
              CustomButton(
                text: "Download PDF proposal",
                onPressed: () async {
                  if (quote != null && quote.pdfUrl.isNotEmpty) {
                    final uri = Uri.parse(quote.pdfUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  } else {
                    Get.snackbar(
                      "Download Error",
                      "PDF file is still uploading or unavailable.",
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: "Return to home",
                isPrimary: false,
                onPressed: () => Get.offAllNamed(AppRoutes.home),
              ),
            ],
          ),
        ),
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
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: AppTheme.sansBody(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
          ),
        ),
      ],
    );
  }
}
