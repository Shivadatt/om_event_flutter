import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/domain/entities/settings_entities.dart';

class FAQSection extends StatelessWidget {
  final bool isDesktop;
  const FAQSection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    return Material(
      color: const Color(0xFF183129), // Section Background
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: isDesktop ? 100 : 70,
        ),
        child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Obx(() {
            final homepage = AppConfigService.to.rxHomepageSettings.value;
            final faqs = homepage.faqs.isNotEmpty
                ? homepage.faqs
                : HomepageSettings.defaultVal().faqs;
            if (faqs.isEmpty) {
              return const SizedBox.shrink();
            }

            final headingWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "A FEW GOOD QUESTIONS",
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    color: AppColors.secondaryAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.5,
                  ),
                ),
                const SizedBox(height: 12),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFE8A3), Color(0xFFF3D37A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    homepage.faqHeader.isNotEmpty
                        ? homepage.faqHeader.toUpperCase()
                        : "BEFORE THE CONFETTI FLIES.",
                    style: GoogleFonts.italiana(
                      fontSize: isDesktop ? 34 : 26,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            );

            final faqsListWidget = Column(
              children: faqs.map((faq) {
                final map = Map<String, dynamic>.from(faq);
                return _faqItem(
                  map['question'] ?? '',
                  map['answer'] ?? '',
                );
              }).toList(),
            );

            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: headingWidget,
                  ),
                  const SizedBox(width: 64),
                  Expanded(
                    flex: 13,
                    child: faqsListWidget,
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headingWidget,
                  const SizedBox(height: 36),
                  faqsListWidget,
                ],
              );
            }
          }),
        ),
      ),
    ),
  );
}

  Widget _faqItem(String question, String answer) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.secondaryAccent.withValues(alpha: 0.18),
              width: 1.2,
            ),
          ),
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.italiana(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          collapsedIconColor: AppColors.secondaryAccent,
          iconColor: AppColors.secondaryAccent,
          childrenPadding: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
          children: [
            Text(
              answer,
              style: AppTheme.sansBody(
                fontSize: 13.5,
                height: 1.6,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
