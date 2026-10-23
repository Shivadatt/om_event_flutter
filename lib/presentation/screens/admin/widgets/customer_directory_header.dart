import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../controllers/admin_controller.dart';
import 'add_customer_dialog.dart';

/// Top header section for the Customer Directory.
/// Renders title, count badge, subtitle, refresh button, and Add Customer action.
class CustomerDirectoryHeader extends StatelessWidget {
  final AdminController controller;
  final bool isMobile;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryAccent;

  const CustomerDirectoryHeader({
    super.key,
    required this.controller,
    required this.isMobile,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            Text(
              'Client Directory',
              style: AppTheme.serifHeader(
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C2417),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    '${controller.rxCustomers.length} Total Customers',
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Complete client information with booking insights.',
          style: AppTheme.sansBody(
            fontSize: isMobile ? 12 : 13,
            color: subtitleColor,
          ),
        ),
      ],
    );

    final actionsWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, size: 20, color: primaryAccent),
          tooltip: 'Refresh Customers',
          onPressed: () => controller.loadCustomers(),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Customer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryAccent,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTheme.sansBody(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => Get.dialog(CustomerCreateDialog(controller: controller)),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleWidget),
              IconButton(
                icon: Icon(Icons.refresh_rounded, size: 20, color: primaryAccent),
                tooltip: 'Refresh Customers',
                onPressed: () => controller.loadCustomers(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTheme.sansBody(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Get.dialog(CustomerCreateDialog(controller: controller)),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleWidget),
        const SizedBox(width: 16),
        actionsWidget,
      ],
    );
  }
}
