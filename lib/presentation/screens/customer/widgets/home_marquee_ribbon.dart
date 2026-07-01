import 'dart:async' as dart_async;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarqueeRibbon extends StatefulWidget {
  const MarqueeRibbon({super.key});

  @override
  State<MarqueeRibbon> createState() => _MarqueeRibbonState();
}

class _MarqueeRibbonState extends State<MarqueeRibbon> {
  late ScrollController _scrollController;
  dart_async.Timer? _timer;

  final List<String> _marqueeItems = [
    "Weddings",
    "Birthdays",
    "Baby Showers",
    "Proposals",
    "Brand Launches",
    "Grand Entries",
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!_scrollController.hasClients) return;
    const speed = 0.8;
    _timer = dart_async.Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_scrollController.hasClients) {
        final max = _scrollController.position.maxScrollExtent;
        final current = _scrollController.offset;
        final next = current + speed;
        if (next >= max) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(next);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF101C18) : const Color(0xFFFAF8F5);
    final borderColor =
        isDark ? const Color(0xFF1D2A26) : const Color(0xFFE5DFD5);

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Center(
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = _marqueeItems[index % _marqueeItems.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 24),
                Text(
                  item.toUpperCase(),
                  style: GoogleFonts.italiana(
                    fontSize: 20,
                    color: isDark ? const Color(0xFFFAF8F5) : const Color(0xFF17201E),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(width: 24),
                const Text(
                  "✦",
                  style: TextStyle(color: Color(0xFFD6B080), fontSize: 14),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
