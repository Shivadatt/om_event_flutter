import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';

class ContactAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color goldColor;
  final bool isMobile;
  final bool isDesktop;
  final double screenWidth;
  final GlobalKey appBarWhatsAppKey;
  final VoidCallback onBackPressed;
  final VoidCallback onWhatsAppPressed;
  final VoidCallback onTrackPressed;

  const ContactAppBar({
    super.key,
    required this.goldColor,
    required this.isMobile,
    required this.isDesktop,
    required this.screenWidth,
    required this.appBarWhatsAppKey,
    required this.onBackPressed,
    required this.onWhatsAppPressed,
    required this.onTrackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF08120E).withValues(alpha: 0.98),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: Colors.white70,
        ),
        onPressed: onBackPressed,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMobile ? 22 : 26,
            height: isMobile ? 22 : 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: goldColor, width: 1.2),
              color: const Color(0xFF0C1914),
            ),
            child: Center(
              child: Text(
                "OE",
                style: TextStyle(
                  color: goldColor,
                  fontSize: isMobile ? 8.5 : 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "OM EVENTS & DECORATORS",
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.italiana(
                fontSize: isDesktop ? 16 : (isMobile ? 12 : 14),
                fontWeight: FontWeight.bold,
                letterSpacing: isMobile ? 1.0 : 2.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (screenWidth > 380) ...[
          TextButton.icon(
            key: appBarWhatsAppKey,
            onPressed: onWhatsAppPressed,
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 14,
              color: Color(0xFF4EBA7A),
            ),
            label: Text(
              "WhatsApp",
              style: AppTheme.sansBody(
                fontSize: 10.5,
                color: const Color(0xFF4EBA7A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: onTrackPressed,
            icon: Icon(
              Icons.track_changes_rounded,
              size: 14,
              color: goldColor,
            ),
            label: Text(
              "Track",
              style: AppTheme.sansBody(
                fontSize: 10.5,
                color: goldColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ] else ...[
          IconButton(
            key: appBarWhatsAppKey,
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 17,
              color: Color(0xFF4EBA7A),
            ),
            tooltip: "WhatsApp",
            onPressed: onWhatsAppPressed,
          ),
          IconButton(
            icon: Icon(
              Icons.track_changes_rounded,
              size: 17,
              color: goldColor,
            ),
            tooltip: "Track Booking",
            onPressed: onTrackPressed,
          ),
        ],
        SizedBox(width: isMobile ? 6 : 12),
      ],
    );
  }
}
