import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
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
        return const Color(0xFFC8A26A); // Gold Accent
      case 'demo_admin':
        return Colors.blue;
      case 'staff':
        return const Color(0xFF3BA776); // Green Accent
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1714),
      body: Obx(() {
        if (controller.isLoadingStats.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC8A26A)),
            ),
          );
        }

        final currentAdmin = authController.rxAdminRole.value;
        final isSuper = currentAdmin?.roleType == 'super_admin';

        return Scaffold(
                backgroundColor: const Color(0xFF0B1714),
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xFF0D1915),
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Color(0xFFF4F4F4)),

                  title: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Color(0xFFA4A9A7),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Search menu...",
                        style: AppTheme.sansBody(
                          fontSize: 13,
                          color: const Color(0xFFA4A9A7),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFFF4F4F4)),
                      onPressed: () => controller.loadDashboardStats(),
                    ),
                    const SizedBox(width: 8),
                    if (currentAdmin != null)
                      GestureDetector(
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
                                    color: const Color(0xFFF4F4F4),
                                  ),
                                ),
                                Text(
                                  currentAdmin.roleType
                                      .replaceAll('_', ' ')
                                      .toUpperCase(),
                                  style: AppTheme.sansBody(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: _getBadgeColor(
                                      currentAdmin.roleType,
                                    ),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF162822),
                              child: Text(
                                (currentAdmin.name.isEmpty
                                        ? currentAdmin.email
                                        : currentAdmin.name)[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFFC8A26A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                  ],
                ),

                body: RefreshIndicator(
                  onRefresh: () => controller.loadDashboardStats(),
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
                                    color: const Color(0xFFF4F4F4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Here is what is happening with the studio today • ${_getFormattedDate()}",
                                  style: AppTheme.sansBody(
                                    fontSize: 12,
                                    color: const Color(0xFFA4A9A7),
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
                            final cols =
                                width > 1200 ? 4 : (width > 600 ? 2 : 1);
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
                                  color: const Color(0xFFC8A26A),
                                ),
                                AdminMetricCard(
                                  label: "PROPOSALS SENT",
                                  value: controller.quoteCount.toString(),
                                  desc: "Saved event contracts",
                                  icon: Icons.receipt_long_outlined,
                                  color: const Color(0xFFE0A458),
                                ),
                                AdminMetricCard(
                                  label: "TOTAL PIPELINE",
                                  value: AppFormatters.formatCurrency(
                                    controller.pipelineRevenue.value,
                                  ),
                                  desc: "Pending valuation",
                                  icon: Icons.payments_outlined,
                                  color: const Color(0xFF3BA776),
                                ),
                                AdminMetricCard(
                                  label: "ACTIVE CATS",
                                  value:
                                      controller.activeCategoriesCount.value
                                          .toString(),
                                  desc: "Decoration catalog",
                                  icon: Icons.category_outlined,
                                  color: const Color(0xFFC8A26A),
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
                            color: const Color(0xFFA4A9A7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (isSuper ||
                                (currentAdmin
                                        ?.permissions['can_manage_categories'] ??
                                    false))
                              AdminActionButton(
                                label: "Add Category",
                                icon: Icons.add_box_outlined,
                                onTap:
                                    () =>
                                        Get.toNamed(AppRoutes.manageCategories),
                              ),
                            if (isSuper ||
                                (currentAdmin
                                        ?.permissions['can_manage_items'] ??
                                    false))
                              AdminActionButton(
                                label: "Add Experience",
                                icon: Icons.stars_outlined,
                                onTap:
                                    () => Get.toNamed(
                                      AppRoutes.manageExperiences,
                                    ),
                              ),
                            if (isSuper ||
                                (currentAdmin
                                        ?.permissions['can_manage_quotes'] ??
                                    false))
                              AdminActionButton(
                                label: "Create Quote",
                                icon: Icons.receipt_outlined,
                                onTap:
                                    () => Get.toNamed(AppRoutes.manageQuotes),
                              ),
                            if (isSuper ||
                                (currentAdmin
                                        ?.permissions['can_manage_customers'] ??
                                    false))
                              AdminActionButton(
                                label: "Add Customer",
                                icon: Icons.person_add_outlined,
                                onTap:
                                    () =>
                                        Get.toNamed(AppRoutes.manageCustomers),
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
                ),
        );
      }),
    );
  }
}
