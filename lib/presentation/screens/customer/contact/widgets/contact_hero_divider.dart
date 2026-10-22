import 'dart:math' as math;
import 'package:flutter/material.dart';

class ContactHeroDivider extends StatelessWidget {
  final Color goldColor;
  final bool isMobile;

  const ContactHeroDivider({
    super.key,
    required this.goldColor,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: isMobile ? 36 : 48,
          height: 1.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                goldColor.withValues(alpha: 0.6),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: goldColor,
              shape: BoxShape.rectangle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: isMobile ? 36 : 48,
          height: 1.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                goldColor.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
