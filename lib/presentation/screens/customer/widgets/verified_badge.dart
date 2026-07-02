import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(44, 155, 93, 0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified,
            color: Color(0xFF2C9B5D),
            size: 10,
          ),
          const SizedBox(width: 4),
          Text(
            "Verified Client",
            style: AppTheme.sansBody(
              fontSize: 8,
              color: const Color(0xFF2C9B5D),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
