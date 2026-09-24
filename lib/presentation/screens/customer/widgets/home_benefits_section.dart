import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/services/app_config_service.dart';

class BenefitsSection extends StatefulWidget {
  final bool isDesktop;
  const BenefitsSection({super.key, required this.isDesktop});

  @override
  State<BenefitsSection> createState() => _BenefitsSectionState();
}

class _BenefitsSectionState extends State<BenefitsSection> {
  // Canonical 5 benefit items matching Reference Image 1
  static const List<Map<String, dynamic>> _canonicalBenefits = [
    {
      'icon': 'heart',
      'title': 'Personalized Design',
      'desc': 'Unique themes for your special moments',
    },
    {
      'icon': 'tag',
      'title': 'Clear & Fair Pricing',
      'desc': 'Transparent quotes with no hidden charges',
    },
    {
      'icon': 'team',
      'title': 'One Accountable Team',
      'desc': 'Planning to setup, we handle everything',
    },
    {
      'icon': 'shield',
      'title': 'Premium Quality',
      'desc': 'High-quality decor with attention-to-detail',
    },
    {
      'icon': 'clock',
      'title': 'On-Time Setup',
      'desc': 'Punctual and professional service you can trust',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double hPad = width >= 1440 ? 48.0 : (width >= 1000 ? 32.0 : 16.0);
    final double titleSize = width >= 700 ? (width * 0.038).clamp(32.0, 52.0) : 26.0;

    return Obx(() {
      final homepage = AppConfigService.to.rxHomepageSettings.value;
      final rawBenefits = homepage.benefits.isNotEmpty
          ? homepage.benefits
          : _canonicalBenefits;

      // Ensure we display benefits gracefully across the responsive columns
      final List<Map<String, dynamic>> benefitsList =
          rawBenefits.map((b) => Map<String, dynamic>.from(b)).toList();
      if (benefitsList.isEmpty) {
        return const SizedBox.shrink();
      }

      // Responsive cross-axis count:
      // Large Desktop (>=1150px): Fits all benefits (up to 6) in 1 balanced row
      // Tablet (750-1149px): 3 columns
      // Mobile (<750px): 2 columns
      final int crossAxisCount = width >= 1150
          ? (benefitsList.length <= 6 ? benefitsList.length : 5)
          : (width >= 750 ? 3 : 2);

      int cardIdx = 0;
      List<Widget> cards = benefitsList.map((b) {
        final glowColor = cardIdx % 3 == 0
            ? const Color(0xFF183129)
            : (cardIdx % 3 == 1 ? AppColors.secondaryAccent : AppColors.highlight);
        cardIdx++;

        return _BenefitCard(
          iconKey: b['icon']?.toString() ?? '',
          title: b['title']?.toString() ?? '',
          description: b['desc']?.toString() ?? '',
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
                  padding: EdgeInsets.only(left: idx > 0 ? 14 : 0),
                  child: rowCards[idx],
                ),
              );
            }),
          ),
        );
        if (i + crossAxisCount < cards.length) {
          rows.add(const SizedBox(height: 14));
        }
      }

      final gridWidget = Column(children: rows);

      return Container(
        width: double.infinity,
        color: const Color(0xFF152621), // Secondary Background
        padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: widget.isDesktop ? 44.0 : 32.0,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                      height: 1.15,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTheme.sansBody(
                      fontSize: 14,
                      color: AppColors.muted,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(text: "Less chasing vendors. "),
                      TextSpan(
                        text: "More",
                        style: AppTheme.sansBody(
                          fontSize: 14,
                          color: AppColors.secondaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: " time being present."),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
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
  final String iconKey;
  final String title;
  final String description;
  final Color glowColor;

  const _BenefitCard({
    required this.iconKey,
    required this.title,
    required this.description,
    required this.glowColor,
  });

  @override
  State<_BenefitCard> createState() => _BenefitCardState();
}

class _BenefitCardState extends State<_BenefitCard> {
  bool _isHovered = false;

  IconData _resolveIcon(String key, String title) {
    final lower = "${key.toLowerCase()} ${title.toLowerCase()}";
    if (lower.contains("heart") || lower.contains("personal")) {
      return Icons.auto_awesome_rounded;
    }
    if (lower.contains("tag") || lower.contains("pricing") || lower.contains("price")) {
      return Icons.verified_outlined;
    }
    if (lower.contains("team") || lower.contains("accountable")) {
      return Icons.groups_outlined;
    }
    if (lower.contains("shield") || lower.contains("quality")) {
      return Icons.shield_outlined;
    }
    if (lower.contains("clock") || lower.contains("time") || lower.contains("setup")) {
      return Icons.headset_mic_outlined;
    }
    return Icons.star_border_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _resolveIcon(widget.iconKey, widget.title);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        constraints: const BoxConstraints(minHeight: 180),
        decoration: BoxDecoration(
          color: const Color(0xFF13221C), // Card Background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? AppColors.secondaryAccent : AppColors.secondaryAccent.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withValues(alpha: _isHovered ? 0.3 : 0.08),
              blurRadius: _isHovered ? 20 : 8,
              offset: Offset(0, _isHovered ? 8 : 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondaryAccent.withValues(alpha: 0.5), width: 1.2),
                color: AppColors.secondaryAccent.withValues(alpha: 0.08),
              ),
              child: Center(
                child: Icon(
                  iconData,
                  color: AppColors.secondaryAccent,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: AppTheme.sansBody(
                fontSize: 14.5,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: AppTheme.sansBody(
                fontSize: 11.5,
                color: AppColors.muted.withValues(alpha: 0.8),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
