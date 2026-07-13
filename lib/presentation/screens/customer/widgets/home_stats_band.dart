import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/domain/entities/settings_entities.dart';

class _StatItem {
  final double targetValue;
  final String label;
  final bool hasPlus;
  final int decimals;

  const _StatItem({
    required this.targetValue,
    required this.label,
    this.hasPlus = true,
    this.decimals = 0,
  });
}

class AnimatedStatsBand extends StatelessWidget {
  final bool isDesktop;
  const AnimatedStatsBand({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = width >= 1000 ? 64.0 : 24.0;

    return Obx(() {
      final rawStats = AppConfigService.to.rxStatisticsSettings.value;
      // Fall back to defaults when Firebase hasn't been configured yet
      final defaults = StatisticsSettings.defaultVal();
      final stats = (rawStats.completedEvents == 0 &&
              rawStats.happyClients == 0 &&
              rawStats.cities == 0 &&
              rawStats.years == 0)
          ? defaults
          : rawStats;
      final list = [
        _StatItem(
          targetValue: stats.completedEvents.toDouble(),
          label: "Completed Events",
          hasPlus: true,
          decimals: 0,
        ),
        _StatItem(
          targetValue: stats.happyClients.toDouble(),
          label: "Happy Clients",
          hasPlus: true,
          decimals: 0,
        ),
        _StatItem(
          targetValue: stats.cities.toDouble(),
          label: "Cities Reached",
          hasPlus: true,
          decimals: 0,
        ),
        _StatItem(
          targetValue: stats.years.toDouble(),
          label: "Years of Curation",
          hasPlus: true,
          decimals: 0,
        ),
      ];

      final containerDecoration = BoxDecoration(
        color: const Color(0xFF1B2D27).withValues(alpha: 0.55), // Card Background
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.22), // Champagne Gold
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.secondaryAccent.withValues(alpha: 0.03),
            blurRadius: 16,
            spreadRadius: -1,
          )
        ],
      );

      Widget content;
      if (width >= 700) {
        content = Container(
          decoration: containerDecoration,
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Row(
            children: List.generate(list.length, (index) {
              final s = list[index];
              return Expanded(
                child: _AnimatedStatTile(
                  targetValue: s.targetValue,
                  label: s.label,
                  hasPlus: s.hasPlus,
                  decimals: s.decimals,
                  showLeftBorder: index > 0,
                ),
              );
            }),
          ),
        );
      } else {
        // Mobile split Layout
        final row1 = list.sublist(0, 2);
        final row2 = list.sublist(2, 4);

        content = Container(
          decoration: containerDecoration,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          child: Column(
            children: [
              Row(
                children: List.generate(row1.length, (index) {
                  final s = row1[index];
                  return Expanded(
                    child: _AnimatedStatTile(
                      targetValue: s.targetValue,
                      label: s.label,
                      hasPlus: s.hasPlus,
                      decimals: s.decimals,
                      showLeftBorder: index > 0,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              Row(
                children: List.generate(row2.length, (index) {
                  final s = row2[index];
                  return Expanded(
                    child: _AnimatedStatTile(
                      targetValue: s.targetValue,
                      label: s.label,
                      hasPlus: s.hasPlus,
                      decimals: s.decimals,
                      showLeftBorder: index > 0,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }

      return Container(
        color: const Color(0xFF0F1B18), // Primary Background
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: 36,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: content,
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _AnimatedStatTile extends StatefulWidget {
  final double targetValue;
  final String label;
  final bool hasPlus;
  final int decimals;
  final bool showLeftBorder;

  const _AnimatedStatTile({
    required this.targetValue,
    required this.label,
    this.hasPlus = true,
    this.decimals = 0,
    required this.showLeftBorder,
  });

  @override
  State<_AnimatedStatTile> createState() => _AnimatedStatTileState();
}

class _AnimatedStatTileState extends State<_AnimatedStatTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.targetValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedStatTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _animation = Tween<double>(begin: 0, end: widget.targetValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = AppColors.secondaryAccent.withValues(alpha: 0.12); // Champagne Gold

    return Container(
      decoration: BoxDecoration(
        border: widget.showLeftBorder
            ? Border(left: BorderSide(color: dividerColor, width: 1.2))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              String displayVal = _animation.value.toStringAsFixed(
                widget.decimals,
              );
              if (widget.hasPlus) displayVal += "+";
              return Text(
                displayVal,
                style: GoogleFonts.italiana(
                  fontSize: MediaQuery.of(context).size.width >= 600 ? 54 : 36,
                  color: AppColors.secondaryAccent, // Champagne Gold
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            widget.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTheme.sansBody(
              fontSize: 9,
              color: AppColors.muted.withValues(alpha: 0.65),
              fontWeight: FontWeight.bold,
              letterSpacing: 2.2,
            ),
          ),
        ],
      ),
    );
  }
}
