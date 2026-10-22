import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/quotation_controller.dart';
import 'widgets/quote_success_action_buttons.dart';
import 'widgets/quote_success_details_card.dart';

class QuoteSuccessScreen extends StatelessWidget {
  const QuoteSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quoteController = Get.find<QuotationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quote = quoteController.rxCreatedQuotation.value;
    final goldColor = isDark ? AppTheme.darkGold : AppTheme.lightGold;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: goldColor.withValues(alpha: 0.12),
                      border: Border.all(
                        color: goldColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 44,
                      color: goldColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Booking Request Received!",
                    textAlign: TextAlign.center,
                    style: AppTheme.serifHeader(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your event booking has been securely registered in our system. Our decor design team is reviewing your requirements and preparing the styling moodboard.",
                    textAlign: TextAlign.center,
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                      height: 1.6,
                    ),
                  ),
                  if (quote != null) ...[
                    const SizedBox(height: 28),
                    QuoteSuccessDetailsCard(
                      quote: quote,
                      isDark: isDark,
                      goldColor: goldColor,
                    ),
                  ],
                  const SizedBox(height: 36),
                  QuoteSuccessActionButtons(quote: quote, goldColor: goldColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
