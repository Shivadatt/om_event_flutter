import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import 'dashboard_chart.dart';

class AdminDashboardScreen extends GetView<AdminController> {
  const AdminDashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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

        return Row(
          children: [
            // Fixed Sidebar Navigation for Desktop/Laptops (Width >= 1024)
            if (MediaQuery.of(context).size.width >= 1024)
              Container(
                width: 240,
                color: const Color(0xFF0D1915),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFF254235), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF162822),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFC8A26A), width: 1),
                            ),
                            child: Text(
                              "OE",
                              style: AppTheme.serifHeader(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFC8A26A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "OM EVENTS",
                                style: AppTheme.sansBody(
                                  fontSize: 12,
                                  color: const Color(0xFFF4F4F4),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                "STUDIO ADMIN",
                                style: AppTheme.sansBody(
                                  fontSize: 9,
                                  color: const Color(0xFFA4A9A7),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        children: [
                          _sidebarItem(
                            icon: Icons.dashboard_outlined,
                            label: "Dashboard",
                            isActive: true,
                            onTap: () {},
                          ),
                          if (isSuper || (currentAdmin?.permissions['can_manage_categories'] ?? false))
                            _sidebarItem(
                              icon: Icons.category_outlined,
                              label: "Categories",
                              onTap: () => Get.toNamed(AppRoutes.manageCategories),
                            ),
                          if (isSuper || (currentAdmin?.permissions['can_manage_items'] ?? false))
                            _sidebarItem(
                              icon: Icons.stars_outlined,
                              label: "Experiences",
                              onTap: () => Get.toNamed(AppRoutes.manageExperiences),
                            ),
                          if (isSuper || (currentAdmin?.permissions['can_manage_customers'] ?? false))
                            _sidebarItem(
                              icon: Icons.people_outline,
                              label: "Customers",
                              onTap: () => Get.toNamed(AppRoutes.manageCustomers),
                            ),
                          if (isSuper || (currentAdmin?.permissions['can_manage_leads'] ?? false))
                            _sidebarItem(
                              icon: Icons.contact_phone_outlined,
                              label: "Leads",
                              onTap: () => Get.toNamed(AppRoutes.manageLeads),
                            ),
                          if (isSuper || (currentAdmin?.permissions['can_manage_quotes'] ?? false))
                            _sidebarItem(
                              icon: Icons.receipt_long_outlined,
                              label: "Quotations",
                              onTap: () => Get.toNamed(AppRoutes.manageQuotes),
                            ),
                          if (isSuper || (currentAdmin?.permissions['can_manage_users'] ?? false))
                            _sidebarItem(
                              icon: Icons.admin_panel_settings_outlined,
                              label: "Users",
                              onTap: () => Get.toNamed(AppRoutes.manageUsers),
                            ),
                          _sidebarItem(
                            icon: Icons.rate_review_outlined,
                            label: "Reviews",
                            onTap: () => Get.toNamed('/admin/reviews'),
                          ),
                          if (isSuper || (currentAdmin?.permissions['can_manage_settings'] ?? false))
                            _sidebarItem(
                              icon: Icons.settings_outlined,
                              label: "Settings",
                              onTap: () => Get.toNamed(AppRoutes.systemSettings),
                            ),
                          const Divider(color: Color(0xFF254235), height: 32),
                          _sidebarItem(
                            icon: Icons.logout_outlined,
                            label: "Logout",
                            onTap: () => authController.logout(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Main Content Area
            Expanded(
              child: Scaffold(
                backgroundColor: const Color(0xFF0B1714),
                appBar: AppBar(
                  backgroundColor: const Color(0xFF0D1915),
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Color(0xFFF4F4F4)),
                  leading: MediaQuery.of(context).size.width < 1024
                      ? Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        )
                      : null,
                  title: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFFA4A9A7), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Search menu...",
                        style: AppTheme.sansBody(fontSize: 13, color: const Color(0xFFA4A9A7)),
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
                                  currentAdmin.name.isEmpty ? currentAdmin.email.split('@').first : currentAdmin.name,
                                  style: AppTheme.sansBody(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFF4F4F4),
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
                              backgroundColor: const Color(0xFF162822),
                              child: Text(
                                (currentAdmin.name.isEmpty ? currentAdmin.email : currentAdmin.name)[0].toUpperCase(),
                                style: const TextStyle(color: Color(0xFFC8A26A), fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                  ],
                ),
                drawer: MediaQuery.of(context).size.width < 1024
                    ? Drawer(
                        child: Container(
                          color: const Color(0xFF0D1915),
                          child: Column(
                            children: [
                              DrawerHeader(
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0xFF254235))),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("OE", style: AppTheme.serifHeader(fontSize: 24, color: const Color(0xFFC8A26A))),
                                      Text("OM EVENTS", style: AppTheme.sansBody(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  children: [
                                    _sidebarItem(
                                      icon: Icons.dashboard_outlined,
                                      label: "Dashboard",
                                      isActive: true,
                                      onTap: () => Get.back(),
                                    ),
                                    if (isSuper || (currentAdmin?.permissions['can_manage_categories'] ?? false))
                                      _sidebarItem(
                                        icon: Icons.category_outlined,
                                        label: "Categories",
                                        onTap: () {
                                          Get.back();
                                          Get.toNamed(AppRoutes.manageCategories);
                                        },
                                      ),
                                    if (isSuper || (currentAdmin?.permissions['can_manage_items'] ?? false))
                                      _sidebarItem(
                                        icon: Icons.stars_outlined,
                                        label: "Experiences",
                                        onTap: () {
                                          Get.back();
                                          Get.toNamed(AppRoutes.manageExperiences);
                                        },
                                      ),
                                    if (isSuper || (currentAdmin?.permissions['can_manage_customers'] ?? false))
                                      _sidebarItem(
                                        icon: Icons.people_outline,
                                        label: "Customers",
                                        onTap: () {
                                          Get.back();
                                          Get.toNamed(AppRoutes.manageCustomers);
                                        },
                                      ),
                                    if (isSuper || (currentAdmin?.permissions['can_manage_leads'] ?? false))
                                      _sidebarItem(
                                        icon: Icons.contact_phone_outlined,
                                        label: "Leads",
                                        onTap: () {
                                          Get.back();
                                          Get.toNamed(AppRoutes.manageLeads);
                                        },
                                      ),
                                    if (isSuper || (currentAdmin?.permissions['can_manage_quotes'] ?? false))
                                      _sidebarItem(
                                        icon: Icons.receipt_long_outlined,
                                        label: "Quotations",
                                        onTap: () {
                                          Get.back();
                                          Get.toNamed(AppRoutes.manageQuotes);
                                        },
                                      ),
                                    if (isSuper || (currentAdmin?.permissions['can_manage_users'] ?? false))
                                      _sidebarItem(
                                        icon: Icons.admin_panel_settings_outlined,
                                        label: "Users",
                                        onTap: () {
                                          Get.back();
                                          Get.toNamed(AppRoutes.manageUsers);
                                        },
                                      ),
                                    _sidebarItem(
                                      icon: Icons.rate_review_outlined,
                                      label: "Reviews",
                                      onTap: () {
                                        Get.back();
                                        Get.toNamed('/admin/reviews');
                                      },
                                    ),
                                    if (isSuper || (currentAdmin?.permissions['can_manage_settings'] ?? false))
                                      _sidebarItem(
                                        icon: Icons.settings_outlined,
                                        label: "Settings",
                                        onTap: () {
                                          Get.back();
                                          Get.toNamed(AppRoutes.systemSettings);
                                        },
                                      ),
                                    const Divider(color: Color(0xFF254235), height: 32),
                                    _sidebarItem(
                                      icon: Icons.logout_outlined,
                                      label: "Logout",
                                      onTap: () => authController.logout(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
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
                                  style: AppTheme.sansBody(fontSize: 12, color: const Color(0xFFA4A9A7)),
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
                                _metricCard(
                                  label: "NEW INQUIRIES",
                                  value: controller.leadCount.toString(),
                                  desc: "Active studio leads",
                                  icon: Icons.contact_phone_outlined,
                                  color: const Color(0xFFC8A26A),
                                ),
                                _metricCard(
                                  label: "PROPOSALS SENT",
                                  value: controller.quoteCount.toString(),
                                  desc: "Saved event contracts",
                                  icon: Icons.receipt_long_outlined,
                                  color: const Color(0xFFE0A458),
                                ),
                                _metricCard(
                                  label: "TOTAL PIPELINE",
                                  value: AppFormatters.formatCurrency(controller.pipelineRevenue.value),
                                  desc: "Pending valuation",
                                  icon: Icons.payments_outlined,
                                  color: const Color(0xFF3BA776),
                                ),
                                _metricCard(
                                  label: "ACTIVE CATS",
                                  value: controller.activeCategoriesCount.value.toString(),
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
                            color: const Color(0xFFC8A26A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (isSuper || (currentAdmin?.permissions['can_manage_categories'] ?? false))
                              _actionButton(
                                label: "Add Category",
                                icon: Icons.add_box_outlined,
                                onTap: () => Get.toNamed(AppRoutes.manageCategories),
                              ),
                            if (isSuper || (currentAdmin?.permissions['can_manage_items'] ?? false))
                              _actionButton(
                                label: "Add Experience",
                                icon: Icons.stars_outlined,
                                onTap: () => Get.toNamed(AppRoutes.manageExperiences),
                              ),
                            if (isSuper || (currentAdmin?.permissions['can_manage_quotes'] ?? false))
                              _actionButton(
                                label: "Create Quote",
                                icon: Icons.receipt_outlined,
                                onTap: () => Get.toNamed(AppRoutes.manageQuotes),
                              ),
                            if (isSuper || (currentAdmin?.permissions['can_manage_customers'] ?? false))
                              _actionButton(
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
                                  Expanded(
                                    flex: 3,
                                    child: _chartWidgetSection(),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 2,
                                    child: _recentInquiriesSection(),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _chartWidgetSection(),
                                  const SizedBox(height: 24),
                                  _recentInquiriesSection(),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isActive ? const Color(0xFF1B332B) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive ? const Color(0xFFC8A26A) : const Color(0xFFA4A9A7),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTheme.sansBody(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? const Color(0xFFF4F4F4) : const Color(0xFFA4A9A7),
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 3,
                    height: 16,
                    color: const Color(0xFFC8A26A),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF254235), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTheme.sansBody(
                  fontSize: 10,
                  color: const Color(0xFFA4A9A7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppTheme.serifHeader(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF4F4F4),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      desc,
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        color: const Color(0xFFA4A9A7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF162822),
        foregroundColor: const Color(0xFFF4F4F4),
        side: const BorderSide(color: Color(0xFF254235), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      icon: Icon(icon, size: 16, color: const Color(0xFFC8A26A)),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _chartWidgetSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF254235), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "INQUIRIES TREND",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: const Color(0xFFC8A26A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF11211C),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Last 6 Months",
                  style: AppTheme.sansBody(fontSize: 9, color: const Color(0xFFA4A9A7)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SizedBox(
            height: 180,
            child: DashboardLineChart(
              dataPoints: [12.0, 19.0, 15.0, 24.0, 18.0, 31.0],
              labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
              lineColor: Color(0xFFC8A26A),
              gradientColor: Color(0xFFC8A26A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentInquiriesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF254235), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "LATEST INQUIRIES",
            style: AppTheme.sansBody(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: const Color(0xFFC8A26A),
            ),
          ),
          const SizedBox(height: 16),
          if (controller.rxLeads.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                "No inquiries found.",
                style: AppTheme.sansBody(fontSize: 13, color: const Color(0xFFA4A9A7)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.rxLeads.length > 4 ? 4 : controller.rxLeads.length,
              itemBuilder: (context, index) {
                final lead = controller.rxLeads[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF254235))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lead.name,
                            style: AppTheme.serifHeader(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFF4F4F4)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lead.phone,
                            style: AppTheme.sansBody(fontSize: 11, color: const Color(0xFFA4A9A7)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(lead.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          lead.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(lead.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'contacted':
        return Colors.orange;
      case 'qualified':
        return Colors.indigo;
      case 'won':
        return const Color(0xFF3BA776);
      default:
        return Colors.grey;
    }
  }
}
