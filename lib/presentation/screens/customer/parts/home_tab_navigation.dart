part of '../home_screen.dart';

extension HomeTabNavigation on HomeScreen {
  Widget _buildWhatsAppFab(BuildContext context) {
    return Obx(() {
      final details = BusinessDetailsService.to.rxDetails.value;
      final activeNumbers = details.contacts.whatsapps.where((c) => c.isActive).toList();

      if (activeNumbers.isEmpty) {
        return const SizedBox.shrink();
      }

      if (activeNumbers.length == 1) {
        return FloatingActionButton.extended(
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
          icon: const Icon(Icons.chat_bubble_outline),
          label: Text(
            "WHATSAPP US",
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
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
              String cleanLabel = cn.label.replaceAll(RegExp(r'\s*WhatsApp\s*$', caseSensitive: false), '');
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
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C9B5D),
              borderRadius: BorderRadius.circular(24),
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
                const Icon(Icons.chat_bubble_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  "WHATSAPP US",
                  style: AppTheme.sansBody(
                    fontSize: 10,
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
