import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import 'seeder_screen.dart';

class AdminDashboardScreen extends GetView<AdminController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "STUDIO OVERVIEW",
          style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadDashboardStats(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF101815)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("OE", style: AppTheme.serifHeader(fontSize: 24, color: const Color(0xFFC9A77E))),
                  Text("OM EVENTS", style: AppTheme.sansBody(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text("Overview"),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text("Manage Categories"),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.manageCategories);
              },
            ),
            ListTile(
              leading: const Icon(Icons.stars_outlined),
              title: const Text("Manage Catalog"),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.manageExperiences);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone_outlined),
              title: const Text("Manage Leads"),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.manageLeads);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text("Quotations"),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.manageQuotes);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text("Customer Directory"),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.manageCustomers);
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text("User Management"),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.manageUsers);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore_outlined),
              title: const Text("Database Seeder"),
              onTap: () {
                Get.back();
                Get.to(() => const SeederScreen());
              },
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingStats.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadDashboardStats(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good day, team.",
                  style: AppTheme.serifHeader(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Metrics Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.35,
                  children: [
                    _metricCard("NEW LEADS", controller.leadCount.toString(), "Inquiries waiting", isDark),
                    _metricCard("QUOTATIONS", controller.quoteCount.toString(), "Proposals saved", isDark),
                    _metricCard(
                      "VALUATION",
                      AppFormatters.formatCurrency(controller.pipelineRevenue.value),
                      "Total pipeline",
                      isDark,
                      isRevenue: true,
                    ),
                    Obx(() => _metricCard("ACTIVE CATS", controller.activeCategoriesCount.value.toString(), "Event categories", isDark)),
                  ],
                ),
                const SizedBox(height: 32),

                // Latest Inquiries Section
                Text(
                  "LATEST INQUIRIES",
                  style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: isDark ? AppTheme.darkGold : AppTheme.lightGold),
                ),
                const SizedBox(height: 12),
                if (controller.rxLeads.isEmpty)
                  Text("No inquiries found.", style: AppTheme.sansBody(fontSize: 13, color: Colors.grey))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.rxLeads.length > 5 ? 5 : controller.rxLeads.length,
                    itemBuilder: (context, index) {
                      final lead = controller.rxLeads[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkLine : AppTheme.lightLine)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lead.name, style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(lead.phone, style: AppTheme.sansBody(fontSize: 12, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(lead.status, isDark),
                              ),
                              child: Text(
                                lead.status.toUpperCase(),
                                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _metricCard(String label, String value, String desc, bool isDark, {bool isRevenue = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTheme.sansBody(fontSize: 8, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTheme.serifHeader(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isRevenue ? (isDark ? AppTheme.darkGold : AppTheme.lightGold) : null,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(desc, style: AppTheme.sansBody(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'contacted':
        return Colors.orange;
      case 'qualified':
        return Colors.indigo;
      case 'won':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
