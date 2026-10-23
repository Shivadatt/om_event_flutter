import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/lead.dart';

class InquiryCardImage extends StatelessWidget {
  final Lead lead;
  final String coverUrl;
  final String cleanType;
  static const Color goldColor = Color(0xFFECC24A);

  const InquiryCardImage({
    super.key,
    required this.lead,
    required this.coverUrl,
    required this.cleanType,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.2,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              coverUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF081410),
                child: Center(
                  child: Icon(
                    Icons.celebration_rounded,
                    color: goldColor.withValues(alpha: 0.3),
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                cleanType.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF091410),
                  fontSize: 9.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 0.5),
              ),
              child: Text(
                lead.budget != null ? AppFormatters.formatCurrency(lead.budget!) : "₹0",
                style: const TextStyle(
                  color: goldColor,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
