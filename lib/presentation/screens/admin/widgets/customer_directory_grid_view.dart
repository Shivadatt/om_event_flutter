import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../domain/entities/quotation.dart';
import '../../../controllers/admin_controller.dart';
import 'customer_avatar_badge.dart';
import 'customer_directory_row_actions.dart';
import 'customer_stats_calculator.dart';

/// Grid card view layout for Customer Directory when grid view is selected.
class CustomerDirectoryGridView extends StatelessWidget {
  final List<CustomerModel> customers;
  final List<Quotation> quotes;
  final double maxWidth;
  final AdminController controller;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryAccent;

  const CustomerDirectoryGridView({
    super.key,
    required this.customers,
    required this.quotes,
    required this.maxWidth,
    required this.controller,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 3;
    if (maxWidth < 900) {
      crossAxisCount = 2;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: customers.map((customer) {
            final stats = CustomerStatsCalculator.calculate(customer, quotes);
            final displayPhone = customer.phone.isNotEmpty ? customer.phone : '—';
            final displayLocation = customer.city.isNotEmpty
                ? customer.city
                : (customer.address.isNotEmpty ? customer.address : '—');

            return SizedBox(
              width: itemWidth,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomerAvatarBadge(customer: customer, primaryAccent: primaryAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name.isNotEmpty ? customer.name : 'Client ${customer.id}',
                                style: AppTheme.sansBody(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text('${stats.effectiveType} Client', style: AppTheme.sansBody(fontSize: 11, color: subtitleColor)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF132219),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: stats.effectiveType == 'VIP' ? primaryAccent.withValues(alpha: 0.4) : const Color(0xFF274433),
                            ),
                          ),
                          child: Text(
                            stats.effectiveType,
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: stats.effectiveType == 'VIP' ? primaryAccent : textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFF1B2920)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LIFETIME SPENDING',
                              style: AppTheme.sansBody(fontSize: 9, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppFormatters.formatCurrency(stats.totalSpent),
                              style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold, color: primaryAccent),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TOTAL BOOKINGS',
                              style: AppTheme.sansBody(fontSize: 9, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 2),
                            Text('${stats.totalBookings} Events', style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFF1B2920)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: primaryAccent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(displayPhone, style: AppTheme.sansBody(fontSize: 12, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Icon(Icons.location_on_outlined, size: 14, color: primaryAccent),
                        const SizedBox(width: 4),
                        Text(displayLocation, style: AppTheme.sansBody(fontSize: 12, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomerDirectoryRowActions(
                        customer: customer,
                        controller: controller,
                        iconColor: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
