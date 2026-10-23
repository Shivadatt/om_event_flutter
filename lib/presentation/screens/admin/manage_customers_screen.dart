import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/admin_controller.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/customer_directory_content.dart';
import 'widgets/customer_directory_header.dart';
import 'widgets/customer_directory_toolbar.dart';
import 'widgets/customer_statistics_grid.dart';
import 'widgets/customer_stats_calculator.dart';

/// Client Directory management screen for administrators.
/// Orchestrates responsive statistics, search/sorting toolbar, and customer records.
class ManageCustomersScreen extends StatefulWidget {
  const ManageCustomersScreen({super.key});

  @override
  State<ManageCustomersScreen> createState() => _ManageCustomersScreenState();
}

class _ManageCustomersScreenState extends State<ManageCustomersScreen> {
  final AdminController controller = Get.find<AdminController>();
  final TextEditingController searchCtrl = TextEditingController();
  final RxString rxSearchQuery = ''.obs;
  final RxString rxSortOption = 'Latest'.obs;
  final RxString rxViewMode = 'table'.obs;
  final RxSet<String> rxSelectedCustomerIds = <String>{}.obs;

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryAccent = AppColors.primaryAccent;
    final Color cardColor = isDark ? const Color(0xFF0F1713) : AppColors.lightPaper;
    final Color borderColor = isDark ? const Color(0xFF1E2E23) : AppColors.lightLine;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? const Color(0xFF8E9893) : AppColors.lightMuted;
    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isInsideDrawer
          ? null
          : AppBar(
              leading: const AdminBackButton(),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1100;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomerDirectoryHeader(
                    controller: controller,
                    isMobile: isMobile,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    primaryAccent: primaryAccent,
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final allCustomers = controller.rxCustomers.toList();
                    final allQuotes = controller.rxQuotes.toList();
                    int vipClients = 0;
                    int corporateClients = 0;
                    double totalRevenue = 0.0;

                    for (final customer in allCustomers) {
                      final stats = CustomerStatsCalculator.calculate(customer, allQuotes);
                      if (stats.effectiveType == 'VIP' || stats.totalSpent >= 50000) {
                        vipClients++;
                      }
                      if (stats.effectiveType == 'Corporate' || stats.effectiveType == 'Business') {
                        corporateClients++;
                      }
                      totalRevenue += stats.totalSpent;
                    }

                    if (totalRevenue == 0.0 && controller.pipelineRevenue.value > 0.0) {
                      totalRevenue = controller.pipelineRevenue.value;
                    }

                    return CustomerStatisticsGrid(
                      isMobile: isMobile,
                      isTablet: isTablet,
                      totalClients: allCustomers.length,
                      vipClients: vipClients,
                      corporateClients: corporateClients,
                      totalRevenue: totalRevenue,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      primaryAccent: primaryAccent,
                    );
                  }),
                  const SizedBox(height: 22),
                  CustomerDirectoryToolbar(
                    searchCtrl: searchCtrl,
                    rxSearchQuery: rxSearchQuery,
                    rxSortOption: rxSortOption,
                    rxViewMode: rxViewMode,
                    isMobile: isMobile,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    primaryAccent: primaryAccent,
                  ),
                  const SizedBox(height: 20),
                  CustomerDirectoryContent(
                    controller: controller,
                    searchCtrl: searchCtrl,
                    rxSearchQuery: rxSearchQuery,
                    rxSortOption: rxSortOption,
                    rxViewMode: rxViewMode,
                    rxSelectedCustomerIds: rxSelectedCustomerIds,
                    maxWidth: constraints.maxWidth,
                    isMobile: isMobile,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    primaryAccent: primaryAccent,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
