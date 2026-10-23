import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

/// Header for the Add New Client dialog with title, subtitle, and close button.
class AddCustomerDialogHeader extends StatelessWidget {
  final bool isMobile;
  final Color textColor;
  final Color subtitleColor;
  final Color borderColor;
  final VoidCallback onClose;

  const AddCustomerDialogHeader({
    super.key,
    required this.isMobile,
    required this.textColor,
    required this.subtitleColor,
    required this.borderColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : 28,
        isMobile ? 16 : 22,
        isMobile ? 14 : 20,
        isMobile ? 14 : 16,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Client',
                  style: AppTheme.serifHeader(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Create a new client profile with complete information.',
                  style: AppTheme.sansBody(
                    fontSize: isMobile ? 11 : 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            color: textColor.withValues(alpha: 0.6),
            tooltip: 'Close',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
