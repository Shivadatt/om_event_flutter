import 'package:flutter/material.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../domain/entities/quotation.dart';
import '../../../controllers/admin_controller.dart';
import 'customer_directory_mobile_card.dart';
import 'customer_stats_calculator.dart';

/// Renders a vertically stacked list of rich customer cards for mobile viewports.
class CustomerDirectoryMobileList extends StatelessWidget {
  final List<CustomerModel> customers;
  final List<Quotation> quotes;
  final AdminController controller;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryAccent;

  const CustomerDirectoryMobileList({
    super.key,
    required this.customers,
    required this.quotes,
    required this.controller,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: customers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final customer = customers[index];
        final stats = CustomerStatsCalculator.calculate(customer, quotes);

        return CustomerDirectoryMobileCard(
          customer: customer,
          stats: stats,
          controller: controller,
          cardColor: cardColor,
          borderColor: borderColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          primaryAccent: primaryAccent,
        );
      },
    );
  }
}
