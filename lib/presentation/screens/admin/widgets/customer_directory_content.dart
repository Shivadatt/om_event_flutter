import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../domain/entities/quotation.dart';
import '../../../controllers/admin_controller.dart';
import 'customer_directory_grid_view.dart';
import 'customer_directory_mobile_list.dart';
import 'customer_directory_states.dart';
import 'customer_directory_table.dart';
import 'customer_stats_calculator.dart';

/// Content section managing loading/empty/error states, search filtering, sorting,
/// and rendering Mobile List, Desktop Grid, or Desktop Table views.
class CustomerDirectoryContent extends StatelessWidget {
  final AdminController controller;
  final TextEditingController searchCtrl;
  final RxString rxSearchQuery;
  final RxString rxSortOption;
  final RxString rxViewMode;
  final RxSet<String> rxSelectedCustomerIds;
  final double maxWidth;
  final bool isMobile;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryAccent;

  const CustomerDirectoryContent({
    super.key,
    required this.controller,
    required this.searchCtrl,
    required this.rxSearchQuery,
    required this.rxSortOption,
    required this.rxViewMode,
    required this.rxSelectedCustomerIds,
    required this.maxWidth,
    required this.isMobile,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryAccent,
  });

  List<CustomerModel> _filterAndSort(
    List<CustomerModel> allCustomers,
    List<Quotation> allQuotes,
  ) {
    final query = rxSearchQuery.value.trim().toLowerCase();
    final filtered = allCustomers.where((c) {
      if (query.isEmpty) return true;
      return c.name.toLowerCase().contains(query) ||
          c.phone.toLowerCase().contains(query) ||
          c.email.toLowerCase().contains(query) ||
          c.city.toLowerCase().contains(query) ||
          c.address.toLowerCase().contains(query) ||
          c.type.toLowerCase().contains(query) ||
          c.id.toLowerCase().contains(query);
    }).toList();

    final sort = rxSortOption.value;
    filtered.sort((a, b) {
      final aStats = CustomerStatsCalculator.calculate(a, allQuotes);
      final bStats = CustomerStatsCalculator.calculate(b, allQuotes);
      switch (sort) {
        case 'Oldest':
          return a.createdAt.compareTo(b.createdAt);
        case 'Highest Spending':
          return bStats.totalSpent.compareTo(aStats.totalSpent);
        case 'Lowest Spending':
          return aStats.totalSpent.compareTo(bStats.totalSpent);
        case 'Most Bookings':
          return bStats.totalBookings.compareTo(aStats.totalBookings);
        case 'Least Bookings':
          return aStats.totalBookings.compareTo(bStats.totalBookings);
        case 'Latest':
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoadingCustomers.value;
      final hasError = controller.customerLoadError.value.isNotEmpty;
      final allCustomers = controller.rxCustomers.toList();
      final allQuotes = controller.rxQuotes.toList();

      if (isLoading && allCustomers.isEmpty) {
        return CustomerDirectoryStates.buildLoading(subtitleColor, primaryAccent);
      }
      if (hasError && allCustomers.isEmpty) {
        return CustomerDirectoryStates.buildError(
          controller: controller,
          textColor: textColor,
          subtitleColor: subtitleColor,
          primaryAccent: primaryAccent,
        );
      }
      if (allCustomers.isEmpty) {
        return CustomerDirectoryStates.buildEmpty(
          controller: controller,
          textColor: textColor,
          subtitleColor: subtitleColor,
          primaryAccent: primaryAccent,
        );
      }

      final filtered = _filterAndSort(allCustomers, allQuotes);
      if (filtered.isEmpty) {
        return CustomerDirectoryStates.buildNoResults(
          query: rxSearchQuery.value.trim(),
          onClear: () {
            searchCtrl.clear();
            rxSearchQuery.value = '';
          },
          textColor: textColor,
          subtitleColor: subtitleColor,
          primaryAccent: primaryAccent,
        );
      }

      if (isMobile) {
        return CustomerDirectoryMobileList(
          customers: filtered,
          quotes: allQuotes,
          controller: controller,
          cardColor: cardColor,
          borderColor: borderColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          primaryAccent: primaryAccent,
        );
      }

      if (rxViewMode.value == 'grid') {
        return CustomerDirectoryGridView(
          customers: filtered,
          quotes: allQuotes,
          maxWidth: maxWidth,
          controller: controller,
          cardColor: cardColor,
          borderColor: borderColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          primaryAccent: primaryAccent,
        );
      }

      return CustomerDirectoryTable(
        customers: filtered,
        quotes: allQuotes,
        controller: controller,
        rxSelectedCustomerIds: rxSelectedCustomerIds,
        cardColor: cardColor,
        borderColor: borderColor,
        textColor: textColor,
        subtitleColor: subtitleColor,
        primaryAccent: primaryAccent,
      );
    });
  }
}
