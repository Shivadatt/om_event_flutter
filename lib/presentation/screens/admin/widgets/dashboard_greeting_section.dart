import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/admin_role.dart';

/// Responsive greeting and date section for the Admin Dashboard.
class DashboardGreetingSection extends StatelessWidget {
  final AdminRole? currentAdmin;
  final Color textColor;
  final Color subtitleColor;
  final bool isMobile;

  const DashboardGreetingSection({
    super.key,
    required this.currentAdmin,
    required this.textColor,
    required this.subtitleColor,
    required this.isMobile,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    final name = currentAdmin != null
        ? (currentAdmin!.name.isEmpty
            ? currentAdmin!.email.split('@').first
            : currentAdmin!.name)
        : 'Super Admin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_getGreeting()}, $name,",
          style: GoogleFonts.italiana(
            fontSize: isMobile ? 19 : 23,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          isMobile
              ? _getFormattedDate()
              : "Here's what happening with your studio today · ${_getFormattedDate()}",
          style: GoogleFonts.dmSans(
            fontSize: isMobile ? 10 : 11,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }
}
