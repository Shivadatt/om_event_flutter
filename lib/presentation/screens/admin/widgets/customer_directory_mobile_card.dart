import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/customer_model.dart';
import '../../../controllers/admin_controller.dart';
import 'customer_avatar_badge.dart';
import 'customer_details_dialog.dart';
import 'customer_directory_row_actions.dart';
import 'customer_stats_calculator.dart';

/// Rich responsive customer card for mobile viewports matching the reference design.
class CustomerDirectoryMobileCard extends StatelessWidget {
  final CustomerModel customer;
  final CustomerStats stats;
  final AdminController controller;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryAccent;

  const CustomerDirectoryMobileCard({
    super.key,
    required this.customer,
    required this.stats,
    required this.controller,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    final displayPhone = customer.phone.isNotEmpty ? customer.phone : '—';
    final displayEmail = customer.email.isNotEmpty ? customer.email : '—';
    final displayLocation = customer.city.isNotEmpty
        ? customer.city
        : (customer.address.isNotEmpty ? customer.address : '—');

    return InkWell(
      onTap: () => Get.dialog(CustomerDetailsDialog(customer: customer, controller: controller)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar, Name + Type Badge, and Actions
            Row(
              children: [
                CustomerAvatarBadge(customer: customer, primaryAccent: primaryAccent, size: 42),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name.isNotEmpty ? customer.name : 'Client ${customer.id}',
                        style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${stats.effectiveType} Client',
                              style: AppTheme.sansBody(fontSize: 10.5, color: subtitleColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF132219),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: stats.effectiveType == 'VIP'
                                    ? primaryAccent.withValues(alpha: 0.4)
                                    : const Color(0xFF274433),
                              ),
                            ),
                            child: Text(
                              stats.effectiveType,
                              style: AppTheme.sansBody(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: stats.effectiveType == 'VIP' ? primaryAccent : textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomerDirectoryRowActions(
                  customer: customer,
                  controller: controller,
                  iconColor: textColor.withValues(alpha: 0.7),
                  iconSize: 17,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFF1B2920)),
            const SizedBox(height: 10),

            // Middle: Contact details
            Text(displayPhone, style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.w500, color: textColor)),
            if (displayEmail != '—') ...[
              const SizedBox(height: 2),
              Text(displayEmail, style: AppTheme.sansBody(fontSize: 11, color: subtitleColor)),
            ],
            const SizedBox(height: 8),

            // Bottom: Location, Events count, Spending amount
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(displayLocation, style: AppTheme.sansBody(fontSize: 11, color: subtitleColor)),
                      const SizedBox(width: 10),
                      const Icon(Icons.event_outlined, size: 13, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 4),
                      Text('${stats.totalBookings}', style: AppTheme.sansBody(fontSize: 11, color: textColor)),
                    ],
                  ),
                ),
                Text(
                  AppFormatters.formatCurrency(stats.totalSpent),
                  style: AppTheme.serifHeader(fontSize: 13, fontWeight: FontWeight.bold, color: primaryAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
