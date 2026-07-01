import 'package:flutter/material.dart';
import 'package:om_event/core/config/app_theme.dart';

class FAQSection extends StatelessWidget {
  final bool isDesktop;
  const FAQSection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "A few good questions",
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Before the confetti flies.",
                            style: AppTheme.serifHeader(fontSize: 32),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 64),
                    Expanded(
                      flex: 13,
                      child: Column(
                        children: [
                          _faqItem(
                            "How far in advance should I book?",
                            "Four to eight weeks is ideal for custom work. For larger weddings, reserve your date three to six months ahead. Short notice? Ask us—we keep a little room for spontaneous magic.",
                          ),
                          _faqItem(
                            "Can I change the colors and materials?",
                            "Absolutely. Every concept can be adapted to your palette, venue and story. Use the canvas builder to share your direction.",
                          ),
                          _faqItem(
                            "What does the starting price include?",
                            "The starting price includes the listed styling, setup and teardown. Your quotation separately displays GST and flat delivery charges.",
                          ),
                          _faqItem(
                            "Do you visit the venue before the event?",
                            "For complex installations and weddings, we schedule a site visit after the discovery call. It helps us verify dimensions, power access and load-in timing.",
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "A few good questions",
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Before the confetti flies.",
                      style: AppTheme.serifHeader(fontSize: 28),
                    ),
                    const SizedBox(height: 28),
                    _faqItem(
                      "How far in advance should I book?",
                      "Four to eight weeks is ideal for custom work. For larger weddings, reserve your date three to six months ahead. Short notice? Ask us—we keep a little room for spontaneous magic.",
                    ),
                    _faqItem(
                      "Can I change the colors and materials?",
                      "Absolutely. Every concept can be adapted to your palette, venue and story. Use the canvas builder to share your direction.",
                    ),
                    _faqItem(
                      "What does the starting price include?",
                      "The starting price includes the listed styling, setup and teardown. Your quotation separately displays GST and flat delivery charges.",
                    ),
                    _faqItem(
                      "Do you visit the venue before the event?",
                      "For complex installations and weddings, we schedule a site visit after the discovery call. It helps us verify dimensions, power access and load-in timing.",
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      childrenPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      children: [
        Text(answer, style: AppTheme.sansBody(fontSize: 13, height: 1.6)),
      ],
    );
  }
}
