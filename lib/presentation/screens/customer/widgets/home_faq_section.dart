import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/services/app_config_service.dart';

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
          child: Obx(() {
            final homepage = AppConfigService.to.rxHomepageSettings.value;
            final faqs = homepage.faqs;
            if (faqs.isEmpty) {
              return const SizedBox.shrink();
            }

            if (isDesktop) {
              return Row(
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
                          homepage.faqHeader.isNotEmpty
                              ? homepage.faqHeader
                              : "Before the confetti flies.",
                          style: AppTheme.serifHeader(fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 64),
                  Expanded(
                    flex: 13,
                    child: Column(
                      children:
                          faqs.map((faq) {
                            final map = Map<String, dynamic>.from(faq);
                            return _faqItem(
                              map['question'] ?? '',
                              map['answer'] ?? '',
                            );
                          }).toList(),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
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
                    homepage.faqHeader.isNotEmpty
                        ? homepage.faqHeader
                        : "Before the confetti flies.",
                    style: AppTheme.serifHeader(fontSize: 28),
                  ),
                  const SizedBox(height: 28),
                  Column(
                    children:
                        faqs.map((faq) {
                          final map = Map<String, dynamic>.from(faq);
                          return _faqItem(
                            map['question'] ?? '',
                            map['answer'] ?? '',
                          );
                        }).toList(),
                  ),
                ],
              );
            }
          }),
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
