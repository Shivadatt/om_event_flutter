import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_images.dart';

class ContactFooterVerticalDivider extends StatelessWidget {
  final Color goldColor;

  const ContactFooterVerticalDivider({super.key, required this.goldColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 140,
      color: goldColor.withValues(alpha: 0.15),
    );
  }
}

class ContactFooterDecorativeArch extends StatelessWidget {
  final Color goldColor;
  final BorderRadius? borderRadius;
  final double? height;

  const ContactFooterDecorativeArch({
    super.key,
    required this.goldColor,
    this.borderRadius,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius:
            borderRadius ??
            const BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.luxuryEveningDecor,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0C1914)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF060907).withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 10,
            right: 10,
            child: Text(
              "Make\nEvery Moment\nExtra Special",
              style: GoogleFonts.italiana(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: goldColor,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
