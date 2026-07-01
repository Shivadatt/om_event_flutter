import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/services/app_config_service.dart';

class BenefitsSection extends StatefulWidget {
  final bool isDesktop;
  const BenefitsSection({super.key, required this.isDesktop});

  @override
  State<BenefitsSection> createState() => _BenefitsSectionState();
}

class _BenefitsSectionState extends State<BenefitsSection> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width >= 1000 ? 3 : (width >= 700 ? 2 : 1);
    final double hPad = width >= 1000 ? 110.0 : 24.0;
    final double titleSize =
        widget.isDesktop ? (width * 0.044).clamp(42.0, 67.0) : 36.0;

    return Obx(() {
      final homepage = AppConfigService.to.rxHomepageSettings.value;
      final benefits = homepage.benefits;
      if (benefits.isEmpty) {
        return const SizedBox.shrink();
      }

      List<Widget> cards =
          benefits.map((b) {
            final map = Map<String, dynamic>.from(b);
            return _BenefitCard(
              icon: map['icon'] ?? '◇',
              title: map['title'] ?? '',
              description: map['desc'] ?? '',
            );
          }).toList();

      List<Widget> rows = [];
      for (int i = 0; i < cards.length; i += crossAxisCount) {
        final rowCards = cards.sublist(
          i,
          (i + crossAxisCount).clamp(0, cards.length),
        );
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(rowCards.length, (idx) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: idx > 0 ? 16 : 0),
                  child: rowCards[idx],
                ),
              );
            }),
          ),
        );
        if (i + crossAxisCount < cards.length) {
          rows.add(const SizedBox(height: 16));
        }
      }

      final gridWidget = Column(children: rows);

      return Container(
        width: double.infinity,
        color: const Color(0xFF1A2420),
        padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: widget.isDesktop ? 105 : 80,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "WHY CELEBRATE WITH US",
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    color: const Color(0xFFD6B080),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.italiana(
                      fontSize: titleSize,
                      color: const Color(0xFFF2EEE6),
                      height: 1.0,
                    ),
                    children: const [
                      TextSpan(text: "Everything your event needs.\n"),
                      TextSpan(
                        text: "One thoughtful team.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFD3AD7B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTheme.sansBody(
                      fontSize: 14,
                      color: const Color(0xFF6D746F),
                      height: 1.7,
                    ),
                    children: [
                      const TextSpan(text: "Less chasing vendors. "),
                      TextSpan(
                        text: "More",
                        style: AppTheme.sansBody(
                          fontSize: 14,
                          color: const Color(0xFFD3AD7B),
                        ),
                      ),
                      const TextSpan(text: " time being present."),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                gridWidget,
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _BenefitCard extends StatefulWidget {
  final String icon;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_BenefitCard> createState() => _BenefitCardState();
}

class _BenefitCardState extends State<_BenefitCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.all(30),
        constraints: const BoxConstraints(minHeight: 190),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2C27),
          border: Border.all(
            color:
                _isHovered ? const Color(0xFFAA7C4B) : const Color(0xFF243028),
            width: 1,
          ),
          boxShadow:
              _isHovered
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 45,
                      offset: const Offset(0, 18),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFAA7C4B), width: 1),
              ),
              child: Center(
                child: Text(
                  widget.icon,
                  style: GoogleFonts.italiana(
                    fontSize: 20,
                    color: const Color(0xFFAA7C4B),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: GoogleFonts.italiana(
                fontSize: 22,
                color: const Color(0xFFF2EEE6),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              widget.description,
              style: AppTheme.sansBody(
                fontSize: 12,
                color: const Color(0xFF6D746F),
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
