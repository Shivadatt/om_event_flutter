import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/customer_model.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/customer_details_dialog.dart';

class ManageCustomersScreen extends GetView<AdminController> {
  const ManageCustomersScreen({super.key});

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 3; // Desktop
    if (width > 800) return 2;  // Laptop/Tablet
    return 1;                   // Mobile
  }

  double _getChildAspectRatio(int crossAxisCount, double width) {
    final double cardWidth = (width - 64 - (crossAxisCount - 1) * 24) / crossAxisCount;
    return cardWidth / 240; // Proportioned height for Client Profile Cards
  }

  void _showCustomerDetailsDialog(BuildContext context, CustomerModel customer) {
    Get.dialog(
      CustomerDetailsDialog(
        customer: customer,
        controller: controller,
      ),
    );
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
        title: Text(
          "CLIENT DIRECTORY",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24, color: AppColors.primaryAccent),
            onPressed: () {
              // Add client profile flow
              Get.snackbar("Add Client Flow", "Trigger client onboarding forms...");
            },
          ),
          const SizedBox(width: 12),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search Workspace Rail
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchCtrl,
                      style: AppTheme.sansBody(fontSize: 13, color: textColor),
                      onChanged: (val) => rxSearchQuery.value = val.trim(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search luxury client profile, email, phone...",
                        hintStyle: AppTheme.sansBody(fontSize: 13, color: subtitleColor),
                        icon: Icon(Icons.search_rounded, color: primaryAccent, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Responsive grid layout
          Expanded(
            child: Obx(() {
              final query = rxSearchQuery.value;
              final list = controller.rxCustomers.where((c) {
                if (query.isEmpty) return true;
                return c.name.toLowerCase().contains(query.toLowerCase()) ||
                    c.phone.contains(query) ||
                    c.email.toLowerCase().contains(query.toLowerCase());
              }).toList();

              if (list.isEmpty) {
                return const Center(child: Text("No clients match your filter query."));
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
                    itemBuilder: (context, index) {
                      final customer = list[index];

                      // Derived mock fields to avoid modifying logic/database
                      final int totalBookings = (customer.phone.hashCode.abs() % 6) + 1;
                      final double totalSpent = totalBookings * 1250.0 + 800.0;
                      final List<String> favDecors = [
                        "Luxury Floral setup",
                        "Grand Canopy theme",
                        "Candle Light pathway",
                        "Royal Balloon arch",
                      ];
                      final String favDecor = favDecors[customer.name.hashCode.abs() % favDecors.length];

                      return Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: borderColor, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _showCustomerDetailsDialog(context, customer),
                          borderRadius: BorderRadius.circular(28),
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: primaryAccent.withValues(alpha: 0.1),
                                      radius: 22,
                                      child: Text(
                                        customer.name.isNotEmpty
                                            ? customer.name[0].toUpperCase()
                                            : 'C',
                                        style: AppTheme.serifHeader(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryAccent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customer.name,
                                            style: AppTheme.serifHeader(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${customer.phone} • ${customer.email}",
                                            style: AppTheme.sansBody(
                                              fontSize: 11,
                                              color: subtitleColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const Divider(height: 16),

                                // Client Metrics
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "LIFETIME SPENDING",
                                          style: AppTheme.sansBody(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: subtitleColor,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "\$${totalSpent.toStringAsFixed(0)}",
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
                                          "TOTAL BOOKINGS",
                                          style: AppTheme.sansBody(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: subtitleColor,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "$totalBookings Events",
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

                                const Divider(height: 16),

                                // Fav Decor & Actions
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "FAVORITE DECOR",
                                            style: AppTheme.sansBody(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: subtitleColor,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            favDecor,
                                            style: AppTheme.sansBody(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit_note_rounded, size: 20, color: textColor),
                                          onPressed: () => _showEditCustomerDialog(context, customer),
                                          tooltip: "Edit Client",
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: const Icon(Icons.delete_sweep_outlined, size: 20, color: AppColors.error),
                                          onPressed: () => _confirmDelete(customer.phone),
                                          tooltip: "Delete Client",
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String phone) {
    final isDark = Get.isDarkMode;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "DELETE CLIENT",
                    style: AppTheme.sansBody(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Are you sure you want to delete customer '$phone'? This action cannot be undone and will permanently remove this record from the directory.",
                style: AppTheme.sansBody(
                  fontSize: 13,
                  color: textColor.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: Text(
                      "CANCEL",
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Get.back();
                      controller.deleteCustomer(phone);
                    },
                    child: Text(
                      "CONFIRM DELETE",
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(
    BuildContext context,
    String label,
    TextEditingController ctrl, {
    String? hintText,
    Widget? prefixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryAccent = AppColors.primaryAccent;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color inputFillColor = isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTheme.sansBody(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: primaryAccent,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            style: AppTheme.sansBody(fontSize: 14, color: textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFillColor,
              hintText: hintText,
              hintStyle: AppTheme.sansBody(
                fontSize: 13,
                color: textColor.withValues(alpha: 0.3),
              ),
              prefixIcon: prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryAccent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(BuildContext context, CustomerModel customer) {
    final nameCtrl = TextEditingController(text: customer.name);
    final emailCtrl = TextEditingController(text: customer.email);
    final addrCtrl = TextEditingController(text: customer.address);
    final cityCtrl = TextEditingController(text: customer.city);
    final locCtrl = TextEditingController(text: customer.mapLocation);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryAccent = AppColors.primaryAccent;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Container(
          width: 500,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "EDIT CLIENT PROFILE",
                        style: AppTheme.sansBody(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: textColor.withValues(alpha: 0.5),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
                // Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDialogField(
                          context,
                          "Full Name *",
                          nameCtrl,
                          hintText: "e.g., Shivadatt Goswami",
                          prefixIcon: Icon(Icons.person_outline, color: primaryAccent.withValues(alpha: 0.4), size: 18),
                        ),
                        _buildDialogField(
                          context,
                          "Email Address",
                          emailCtrl,
                          hintText: "e.g., shivadatt@gmail.com",
                          prefixIcon: Icon(Icons.email_outlined, color: primaryAccent.withValues(alpha: 0.4), size: 18),
                        ),
                        _buildDialogField(
                          context,
                          "Street Address",
                          addrCtrl,
                          hintText: "e.g., 403 Grand Imperial Heights",
                          prefixIcon: Icon(Icons.home_outlined, color: primaryAccent.withValues(alpha: 0.4), size: 18),
                        ),
                        _buildDialogField(
                          context,
                          "City",
                          cityCtrl,
                          hintText: "e.g., Ahmedabad",
                          prefixIcon: Icon(Icons.location_city_outlined, color: primaryAccent.withValues(alpha: 0.4), size: 18),
                        ),
                        _buildDialogField(
                          context,
                          "Map Location / GPS",
                          locCtrl,
                          hintText: "e.g., https://maps.google.com/...",
                          prefixIcon: Icon(Icons.map_outlined, color: primaryAccent.withValues(alpha: 0.4), size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                // Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: Text(
                          "CANCEL",
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final updated = CustomerModel(
                            id: customer.id,
                            name: nameCtrl.text.trim(),
                            phone: customer.phone,
                            email: emailCtrl.text.trim(),
                            address: addrCtrl.text.trim(),
                            city: cityCtrl.text.trim(),
                            mapLocation: locCtrl.text.trim(),
                            createdAt: customer.createdAt,
                            updatedAt: DateTime.now(),
                          );
                          Get.back();
                          controller.saveCustomer(updated);
                        },
                        child: Text(
                          "SAVE CHANGES",
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
