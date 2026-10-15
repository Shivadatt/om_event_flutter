part of '../home_screen.dart';

extension HomeTabNavigation on HomeScreen {
  Widget _buildWhatsAppFab(BuildContext context) {
    return Obx(() {
      final details = BusinessDetailsService.to.rxDetails.value;
      final activeNumbers = details.contacts.whatsapps.where((c) => c.isActive).toList();

      if (activeNumbers.isEmpty) {
        return const SizedBox.shrink();
      }

      final screenWidth = MediaQuery.of(context).size.width;
      final isMobile = screenWidth < 600;
      final double fabHeight = isMobile ? 40.0 : 46.0;
      final double fabPadH = isMobile ? 12.0 : 16.0;
      final double iconSize = isMobile ? 18.0 : 20.0;
      final double fontSize = isMobile ? 9.0 : 10.0;

      if (activeNumbers.length == 1) {
        return SizedBox(
          height: fabHeight,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final rawNumber = activeNumbers.first.value;
              final clean = rawNumber.replaceAll(RegExp(r'\D'), '');
              final number = clean.length == 10 ? '91$clean' : clean;
              const text = "Hello Om Events, I'd like to plan an event.";
              final uri = Uri.parse("https://wa.me/$number?text=${Uri.encodeComponent(text)}");
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            backgroundColor: const Color(0xFF2C9B5D),
            foregroundColor: Colors.white,
            elevation: 4,
            extendedPadding: EdgeInsets.symmetric(horizontal: fabPadH),
            icon: Icon(Icons.chat_bubble_outline, size: iconSize),
            label: Text(
              "WHATSAPP US",
              style: AppTheme.sansBody(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      }

      return Theme(
        data: Theme.of(context).copyWith(
          cardColor: const Color(0xFF0D1915),
        ),
        child: PopupMenuButton<ContactItemEntity>(
          offset: const Offset(0, -120),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFC9A77E), width: 1),
          ),
          onSelected: (selected) async {
            final rawNumber = selected.value;
            final clean = rawNumber.replaceAll(RegExp(r'\D'), '');
            final number = clean.length == 10 ? '91$clean' : clean;
            const text = "Hello Om Events, I'd like to plan an event.";
            final uri = Uri.parse("https://wa.me/$number?text=${Uri.encodeComponent(text)}");
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
          itemBuilder: (context) {
            return activeNumbers.map((cn) {
              final labelSuffix = cn.isPrimary ? " (Primary)" : "";
              String cleanLabel = cn.label.replaceAll(RegExp(r'\s*WhatsApp\s*$', caseSensitive: false), '').trim();
              if (cleanLabel.isEmpty) {
                cleanLabel = "WhatsApp";
              }
              final cleanVal = cn.value.replaceAll(RegExp(r'\D'), '');
              final displayVal = cleanVal.length == 10
                  ? '+91 $cleanVal'
                  : (cleanVal.length == 12 && cleanVal.startsWith('91') ? '+91 ${cleanVal.substring(2)}' : cn.value);
              return PopupMenuItem<ContactItemEntity>(
                value: cn,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Icon(
                      Icons.chat,
                      color: Color(0xFF2C9B5D),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "$cleanLabel: $displayVal$labelSuffix",
                        style: AppTheme.sansBody(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            height: fabHeight,
            padding: EdgeInsets.symmetric(horizontal: fabPadH),
            decoration: BoxDecoration(
              color: const Color(0xFF2C9B5D),
              borderRadius: BorderRadius.circular(fabHeight / 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline, color: Colors.white, size: iconSize),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  "WHATSAPP US",
                  style: AppTheme.sansBody(
                    fontSize: fontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
