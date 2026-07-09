import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/admin_metric_card.dart';
import 'widgets/admin_action_button.dart';
import 'widgets/inquiries_trend_chart.dart';
import 'widgets/recent_inquiries_widget.dart';

/// Core Dashboard landing page for administrators and managers.
class AdminDashboardScreen extends GetView<AdminController> {
  /// Creates an [AdminDashboardScreen] instance.
  const AdminDashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${now.day} ${months[now.month - 1]}, ${now.year}";
  }

  Color _getBadgeColor(String role) {
    switch (role) {
      case 'super_admin':
        return AppColors.primaryAccent;
      case 'demo_admin':
        return AppColors.secondaryAccent;
      case 'staff':
        return AppColors.highlight;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      backgroundColor: Colors.transparent, // Let parent AdminLayout background glow show
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: subtitleColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Search menu...",
              style: AppTheme.sansBody(
                fontSize: 13,
                color: subtitleColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textColor),
            onPressed: () => controller.loadDashboardStats(),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final currentAdmin = authController.rxAdminRole.value;
            if (currentAdmin == null) return const SizedBox();

            return GestureDetector(
              onTap: () => Get.toNamed('/admin/profile'),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currentAdmin.name.isEmpty
                            ? currentAdmin.email.split('@').first
                            : currentAdmin.name,
                        style: AppTheme.sansBody(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        currentAdmin.roleType.replaceAll('_', ' ').toUpperCase(),
                        style: AppTheme.sansBody(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: _getBadgeColor(currentAdmin.roleType),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isDark ? AppColors.darkForestSecondary : AppColors.lightForestSecondary,
                    child: Text(
                      (currentAdmin.name.isEmpty
                              ? currentAdmin.email
                              : currentAdmin.name)[0]
                          .toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primaryAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingStats.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
            ),
          );
        }

        final currentAdmin = authController.rxAdminRole.value;
        final isSuper = currentAdmin?.roleType == 'super_admin';

        return RefreshIndicator(
          onRefresh: () => controller.loadDashboardStats(),
          color: AppColors.primaryAccent,
          backgroundColor: isDark ? AppColors.darkForest : AppColors.lightForest,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic Welcome Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_getGreeting()}, ${currentAdmin != null ? (currentAdmin.name.isEmpty ? currentAdmin.email.split('@').first : currentAdmin.name) : 'Team'}.",
                          style: AppTheme.serifHeader(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Here is what is happening with the studio today • ${_getFormattedDate()}",
                          style: AppTheme.sansBody(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Metrics grid (Responsive Row layout)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final cols = width > 1200 ? 4 : (width > 600 ? 2 : 1);
                    return GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: width > 1200 ? 1.6 : 1.9,
                      children: [
                        AdminMetricCard(
                          label: "NEW INQUIRIES",
                          value: controller.leadCount.toString(),
                          desc: "Active studio leads",
                          icon: Icons.contact_phone_outlined,
                          color: AppColors.primaryAccent,
                        ),
                        AdminMetricCard(
                          label: "PROPOSALS SENT",
                          value: controller.quoteCount.toString(),
                          desc: "Saved event contracts",
                          icon: Icons.receipt_long_outlined,
                          color: AppColors.secondaryAccent,
                        ),
                        AdminMetricCard(
                          label: "TOTAL PIPELINE",
                          value: AppFormatters.formatCurrency(
                            controller.pipelineRevenue.value,
                          ),
                          desc: "Pending valuation",
                          icon: Icons.payments_outlined,
                          color: AppColors.success,
                        ),
                        AdminMetricCard(
                          label: "ACTIVE CATS",
                          value: controller.activeCategoriesCount.value.toString(),
                          desc: "Decoration catalog",
                          icon: Icons.category_outlined,
                          color: AppColors.highlight,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Quick Actions Grid (TailAdmin inspired CRM layout)
                Text(
                  "QUICK ACTIONS",
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (isSuper ||
                        (currentAdmin?.permissions['can_manage_categories'] ?? false))
                      AdminActionButton(
                        label: "Add Category",
                        icon: Icons.add_box_outlined,
                        onTap: () => Get.toNamed(AppRoutes.manageCategories),
                      ),
                    if (isSuper ||
                        (currentAdmin?.permissions['can_manage_items'] ?? false))
                      AdminActionButton(
                        label: "Add Experience",
                        icon: Icons.stars_outlined,
                        onTap: () => Get.toNamed(AppRoutes.manageExperiences),
                      ),
                    if (isSuper ||
                        (currentAdmin?.permissions['can_manage_quotes'] ?? false))
                      AdminActionButton(
                        label: "Create Quote",
                        icon: Icons.receipt_outlined,
                        onTap: () => Get.toNamed(AppRoutes.manageQuotes),
                      ),
                    if (isSuper ||
                        (currentAdmin?.permissions['can_manage_customers'] ?? false))
                      AdminActionButton(
                        label: "Add Customer",
                        icon: Icons.person_add_outlined,
                        onTap: () => Get.toNamed(AppRoutes.manageCustomers),
                      ),
                  ],
                ),
                const SizedBox(height: 32),

                // Analytics & Recent Inquiries Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 950) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            flex: 3,
                            child: InquiriesTrendChart(),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: RecentInquiriesWidget(
                              controller: controller,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          const InquiriesTrendChart(),
                          const SizedBox(height: 24),
                          RecentInquiriesWidget(controller: controller),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
