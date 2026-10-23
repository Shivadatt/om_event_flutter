import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../domain/entities/quotation.dart';
import '../../../controllers/admin_controller.dart';
import 'customer_directory_table_row.dart';
import 'customer_stats_calculator.dart';

/// Horizontally scrollable data table for desktop and laptop viewports in Customer Directory.
class CustomerDirectoryTable extends StatelessWidget {
  final List<CustomerModel> customers;
  final List<Quotation> quotes;
  final AdminController controller;
  final RxSet<String> rxSelectedCustomerIds;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryAccent;

  const CustomerDirectoryTable({
    super.key,
    required this.customers,
    required this.quotes,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1050),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table Header Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Obx(() {
                      final allSelected = customers.isNotEmpty &&
                          customers.every((c) => rxSelectedCustomerIds.contains(c.id));
                      return Checkbox(
                        value: allSelected,
                        activeColor: primaryAccent,
                        checkColor: Colors.black,
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          if (val == true) {
                            rxSelectedCustomerIds.addAll(customers.map((c) => c.id));
                          } else {
                            rxSelectedCustomerIds.clear();
                          }
                        },
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderCell('CLIENT', 250),
                  _buildHeaderCell('TYPE', 120),
                  _buildHeaderCell('CONTACT', 220),
                  _buildHeaderCell('LOCATION', 140),
                  _buildHeaderCell('TOTAL SPENDING', 140),
                  _buildHeaderCell('EVENTS', 80),
                  _buildHeaderCell('ACTIONS', 120),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Table Data Rows
            ...customers.map((customer) {
              final stats = CustomerStatsCalculator.calculate(customer, quotes);
              return CustomerDirectoryTableRow(
                customer: customer,
                stats: stats,
                controller: controller,
                rxSelectedCustomerIds: rxSelectedCustomerIds,
                cardColor: cardColor,
                borderColor: borderColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                primaryAccent: primaryAccent,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String title, double width) {
    return SizedBox(
      width: width,
      child: Text(
        title,
        style: AppTheme.sansBody(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: subtitleColor,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
