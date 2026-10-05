import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/customer_model.dart';
import '../../../domain/entities/quotation.dart';
import '../../controllers/admin_controller.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/customer_details_dialog.dart';
import 'widgets/customer_edit_delete_dialogs.dart';

/// Client statistics calculated from canonical customer records and linked quotations.
class _CustomerStats {
  final double totalSpent;
  final int totalBookings;
  final String effectiveType;

  const _CustomerStats({
    required this.totalSpent,
    required this.totalBookings,
    required this.effectiveType,
  });
}

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
  final RxString rxViewMode = 'table'.obs; // 'table' or 'grid'
  final RxSet<String> rxSelectedCustomerIds = <String>{}.obs;

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  /// Calculates real spending, event count, and client classification.
  _CustomerStats _calculateCustomerStats(CustomerModel customer, List<Quotation> quotes) {
    final cleanCustPhone = customer.phone.replaceAll(RegExp(r'\D'), '');
    final clientQuotes = quotes.where((q) {
      final cleanQuotePhone = q.customerPhone.replaceAll(RegExp(r'\D'), '');
      final phoneMatch = cleanCustPhone.isNotEmpty &&
          cleanQuotePhone.isNotEmpty &&
          (cleanQuotePhone.contains(cleanCustPhone) || cleanCustPhone.contains(cleanQuotePhone));
      final idMatch = customer.id.isNotEmpty && (q.customerId == customer.id || q.customerPhone == customer.id);
      final nameMatch = customer.name.isNotEmpty &&
          q.customerName.trim().toLowerCase() == customer.name.trim().toLowerCase();
      return phoneMatch || idMatch || nameMatch;
    }).toList();

    final int totalBookings = clientQuotes.length;
    final double totalSpent = clientQuotes.fold(0.0, (sum, q) => sum + q.grandTotal);

    String effectiveType = customer.type.trim();
    if (effectiveType.isEmpty || effectiveType.toLowerCase() == 'individual') {
      final hasCorporateQuote = clientQuotes.any((q) =>
          q.items.any((item) =>
              item.name.toLowerCase().contains('corporate') ||
              item.theme.toLowerCase().contains('corporate')) ||
          q.notes.toLowerCase().contains('corporate') ||
          q.notes.toLowerCase().contains('company'));
      if (hasCorporateQuote) {
        effectiveType = 'Corporate';
      } else if (totalSpent >= 50000) {
        effectiveType = 'VIP';
      } else {
        effectiveType = 'Individual';
      }
    }

    return _CustomerStats(
      totalSpent: totalSpent,
      totalBookings: totalBookings,
      effectiveType: effectiveType,
    );
  }

  String _formatRevenueCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return AppFormatters.formatCurrency(amount);
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'C';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryAccent = AppColors.primaryAccent;
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
                  // 1. TOP HEADER (IMAGE 1 SPECIFICATION)
                  _buildHeader(isMobile, textColor, subtitleColor, primaryAccent),
                  const SizedBox(height: 20),

                  // 2. SUMMARY / KPI ROW (IMAGE 1 SPECIFICATION)
                  Obx(() {
                    final allCustomers = controller.rxCustomers.toList();
                    final allQuotes = controller.rxQuotes.toList();

                    final totalClients = allCustomers.length;
                    int vipClients = 0;
                    int corporateClients = 0;
                    double totalRevenue = 0.0;

                    for (final customer in allCustomers) {
                      final stats = _calculateCustomerStats(customer, allQuotes);
                      if (stats.effectiveType == 'VIP' || stats.totalSpent >= 50000) {
                        vipClients++;
                      }
                      if (stats.effectiveType == 'Corporate' || stats.effectiveType == 'Business') {
                        corporateClients++;
                      }
                      totalRevenue += stats.totalSpent;
                    }

                    // Fallback to pipeline revenue if customer quotes are unlinked
                    if (totalRevenue == 0.0 && controller.pipelineRevenue.value > 0.0) {
                      totalRevenue = controller.pipelineRevenue.value;
                    }

                    return _buildKpiRow(
                      isMobile: isMobile,
                      isTablet: isTablet,
                      totalClients: totalClients,
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

                  // 3. SEARCH BAR + SORT + VIEW CONTROLS
                  _buildSearchAndControls(
                    isMobile: isMobile,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    primaryAccent: primaryAccent,
                  ),
                  const SizedBox(height: 20),

                  // 4. MAIN CUSTOMER DIRECTORY (TABLE OR GRID)
                  Obx(() {
                    final isLoading = controller.isLoadingCustomers.value;
                    final hasError = controller.customerLoadError.value.isNotEmpty;
                    final allCustomers = controller.rxCustomers.toList();
                    final allQuotes = controller.rxQuotes.toList();

                    // Loading state
                    if (isLoading && allCustomers.isEmpty) {
                      return _buildLoadingState(subtitleColor, primaryAccent);
                    }

                    // Error state
                    if (hasError && allCustomers.isEmpty) {
                      return _buildErrorState(textColor, subtitleColor, primaryAccent);
                    }

                    // Pure empty state (0 total customers in Firestore)
                    if (allCustomers.isEmpty) {
                      return _buildEmptyState(textColor, subtitleColor, primaryAccent);
                    }

                    // Apply search filtering
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

                    // Apply real sorting
                    final sort = rxSortOption.value;
                    filtered.sort((a, b) {
                      final aStats = _calculateCustomerStats(a, allQuotes);
                      final bStats = _calculateCustomerStats(b, allQuotes);

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

                    // No results state
                    if (filtered.isEmpty) {
                      return _buildNoResultsState(query, textColor, subtitleColor, primaryAccent);
                    }

                    // Render Desktop/Tablet Table view vs Grid/Card view
                    final viewMode = rxViewMode.value;
                    if (isMobile) {
                      return _buildMobileCardList(
                        filtered,
                        allQuotes,
                        cardColor,
                        borderColor,
                        textColor,
                        subtitleColor,
                        primaryAccent,
                      );
                    }

                    if (viewMode == 'grid') {
                      return _buildGridView(
                        filtered,
                        allQuotes,
                        constraints.maxWidth,
                        cardColor,
                        borderColor,
                        textColor,
                        subtitleColor,
                        primaryAccent,
                      );
                    }

                    return _buildTableView(
                      filtered,
                      allQuotes,
                      cardColor,
                      borderColor,
                      textColor,
                      subtitleColor,
                      primaryAccent,
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. TOP HEADER WIDGET
  // ===========================================================================
  Widget _buildHeader(
    bool isMobile,
    Color textColor,
    Color subtitleColor,
    Color primaryAccent,
  ) {
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Client Directory',
              style: AppTheme.serifHeader(
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(width: 12),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C2417),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    '${controller.rxCustomers.length} Total Customers',
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Complete client information with booking insights.',
          style: AppTheme.sansBody(
            fontSize: isMobile ? 12 : 13,
            color: subtitleColor,
          ),
        ),
      ],
    );

    final actionsWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, size: 20, color: primaryAccent),
          tooltip: 'Refresh Customers',
          onPressed: () => controller.loadCustomers(),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Customer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryAccent,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTheme.sansBody(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => Get.dialog(CustomerCreateDialog(controller: controller)),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTheme.sansBody(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Get.dialog(CustomerCreateDialog(controller: controller)),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        titleWidget,
        actionsWidget,
      ],
    );
  }

  // ===========================================================================
  // 2. SUMMARY / KPI ROW WIDGETS
  // ===========================================================================
  Widget _buildKpiRow({
    required bool isMobile,
    required bool isTablet,
    required int totalClients,
    required int vipClients,
    required int corporateClients,
    required double totalRevenue,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subtitleColor,
    required Color primaryAccent,
  }) {
    final cards = [
      _buildKpiCard(
        icon: Icons.people_alt_rounded,
        title: '$totalClients',
        subtitle: 'Total Clients',
        cardColor: cardColor,
        borderColor: borderColor,
        textColor: textColor,
        subtitleColor: subtitleColor,
        primaryAccent: primaryAccent,
      ),
      _buildKpiCard(
        icon: Icons.workspace_premium_rounded,
        title: '$vipClients',
        subtitle: 'VIP Clients',
        cardColor: cardColor,
        borderColor: borderColor,
        textColor: textColor,
        subtitleColor: subtitleColor,
        primaryAccent: primaryAccent,
      ),
      _buildKpiCard(
        icon: Icons.business_center_rounded,
        title: '$corporateClients',
        subtitle: 'Corporate Clients',
        cardColor: cardColor,
        borderColor: borderColor,
        textColor: textColor,
        subtitleColor: subtitleColor,
        primaryAccent: primaryAccent,
      ),
      _buildKpiCard(
        icon: Icons.account_balance_wallet_rounded,
        title: _formatRevenueCompact(totalRevenue),
        subtitle: 'Total Revenue',
        cardColor: cardColor,
        borderColor: borderColor,
        textColor: textColor,
        subtitleColor: subtitleColor,
        primaryAccent: primaryAccent,
      ),
    ];

    if (isMobile) {
      return SizedBox(
        height: 84,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) => SizedBox(width: 190, child: cards[index]),
        ),
      );
    }

    if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 14),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 14),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 16),
        Expanded(child: cards[1]),
        const SizedBox(width: 16),
        Expanded(child: cards[2]),
        const SizedBox(width: 16),
        Expanded(child: cards[3]),
      ],
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subtitleColor,
    required Color primaryAccent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryAccent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTheme.serifHeader(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. SEARCH + CONTROLS BAR
  // ===========================================================================
  Widget _buildSearchAndControls({
    required bool isMobile,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subtitleColor,
    required Color primaryAccent,
  }) {
    final searchField = Container(
      height: 48,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: searchCtrl,
        style: AppTheme.sansBody(fontSize: 13, color: textColor),
        onChanged: (val) => rxSearchQuery.value = val.trim(),
        decoration: InputDecoration(
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          hintText: 'Search client name, email, phone, or city...',
          hintStyle: AppTheme.sansBody(fontSize: 13, color: subtitleColor),
          prefixIcon: Icon(Icons.search_rounded, color: primaryAccent, size: 20),
          suffixIcon: Obx(() => rxSearchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  color: subtitleColor,
                  onPressed: () {
                    searchCtrl.clear();
                    rxSearchQuery.value = '';
                  },
                )
              : const SizedBox.shrink()),
        ),
      ),
    );

    final sortWidget = Obx(() => Container(
          height: 48,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: PopupMenuButton<String>(
            tooltip: 'Sort Options',
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: borderColor),
            ),
            initialValue: rxSortOption.value,
            onSelected: (val) => rxSortOption.value = val,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Latest', child: Text('Sort: Latest')),
              PopupMenuItem(value: 'Oldest', child: Text('Sort: Oldest')),
              PopupMenuItem(value: 'Highest Spending', child: Text('Sort: Highest Spending')),
              PopupMenuItem(value: 'Lowest Spending', child: Text('Sort: Lowest Spending')),
              PopupMenuItem(value: 'Most Bookings', child: Text('Sort: Most Bookings')),
              PopupMenuItem(value: 'Least Bookings', child: Text('Sort: Least Bookings')),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sort: ${rxSortOption.value}',
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down_rounded, color: primaryAccent, size: 18),
              ],
            ),
          ),
        ));

    final viewControls = Obx(() => Container(
          height: 48,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewModeButton(
                icon: Icons.table_rows_rounded,
                tooltip: 'Table Directory View',
                isSelected: rxViewMode.value == 'table',
                primaryAccent: primaryAccent,
                onTap: () => rxViewMode.value = 'table',
              ),
              const SizedBox(width: 4),
              _buildViewModeButton(
                icon: Icons.grid_view_rounded,
                tooltip: 'Grid Card View',
                isSelected: rxViewMode.value == 'grid',
                primaryAccent: primaryAccent,
                onTap: () => rxViewMode.value = 'grid',
              ),
            ],
          ),
        ));

    if (isMobile) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: sortWidget),
              const SizedBox(width: 10),
              viewControls,
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 14),
        sortWidget,
        const SizedBox(width: 12),
        viewControls,
      ],
    );
  }

  Widget _buildViewModeButton({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required Color primaryAccent,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isSelected ? primaryAccent.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? primaryAccent.withValues(alpha: 0.4) : Colors.transparent,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? primaryAccent : Colors.white54,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. MAIN CUSTOMER DIRECTORY - TABLE VIEW (IMAGE 1 PRIMARY LAYOUT)
  // ===========================================================================
  Widget _buildTableView(
    List<CustomerModel> customers,
    List<Quotation> quotes,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subtitleColor,
    Color primaryAccent,
  ) {
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
                  // Checkbox
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
                  _buildTableHeaderCell('CLIENT', width: 250, textColor: subtitleColor),
                  _buildTableHeaderCell('TYPE', width: 120, textColor: subtitleColor),
                  _buildTableHeaderCell('CONTACT', width: 220, textColor: subtitleColor),
                  _buildTableHeaderCell('LOCATION', width: 140, textColor: subtitleColor),
                  _buildTableHeaderCell('TOTAL SPENDING', width: 140, textColor: subtitleColor),
                  _buildTableHeaderCell('EVENTS', width: 80, textColor: subtitleColor),
                  _buildTableHeaderCell('ACTIONS', width: 110, textColor: subtitleColor),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Table Data Rows
            ...customers.map((customer) {
              final stats = _calculateCustomerStats(customer, quotes);
              return _buildTableRow(
                customer: customer,
                stats: stats,
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

  Widget _buildTableHeaderCell(String title, {required double width, required Color textColor}) {
    return SizedBox(
      width: width,
      child: Text(
        title,
        style: AppTheme.sansBody(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTableRow({
    required CustomerModel customer,
    required _CustomerStats stats,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subtitleColor,
    required Color primaryAccent,
  }) {
    final initials = _getInitials(customer.name);
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
          color: isSelected
              ? primaryAccent.withValues(alpha: 0.08)
              : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryAccent.withValues(alpha: 0.4)
                : borderColor.withValues(alpha: 0.8),
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
            // Checkbox
            SizedBox(
              width: 36,
              child: Checkbox(
                value: isSelected,
                activeColor: primaryAccent,
                checkColor: Colors.black,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (val) {
                  if (val == true) {
                    rxSelectedCustomerIds.add(customer.id);
                  } else {
                    rxSelectedCustomerIds.remove(customer.id);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),

            // CLIENT COLUMN (AVATAR + NAME + SUBTITLE)
            SizedBox(
              width: 250,
              child: Row(
                children: [
                  _buildAvatar(customer, initials, primaryAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          customer.name.isNotEmpty ? customer.name : 'Client ${customer.id}',
                          style: AppTheme.sansBody(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${stats.effectiveType} Client',
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            color: subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // TYPE COLUMN
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
                      color: stats.effectiveType == 'VIP'
                          ? primaryAccent.withValues(alpha: 0.4)
                          : const Color(0xFF274433),
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

            // CONTACT COLUMN (PHONE + EMAIL)
            SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayPhone,
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayEmail,
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // LOCATION COLUMN
            SizedBox(
              width: 140,
              child: Text(
                displayLocation,
                style: AppTheme.sansBody(
                  fontSize: 13,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // TOTAL SPENDING COLUMN
            SizedBox(
              width: 140,
              child: Text(
                AppFormatters.formatCurrency(stats.totalSpent),
                style: AppTheme.serifHeader(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryAccent,
                ),
              ),
            ),

            // EVENTS COLUMN
            SizedBox(
              width: 80,
              child: Text(
                '${stats.totalBookings}',
                style: AppTheme.sansBody(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            // ACTIONS COLUMN
            SizedBox(
              width: 110,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility_outlined, size: 18, color: textColor.withValues(alpha: 0.7)),
                    tooltip: 'View Details',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => Get.dialog(
                      CustomerDetailsDialog(customer: customer, controller: controller),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 18, color: textColor.withValues(alpha: 0.7)),
                    tooltip: 'Edit Client',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => Get.dialog(
                      CustomerEditDialog(customer: customer, controller: controller),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    tooltip: 'Delete Client',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => Get.dialog(
                      CustomerDeleteDialog(customer: customer, controller: controller),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ===========================================================================
  // 5. GRID / CARD VIEW (IMAGE 1 SECONDARY LAYOUT)
  // ===========================================================================
  Widget _buildGridView(
    List<CustomerModel> customers,
    List<Quotation> quotes,
    double maxWidth,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subtitleColor,
    Color primaryAccent,
  ) {
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
            final stats = _calculateCustomerStats(customer, quotes);
            final initials = _getInitials(customer.name);
            final displayPhone = customer.phone.isNotEmpty ? customer.phone : '—';
            final displayEmail = customer.email.isNotEmpty ? customer.email : '—';
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
                    // Header row: Avatar + Name + Subtitle + Type
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatar(customer, initials, primaryAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name.isNotEmpty ? customer.name : 'Client ${customer.id}',
                                style: AppTheme.sansBody(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${stats.effectiveType} Client',
                                style: AppTheme.sansBody(fontSize: 11, color: subtitleColor),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF132219),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: stats.effectiveType == 'VIP'
                                  ? primaryAccent.withValues(alpha: 0.4)
                                  : const Color(0xFF274433),
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
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Metrics row: Spending & Events
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LIFETIME SPENDING',
                              style: AppTheme.sansBody(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: subtitleColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppFormatters.formatCurrency(stats.totalSpent),
                              style: AppTheme.serifHeader(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryAccent,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TOTAL BOOKINGS',
                              style: AppTheme.sansBody(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: subtitleColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${stats.totalBookings} Events',
                              style: AppTheme.sansBody(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Contact & Location
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: primaryAccent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            displayPhone,
                            style: AppTheme.sansBody(fontSize: 12, color: textColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.location_on_outlined, size: 14, color: primaryAccent),
                        const SizedBox(width: 4),
                        Text(
                          displayLocation,
                          style: AppTheme.sansBody(fontSize: 12, color: textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    if (customer.email.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 14, color: subtitleColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              displayEmail,
                              style: AppTheme.sansBody(fontSize: 11, color: subtitleColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Actions row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.visibility_outlined, size: 16, color: primaryAccent),
                          label: Text(
                            'VIEW',
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryAccent,
                            ),
                          ),
                          onPressed: () => Get.dialog(
                            CustomerDetailsDialog(customer: customer, controller: controller),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, size: 18, color: textColor.withValues(alpha: 0.7)),
                          tooltip: 'Edit Client',
                          onPressed: () => Get.dialog(
                            CustomerEditDialog(customer: customer, controller: controller),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                          tooltip: 'Delete Client',
                          onPressed: () => Get.dialog(
                            CustomerDeleteDialog(customer: customer, controller: controller),
                          ),
                        ),
                      ],
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

  // ===========================================================================
  // 6. MOBILE CARD LIST (IMAGE 1 MOBILE REFERENCE)
  // ===========================================================================
  Widget _buildMobileCardList(
    List<CustomerModel> customers,
    List<Quotation> quotes,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subtitleColor,
    Color primaryAccent,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: customers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final customer = customers[index];
        final stats = _calculateCustomerStats(customer, quotes);
        final initials = _getInitials(customer.name);

        return InkWell(
          onTap: () => Get.dialog(CustomerDetailsDialog(customer: customer, controller: controller)),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                _buildAvatar(customer, initials, primaryAccent, size: 44),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name.isNotEmpty ? customer.name : 'Client ${customer.id}',
                        style: AppTheme.sansBody(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${stats.effectiveType} Client',
                        style: AppTheme.sansBody(fontSize: 11, color: subtitleColor),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _formatRevenueCompact(stats.totalSpent),
                            style: AppTheme.serifHeader(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryAccent,
                            ),
                          ),
                          Text(
                            ' • ${stats.totalBookings} Events',
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: primaryAccent.withValues(alpha: 0.6),
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 7. AVATAR WIDGET (IMAGE OR INITIALS GRADIENT)
  // ===========================================================================
  Widget _buildAvatar(CustomerModel customer, String initials, Color primaryAccent, {double size = 40}) {
    if (customer.profileImageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          customer.profileImageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(initials, primaryAccent, size),
        ),
      );
    }
    return _buildInitialsAvatar(initials, primaryAccent, size);
  }

  Widget _buildInitialsAvatar(String initials, Color primaryAccent, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryAccent.withValues(alpha: 0.25),
            primaryAccent.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: primaryAccent.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTheme.serifHeader(
            fontSize: size * 0.38,
            fontWeight: FontWeight.bold,
            color: primaryAccent,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 8. EMPTY, LOADING & ERROR STATES
  // ===========================================================================
  Widget _buildLoadingState(Color subtitleColor, Color primaryAccent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: primaryAccent, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text(
            'Loading client directory...',
            style: AppTheme.sansBody(fontSize: 13, color: subtitleColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color textColor, Color subtitleColor, Color primaryAccent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            'Unable to load customers',
            style: AppTheme.serifHeader(fontSize: 18, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            controller.customerLoadError.value,
            style: AppTheme.sansBody(fontSize: 12, color: subtitleColor),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('RETRY'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () => controller.loadCustomers(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subtitleColor, Color primaryAccent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: primaryAccent.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No Customers Found',
            style: AppTheme.serifHeader(fontSize: 20, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Your customer directory is currently empty.',
            style: AppTheme.sansBody(fontSize: 13, color: subtitleColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('ADD FIRST CLIENT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: () => Get.dialog(CustomerCreateDialog(controller: controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(
    String query,
    Color textColor,
    Color subtitleColor,
    Color primaryAccent,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: subtitleColor),
          const SizedBox(height: 12),
          Text(
            "No clients match '$query'",
            style: AppTheme.serifHeader(fontSize: 18, color: textColor),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              searchCtrl.clear();
              rxSearchQuery.value = '';
            },
            child: Text(
              'CLEAR SEARCH',
              style: AppTheme.sansBody(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: primaryAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
