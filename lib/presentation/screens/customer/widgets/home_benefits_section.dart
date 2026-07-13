import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/domain/entities/settings_entities.dart';

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
      final benefits = homepage.benefits.isNotEmpty
          ? homepage.benefits
          : HomepageSettings.defaultVal().benefits;
      if (benefits.isEmpty) {
        return const SizedBox.shrink();
      }

      int cardIdx = 0;
      List<Widget> cards = benefits.map((b) {
        final map = Map<String, dynamic>.from(b);
        final glowColor = cardIdx % 3 == 0
            ? const Color(0xFF183129) // Deep Emerald glow
            : (cardIdx % 3 == 1 ? AppColors.secondaryAccent : AppColors.highlight); // Champagne / Soft Gold glow
        cardIdx++;

        return _BenefitCard(
          icon: map['icon'] ?? '◇',
          title: map['title'] ?? '',
          description: map['desc'] ?? '',
          glowColor: glowColor,
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
                  padding: EdgeInsets.only(left: idx > 0 ? 20 : 0),
                  child: rowCards[idx],
                ),
              );
            }),
          ),
        );
        if (i + crossAxisCount < cards.length) {
          rows.add(const SizedBox(height: 20));
        }
      }

      final gridWidget = Column(children: rows);

      return Container(
        width: double.infinity,
        color: const Color(0xFF152621), // Secondary Background
        padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: widget.isDesktop ? 110 : 80,
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
                    color: AppColors.secondaryAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.5,
                  ),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFE8A3), Color(0xFFF3D37A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    "EVERYTHING YOUR EVENT NEEDS.\nONE THOUGHTFUL TEAM.",
                    style: GoogleFonts.italiana(
                      fontSize: titleSize,
                      color: Colors.white,
                      height: 1.1,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTheme.sansBody(
                      fontSize: 15,
                      color: AppColors.muted,
                      height: 1.7,
                    ),
                    children: [
                      const TextSpan(text: "Less chasing vendors. "),
                      TextSpan(
                        text: "More",
                        style: AppTheme.sansBody(
                          fontSize: 15,
                          color: AppColors.secondaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: " time being present."),
                    ],
                  ),
                ),
                const SizedBox(height: 56),
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
  final Color glowColor;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.glowColor,
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
        transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(minHeight: 210),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2D27), // Card Background
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.secondaryAccent : AppColors.primaryAccent.withValues(alpha: 0.12),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withValues(alpha: _isHovered ? 0.35 : 0.15),
              blurRadius: _isHovered ? 28 : 12,
              offset: Offset(0, _isHovered ? 10 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondaryAccent, width: 1.2),
                color: AppColors.secondaryAccent.withValues(alpha: 0.04),
              ),
              child: Center(
                child: Text(
                  widget.icon,
                  style: GoogleFonts.italiana(
                    fontSize: 20,
                    color: AppColors.secondaryAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: GoogleFonts.italiana(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: AppTheme.sansBody(
                fontSize: 13.5,
                color: AppColors.muted,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
