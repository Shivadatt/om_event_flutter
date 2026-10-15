import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/presentation/widgets/app_page_container.dart';

class BenefitsSection extends StatefulWidget {
  final bool isDesktop;
  const BenefitsSection({super.key, required this.isDesktop});

  @override
  State<BenefitsSection> createState() => _BenefitsSectionState();
}

enum _BenefitCardLayout { vertical, horizontal }

class _BenefitsSectionState extends State<BenefitsSection> {
  // Canonical 5 benefit items matching Reference Image
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

  Widget _buildBenefitCardItem(
    List<Map<String, dynamic>> benefitsList,
    int index,
    _BenefitCardLayout layoutMode, {
    bool isCompact = false,
    bool isMobile = false,
  }) {
    if (index >= benefitsList.length) return const SizedBox.shrink();
    final b = benefitsList[index];
    final glowColor = index % 3 == 0
        ? const Color(0xFF183129)
        : (index % 3 == 1 ? AppColors.secondaryAccent : AppColors.highlight);

    return _BenefitCard(
      iconKey: b['icon']?.toString() ?? '',
      title: b['title']?.toString() ?? '',
      description: b['desc']?.toString() ?? '',
      glowColor: glowColor,
      layoutMode: layoutMode,
      isCompact: isCompact,
      isMobile: isMobile,
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    List<Map<String, dynamic>> benefitsList,
    double width,
  ) {
    if (width >= 960) {
      // Desktop & Laptop: 5 columns in 1 horizontal row
      final double gap = width >= 1200 ? 14.0 : 10.0;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(benefitsList.length, (idx) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: idx > 0 ? gap : 0),
              child: _buildBenefitCardItem(
                benefitsList,
                idx,
                _BenefitCardLayout.vertical,
                isCompact: width < 1200,
              ),
            ),
          );
        }),
      );
    } else if (width >= 600) {
      // Tablet: 2-column grid, 5th card centered on row 3
      const double gap = 16.0;
      return LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - gap) / 2;
          return Column(
            children: [
              // Row 1: Cards 0 and 1
              Row(
                children: [
                  Expanded(
                    child: _buildBenefitCardItem(benefitsList, 0, _BenefitCardLayout.horizontal),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: _buildBenefitCardItem(benefitsList, 1, _BenefitCardLayout.horizontal),
                  ),
                ],
              ),
              const SizedBox(height: gap),
              // Row 2: Cards 2 and 3
              Row(
                children: [
                  Expanded(
                    child: _buildBenefitCardItem(benefitsList, 2, _BenefitCardLayout.horizontal),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: _buildBenefitCardItem(benefitsList, 3, _BenefitCardLayout.horizontal),
                  ),
                ],
              ),
              if (benefitsList.length > 4) ...[
                const SizedBox(height: gap),
                // Row 3: Card 4 centered
                Center(
                  child: SizedBox(
                    width: cardWidth,
                    child: _buildBenefitCardItem(benefitsList, 4, _BenefitCardLayout.horizontal),
                  ),
                ),
              ],
            ],
          );
        },
      );
    } else {
      // Mobile (< 600px): Single vertical column of all cards
      const double gap = 10.0;
      return Column(
        children: List.generate(benefitsList.length, (idx) {
          return Padding(
            padding: EdgeInsets.only(bottom: idx < benefitsList.length - 1 ? gap : 0),
            child: _buildBenefitCardItem(
              benefitsList,
              idx,
              _BenefitCardLayout.horizontal,
              isMobile: true,
            ),
          );
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double hPad = AppPageContainer.horizontalPadding(context);
    final double titleSize = width >= 960
        ? (width * 0.034).clamp(32.0, 46.0)
        : (width >= 600 ? 28.0 : 23.0);

    return Obx(() {
      final homepage = AppConfigService.to.rxHomepageSettings.value;
      final rawBenefits = homepage.benefits.isNotEmpty
          ? homepage.benefits
          : _canonicalBenefits;

      final List<Map<String, dynamic>> benefitsList =
          rawBenefits.map((b) => Map<String, dynamic>.from(b)).toList();
      if (benefitsList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        color: const Color(0xFF152621), // Secondary Background
        padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: width >= 960 ? 44.0 : (width >= 600 ? 34.0 : 26.0),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: AppPageContainer.maxContentWidth),
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
                      fontSize: width < 600 ? 12.5 : 14.0,
                      color: AppColors.muted,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(text: "Less chasing vendors. "),
                      TextSpan(
                        text: "More",
                        style: AppTheme.sansBody(
                          fontSize: width < 600 ? 12.5 : 14.0,
                          color: AppColors.secondaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: " time being present."),
                    ],
                  ),
                ),
                SizedBox(height: width >= 960 ? 32.0 : 24.0),
                _buildResponsiveGrid(context, benefitsList, width),
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
  final _BenefitCardLayout layoutMode;
  final bool isCompact;
  final bool isMobile;

  const _BenefitCard({
    required this.iconKey,
    required this.title,
    required this.description,
    required this.glowColor,
    this.layoutMode = _BenefitCardLayout.vertical,
    this.isCompact = false,
    this.isMobile = false,
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

    final cardDecoration = BoxDecoration(
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
    );

    if (widget.layoutMode == _BenefitCardLayout.horizontal) {
      // Horizontal Card Layout for Tablet & Mobile
      final double iconBoxSize = widget.isMobile ? 36.0 : 42.0;
      final double iconSize = widget.isMobile ? 18.0 : 20.0;
      final double titleSize = widget.isMobile ? 13.5 : 14.5;
      final double descSize = widget.isMobile ? 11.0 : 11.8;

      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 14.0 : 18.0,
            vertical: widget.isMobile ? 12.0 : 16.0,
          ),
          decoration: cardDecoration,
          child: Row(
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondaryAccent.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  color: AppColors.secondaryAccent.withValues(alpha: 0.08),
                ),
                child: Center(
                  child: Icon(
                    iconData,
                    color: AppColors.secondaryAccent,
                    size: iconSize,
                  ),
                ),
              ),
              SizedBox(width: widget.isMobile ? 12.0 : 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: AppTheme.sansBody(
                        fontSize: titleSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.description,
                      style: AppTheme.sansBody(
                        fontSize: descSize,
                        color: AppColors.muted.withValues(alpha: 0.85),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Vertical Card Layout for Desktop & Laptop
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isCompact ? 12.0 : 16.0,
          vertical: widget.isCompact ? 18.0 : 22.0,
        ),
        constraints: BoxConstraints(minHeight: widget.isCompact ? 170.0 : 185.0),
        decoration: cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: widget.isCompact ? 36.0 : 40.0,
              height: widget.isCompact ? 36.0 : 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondaryAccent.withValues(alpha: 0.5),
                  width: 1.2,
                ),
                color: AppColors.secondaryAccent.withValues(alpha: 0.08),
              ),
              child: Center(
                child: Icon(
                  iconData,
                  color: AppColors.secondaryAccent,
                  size: widget.isCompact ? 18.0 : 20.0,
                ),
              ),
            ),
            SizedBox(height: widget.isCompact ? 12.0 : 16.0),
            Text(
              widget.title,
              style: AppTheme.sansBody(
                fontSize: widget.isCompact ? 13.5 : 14.5,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: widget.isCompact ? 6.0 : 8.0),
            Text(
              widget.description,
              style: AppTheme.sansBody(
                fontSize: widget.isCompact ? 11.0 : 11.5,
                color: AppColors.muted.withValues(alpha: 0.8),
                height: 1.4,
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

