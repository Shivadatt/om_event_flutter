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
        title: Text('CLIENT DIRECTORY', style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: textColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24, color: AppColors.primaryAccent),
            onPressed: () => Get.snackbar('Add Client Flow', 'Trigger client onboarding forms...'),
          ),
          const SizedBox(width: 12),
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
              final query = rxSearchQuery.value;
              final list = controller.rxCustomers.where((c) {
                if (query.isEmpty) return true;
                return c.name.toLowerCase().contains(query.toLowerCase()) ||
                    c.phone.contains(query) ||
                    c.email.toLowerCase().contains(query.toLowerCase());
              }).toList();

              if (list.isEmpty) return const Center(child: Text('No clients match your filter query.'));

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
    final int totalBookings = (customer.phone.hashCode.abs() % 6) + 1;
    final double totalSpent = totalBookings * 1250.0 + 800.0;
    final favDecors = ['Luxury Floral setup', 'Grand Canopy theme', 'Candle Light pathway', 'Royal Balloon arch'];
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

  const _CustomerCardHeader({required this.customer, required this.textColor, required this.subtitleColor, required this.primaryAccent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: primaryAccent.withValues(alpha: 0.1),
          radius: 22,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
            style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold, color: primaryAccent),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.name, style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold, color: textColor), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(' • ', style: AppTheme.sansBody(fontSize: 11, color: subtitleColor), overflow: TextOverflow.ellipsis),
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
            Text('\$${totalSpent.toStringAsFixed(0)}', style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold, color: primaryAccent)),
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
              onPressed: () => Get.dialog(CustomerDeleteDialog(phone: customer.phone, controller: controller)),
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
