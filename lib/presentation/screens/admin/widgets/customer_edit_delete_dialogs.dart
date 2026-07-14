import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../controllers/admin_controller.dart';
import '../../../../data/models/customer_model.dart';

/// Dialog for confirming customer deletion from the admin directory.
class CustomerDeleteDialog extends StatelessWidget {
  final String phone;
  final AdminController controller;

  const CustomerDeleteDialog({super.key, required this.phone, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12))],
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
                  child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
                ),
                const SizedBox(width: 16),
                Text('DELETE CLIENT', style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: textColor)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Are you sure you want to delete customer '$phone'? This action cannot be undone.",
              style: AppTheme.sansBody(fontSize: 13, color: textColor.withValues(alpha: 0.7), height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  child: Text('CANCEL', style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.6))),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 0,
                  ),
                  onPressed: () { Get.back(); controller.deleteCustomer(phone); },
                  child: Text('CONFIRM DELETE', style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for editing a customer profile in the admin directory.
class CustomerEditDialog extends StatefulWidget {
  final CustomerModel customer;
  final AdminController controller;

  const CustomerEditDialog({super.key, required this.customer, required this.controller});

  @override
  State<CustomerEditDialog> createState() => _CustomerEditDialogState();
}

class _CustomerEditDialogState extends State<CustomerEditDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController addrCtrl;
  late final TextEditingController cityCtrl;
  late final TextEditingController locCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.customer.name);
    emailCtrl = TextEditingController(text: widget.customer.email);
    addrCtrl = TextEditingController(text: widget.customer.address);
    cityCtrl = TextEditingController(text: widget.customer.city);
    locCtrl = TextEditingController(text: widget.customer.mapLocation);
  }

  @override
  void dispose() {
    nameCtrl.dispose(); emailCtrl.dispose(); addrCtrl.dispose(); cityCtrl.dispose(); locCtrl.dispose();
    super.dispose();
  }

  Widget _buildField(BuildContext context, String label, TextEditingController ctrl, {String? hint, Widget? prefixIcon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color inputFill = isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTheme.sansBody(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryAccent, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            style: AppTheme.sansBody(fontSize: 14, color: textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFill,
              hintText: hint,
              hintStyle: AppTheme.sansBody(fontSize: 13, color: textColor.withValues(alpha: 0.3)),
              prefixIcon: prefixIcon,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor, width: 1.2)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor, width: 1.2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(textColor, borderColor),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildField(context, 'Full Name *', nameCtrl, hint: 'e.g., Shivadatt Goswami', prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryAccent.withValues(alpha: 0.4), size: 18)),
                      _buildField(context, 'Email Address', emailCtrl, hint: 'e.g., shivadatt@gmail.com', prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.4), size: 18)),
                      _buildField(context, 'Street Address', addrCtrl, hint: 'e.g., 403 Grand Imperial Heights', prefixIcon: Icon(Icons.home_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.4), size: 18)),
                      _buildField(context, 'City', cityCtrl, hint: 'e.g., Ahmedabad', prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.4), size: 18)),
                      _buildField(context, 'Map Location / GPS', locCtrl, hint: 'e.g., https://maps.google.com/...', prefixIcon: Icon(Icons.map_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.4), size: 18)),
                    ],
                  ),
                ),
              ),
              _buildActions(textColor, borderColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('EDIT CLIENT PROFILE', style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: textColor)),
          IconButton(icon: const Icon(Icons.close_rounded), color: textColor.withValues(alpha: 0.5), onPressed: () => Get.back()),
        ],
      ),
    );
  }

  Widget _buildActions(Color textColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor, width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            child: Text('CANCEL', style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.6))),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 0,
            ),
            onPressed: () {
              final updated = CustomerModel(
                id: widget.customer.id,
                name: nameCtrl.text.trim(),
                phone: widget.customer.phone,
                email: emailCtrl.text.trim(),
                address: addrCtrl.text.trim(),
                city: cityCtrl.text.trim(),
                mapLocation: locCtrl.text.trim(),
                createdAt: widget.customer.createdAt,
                updatedAt: DateTime.now(),
              );
              Get.back();
              widget.controller.saveCustomer(updated);
            },
            child: Text('SAVE CHANGES', style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
