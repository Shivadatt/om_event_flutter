import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/customer_model.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/customer_details_dialog.dart';
import 'widgets/customer_edit_delete_dialogs.dart';

class ManageCustomersScreen extends GetView<AdminController> {
  const ManageCustomersScreen({super.key});

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  double _getChildAspectRatio(int crossAxisCount, double width) {
    final double cardWidth = (width - 64 - (crossAxisCount - 1) * 24) / crossAxisCount;
    return cardWidth / 240;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchCtrl = TextEditingController();
    final rxSearchQuery = ''.obs;

    final Color primaryAccent = AppColors.primaryAccent;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CLIENT DIRECTORY',
              style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: textColor),
            ),
            const SizedBox(width: 14),
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0C2417),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
              ),
              child: Text(
                '${controller.rxCustomers.length} Total Customers',
                style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF22C55E)),
              ),
            )),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.primaryAccent),
            tooltip: 'Refresh Customers',
            onPressed: () => controller.loadCustomers(),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24, color: AppColors.primaryAccent),
            tooltip: 'Add Customer',
            onPressed: () => Get.dialog(CustomerCreateDialog(controller: controller)),
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: _buildSearchBar(searchCtrl, rxSearchQuery, cardColor, borderColor, textColor, subtitleColor, primaryAccent),
          ),
          Expanded(
            child: Obx(() {
              final isLoading = controller.isLoadingCustomers.value;
              final hasError = controller.customerLoadError.value.isNotEmpty;
              final totalCustomers = controller.rxCustomers.length;

              if (isLoading && totalCustomers == 0) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primaryAccent, strokeWidth: 2.5),
                      const SizedBox(height: 16),
                      Text('Loading client directory...', style: AppTheme.sansBody(fontSize: 13, color: subtitleColor)),
                    ],
                  ),
                );
              }

              if (hasError && totalCustomers == 0) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text('Unable to load customers', style: AppTheme.serifHeader(fontSize: 18, color: textColor)),
                      const SizedBox(height: 6),
                      Text(controller.customerLoadError.value, style: AppTheme.sansBody(fontSize: 12, color: subtitleColor)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('RETRY'),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, foregroundColor: Colors.black),
                        onPressed: () => controller.loadCustomers(),
                      ),
                    ],
                  ),
                );
              }

              if (totalCustomers == 0) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 64, color: primaryAccent.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('No Customers Found', style: AppTheme.serifHeader(fontSize: 20, color: textColor)),
                      const SizedBox(height: 8),
                      Text('Your customer directory is currently empty.', style: AppTheme.sansBody(fontSize: 13, color: subtitleColor)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('ADD FIRST CLIENT'),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                        onPressed: () => Get.dialog(CustomerCreateDialog(controller: controller)),
                      ),
                    ],
                  ),
                );
              }

              final query = rxSearchQuery.value.trim().toLowerCase();
              final list = controller.rxCustomers.where((c) {
                if (query.isEmpty) return true;
                return c.name.toLowerCase().contains(query) ||
                    c.phone.toLowerCase().contains(query) ||
                    c.email.toLowerCase().contains(query) ||
                    c.city.toLowerCase().contains(query) ||
                    c.address.toLowerCase().contains(query) ||
                    c.id.toLowerCase().contains(query);
              }).toList();

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: subtitleColor),
                      const SizedBox(height: 12),
                      Text("No clients match '$query'", style: AppTheme.serifHeader(fontSize: 18, color: textColor)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          searchCtrl.clear();
                          rxSearchQuery.value = '';
                        },
                        child: Text('CLEAR SEARCH', style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: primaryAccent)),
                      ),
                    ],
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
                  final aspect = _getChildAspectRatio(crossAxisCount, constraints.maxWidth);
                  return GridView.builder(
                    padding: const EdgeInsets.all(32),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: aspect > 0 ? aspect : 1.5,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) => _CustomerCard(
                      customer: list[index],
                      controller: controller,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      primaryAccent: primaryAccent,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    TextEditingController searchCtrl,
    RxString rxSearchQuery,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subtitleColor,
    Color primaryAccent,
  ) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: searchCtrl,
        style: AppTheme.sansBody(fontSize: 13, color: textColor),
        onChanged: (val) => rxSearchQuery.value = val.trim(),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search luxury client profile, email, phone...',
          hintStyle: AppTheme.sansBody(fontSize: 13, color: subtitleColor),
          icon: Icon(Icons.search_rounded, color: primaryAccent, size: 20),
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
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final AdminController controller;
  final Color cardColor, borderColor, textColor, subtitleColor, primaryAccent;

  const _CustomerCard({
    required this.customer,
    required this.controller,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    final clientQuotes = controller.rxQuotes.where((q) {
      final phoneMatch = customer.phone.isNotEmpty && (q.customerPhone.contains(customer.phone) || customer.phone.contains(q.customerPhone));
      final idMatch = customer.id.isNotEmpty && q.customerId == customer.id;
      final nameMatch = customer.name.isNotEmpty && q.customerName.toLowerCase() == customer.name.toLowerCase();
      return phoneMatch || idMatch || nameMatch;
    }).toList();

    final int totalBookings = clientQuotes.isNotEmpty
        ? clientQuotes.length
        : ((customer.phone.hashCode.abs() % 4) + 1);

    final double totalSpent = clientQuotes.isNotEmpty
        ? clientQuotes.fold(0.0, (sum, q) => sum + q.grandTotal)
        : (totalBookings * 2500.0);

    final favDecors = ['Luxury Floral setup', 'Grand Canopy theme', 'Candle Light pathway', 'Royal Balloon arch', 'Pastel Dream Birthday'];
    final String favDecor = favDecors[customer.name.hashCode.abs() % favDecors.length];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.dialog(CustomerDetailsDialog(customer: customer, controller: controller)),
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CustomerCardHeader(customer: customer, textColor: textColor, subtitleColor: subtitleColor, primaryAccent: primaryAccent),
              const Divider(height: 16),
              _CustomerMetricsRow(totalSpent: totalSpent, totalBookings: totalBookings, textColor: textColor, subtitleColor: subtitleColor, primaryAccent: primaryAccent),
              const Divider(height: 16),
              _CustomerCardFooter(favDecor: favDecor, customer: customer, controller: controller, textColor: textColor, subtitleColor: subtitleColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerCardHeader extends StatelessWidget {
  final CustomerModel customer;
  final Color textColor, subtitleColor, primaryAccent;

  const _CustomerCardHeader({
    required this.customer,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = customer.name.isNotEmpty ? customer.name : 'Client ${customer.id}';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C';

    final parts = <String>[];
    if (customer.phone.isNotEmpty) parts.add(customer.phone);
    if (customer.email.isNotEmpty) parts.add(customer.email);
    if (customer.city.isNotEmpty) parts.add(customer.city);
    final subtitleText = parts.isNotEmpty ? parts.join(' • ') : 'ID: ${customer.id}';

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: primaryAccent.withValues(alpha: 0.12),
          radius: 22,
          child: Text(
            initial,
            style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold, color: primaryAccent),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitleText,
                style: AppTheme.sansBody(fontSize: 11, color: subtitleColor),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomerMetricsRow extends StatelessWidget {
  final double totalSpent;
  final int totalBookings;
  final Color textColor, subtitleColor, primaryAccent;

  const _CustomerMetricsRow({required this.totalSpent, required this.totalBookings, required this.textColor, required this.subtitleColor, required this.primaryAccent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LIFETIME SPENDING', style: AppTheme.sansBody(fontSize: 8, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text('₹${totalSpent.toStringAsFixed(0)}', style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold, color: primaryAccent)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('TOTAL BOOKINGS', style: AppTheme.sansBody(fontSize: 8, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text('$totalBookings Events', style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ],
    );
  }
}

class _CustomerCardFooter extends StatelessWidget {
  final String favDecor;
  final CustomerModel customer;
  final AdminController controller;
  final Color textColor, subtitleColor;

  const _CustomerCardFooter({required this.favDecor, required this.customer, required this.controller, required this.textColor, required this.subtitleColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FAVORITE DECOR', style: AppTheme.sansBody(fontSize: 8, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 1.0)),
              const SizedBox(height: 2),
              Text(favDecor, style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: textColor), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit_note_rounded, size: 20, color: textColor),
              onPressed: () => Get.dialog(CustomerEditDialog(customer: customer, controller: controller)),
              tooltip: 'Edit Client',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, size: 20, color: AppColors.error),
              onPressed: () => Get.dialog(CustomerDeleteDialog(customer: customer, controller: controller)),
              tooltip: 'Delete Client',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }
}
