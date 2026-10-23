import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/customer_model.dart';
import '../../../controllers/admin_controller.dart';
import 'customer_avatar_badge.dart';
import 'customer_directory_row_actions.dart';
import 'customer_stats_calculator.dart';

/// Single table row for the desktop/tablet Customer Directory.
class CustomerDirectoryTableRow extends StatelessWidget {
  final CustomerModel customer;
  final CustomerStats stats;
  final AdminController controller;
  final RxSet<String> rxSelectedCustomerIds;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryAccent;

  const CustomerDirectoryTableRow({
    super.key,
    required this.customer,
    required this.stats,
    required this.controller,
    required this.rxSelectedCustomerIds,
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

    return Obx(() {
      final isSelected = rxSelectedCustomerIds.contains(customer.id);

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryAccent.withValues(alpha: 0.08) : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryAccent.withValues(alpha: 0.4) : borderColor.withValues(alpha: 0.8),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Checkbox(
                value: isSelected,
                activeColor: primaryAccent,
                checkColor: Colors.black,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (val) => val == true
                    ? rxSelectedCustomerIds.add(customer.id)
                    : rxSelectedCustomerIds.remove(customer.id),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 250,
              child: Row(
                children: [
                  CustomerAvatarBadge(customer: customer, primaryAccent: primaryAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          customer.name.isNotEmpty ? customer.name : 'Client ${customer.id}',
                          style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${stats.effectiveType} Client',
                          style: AppTheme.sansBody(fontSize: 11, color: subtitleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 120,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132219),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: stats.effectiveType == 'VIP' ? primaryAccent.withValues(alpha: 0.4) : const Color(0xFF274433),
                    ),
                  ),
                  child: Text(
                    stats.effectiveType,
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: stats.effectiveType == 'VIP' ? primaryAccent : textColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(displayPhone, style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.w500, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(displayEmail, style: AppTheme.sansBody(fontSize: 11, color: subtitleColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(
              width: 140,
              child: Text(displayLocation, style: AppTheme.sansBody(fontSize: 13, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(
              width: 140,
              child: Text(
                AppFormatters.formatCurrency(stats.totalSpent),
                style: AppTheme.serifHeader(fontSize: 14, fontWeight: FontWeight.bold, color: primaryAccent),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text('${stats.totalBookings}', style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
            ),
            SizedBox(
              width: 120,
              child: CustomerDirectoryRowActions(
                customer: customer,
                controller: controller,
                iconColor: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    });
  }
}
