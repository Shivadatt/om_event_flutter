import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/services/app_config_service.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final forestColor =
        isDark ? const Color(0xFF131D1A) : const Color(0xFFF4F0E8);
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = width >= 1000 ? 64.0 : 24.0;

    return Obx(() {
      final stats = AppConfigService.to.rxStatisticsSettings.value;
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
          label: "Cities",
          hasPlus: true,
          decimals: 0,
        ),
        _StatItem(
          targetValue: stats.years.toDouble(),
          label: "Years",
          hasPlus: true,
          decimals: 0,
        ),
      ];

      if (width >= 700) {
        return Container(
          decoration: BoxDecoration(
            color: forestColor,
            border: Border(
              top: BorderSide(
                color:
                    isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
                width: 1,
              ),
              bottom: BorderSide(
                color:
                    isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: 62,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
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
            ),
          ),
        );
      } else {
        // Mobile split Layout
        final row1 = list.sublist(0, 2);
        final row2 = list.sublist(2, 4);

        return Container(
          decoration: BoxDecoration(
            color: forestColor,
            border: Border(
              top: BorderSide(
                color:
                    isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
                width: 1,
              ),
              bottom: BorderSide(
                color:
                    isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor =
        isDark ? const Color(0xFFFAF8F5) : const Color(0xFF17201E);
    final borderColor =
        isDark ? const Color(0xFF23322D) : const Color(0xFFE5DFD5);

    return Container(
      decoration: BoxDecoration(
        border:
            widget.showLeftBorder
                ? Border(left: BorderSide(color: borderColor, width: 1))
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
                style: AppTheme.serifHeader(
                  fontSize: MediaQuery.of(context).size.width >= 600 ? 54 : 36,
                  color: valueColor,
                  fontWeight: FontWeight.normal,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            widget.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTheme.sansBody(
              fontSize: 9,
              color: isDark ? const Color(0x99FAF8F5) : const Color(0x9917201E),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
