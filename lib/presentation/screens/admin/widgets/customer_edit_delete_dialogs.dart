import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../controllers/admin_controller.dart';
import '../../../../data/models/customer_model.dart';

/// Helper to safely dismiss modal dialogs without triggering GetX snackbar route collisions.
void _dismissDialog(BuildContext context, [dynamic result]) {
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop(result);
  } else if (Get.isDialogOpen == true) {
    Get.back(result: result);
  }
}

/// Dialog for confirming customer deletion from the admin directory.
class CustomerDeleteDialog extends StatelessWidget {
  final CustomerModel customer;
  final AdminController controller;

  const CustomerDeleteDialog({
    super.key,
    required this.customer,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    final displayName = customer.name.isNotEmpty ? customer.name : customer.phone;
    final displayPhone = customer.phone.isNotEmpty ? customer.phone : customer.id;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 440,
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
                  child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  'DELETE CLIENT',
                  style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Are you sure you want to permanently delete '$displayName' ($displayPhone)?\n\nThis customer record will be permanently deleted from the database. Historical quotations and bookings will remain preserved.",
              style: AppTheme.sansBody(fontSize: 13, color: textColor.withValues(alpha: 0.7), height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _dismissDialog(context),
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
                  onPressed: () async {
                    _dismissDialog(context, true);
                    final targetId = customer.id.isNotEmpty ? customer.id : customer.phone;
                    final ok = await controller.deleteCustomer(targetId);
                    if (ok) {
                      Get.snackbar(
                        "Client Deleted",
                        "Client '$displayName' deleted successfully.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF132219),
                        colorText: const Color(0xFFD4AF37),
                        duration: const Duration(seconds: 3),
                      );
                    }
                  },
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

/// Dialog for creating a new customer profile in the admin directory.
class CustomerCreateDialog extends StatefulWidget {
  final AdminController controller;

  const CustomerCreateDialog({super.key, required this.controller});

  @override
  State<CustomerCreateDialog> createState() => _CustomerCreateDialogState();
}

class _CustomerCreateDialogState extends State<CustomerCreateDialog> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addrCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final locCtrl = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addrCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    locCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = nameCtrl.text.trim();
    final rawPhone = phoneCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Full Name is required.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final cleanDigits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.length < 10) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid 10-digit phone number.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid email address.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final tenDigit = cleanDigits.length >= 10
        ? cleanDigits.substring(cleanDigits.length - 10)
        : cleanDigits;

    final newCustomer = CustomerModel(
      id: tenDigit,
      name: name,
      phone: tenDigit,
      email: email,
      address: addrCtrl.text.trim(),
      city: cityCtrl.text.trim(),
      state: stateCtrl.text.trim(),
      mapLocation: locCtrl.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() => isSaving = true);
    try {
      _dismissDialog(context, true);
      final ok = await widget.controller.createCustomer(newCustomer);
      if (ok) {
        Get.snackbar(
          "Client Created",
          "Client '$name' added to directory.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF132219),
          colorText: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget _buildField(
    BuildContext context,
    String label,
    TextEditingController ctrl, {
    String? hint,
    Widget? prefixIcon,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color inputFill = isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTheme.sansBody(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryAccent, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: 1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ADD NEW CLIENT', style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: textColor)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: textColor.withValues(alpha: 0.5),
                      onPressed: () => _dismissDialog(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildField(
                        context,
                        'Full Name *',
                        nameCtrl,
                        hint: 'e.g., Shivadatt Goswami',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                      ),
                      _buildField(
                        context,
                        'Phone Number * (10 Digits)',
                        phoneCtrl,
                        hint: 'e.g., 9876543210',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                      ),
                      _buildField(
                        context,
                        'Email Address',
                        emailCtrl,
                        hint: 'e.g., shivadatt@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                      ),
                      _buildField(
                        context,
                        'Street Address',
                        addrCtrl,
                        hint: 'e.g., 403 Grand Imperial Heights',
                        prefixIcon: Icon(Icons.home_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              context,
                              'City',
                              cityCtrl,
                              hint: 'e.g., Ahmedabad',
                              prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              context,
                              'State',
                              stateCtrl,
                              hint: 'e.g., Gujarat',
                              prefixIcon: Icon(Icons.map_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                            ),
                          ),
                        ],
                      ),
                      _buildField(
                        context,
                        'Map Location / GPS URL',
                        locCtrl,
                        hint: 'e.g., https://maps.google.com/...',
                        prefixIcon: Icon(Icons.pin_drop_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor, width: 1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isSaving ? null : () => _dismissDialog(context),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                      child: Text('CANCEL', style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.6))),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: isSaving ? null : _handleCreate,
                      child: isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Text('CREATE CLIENT', style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
  late final TextEditingController stateCtrl;
  late final TextEditingController locCtrl;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.customer.name);
    emailCtrl = TextEditingController(text: widget.customer.email);
    addrCtrl = TextEditingController(text: widget.customer.address);
    cityCtrl = TextEditingController(text: widget.customer.city);
    stateCtrl = TextEditingController(text: widget.customer.state);
    locCtrl = TextEditingController(text: widget.customer.mapLocation);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    addrCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    locCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Full Name cannot be empty.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final updated = CustomerModel(
      id: widget.customer.id,
      name: name,
      phone: widget.customer.phone,
      email: emailCtrl.text.trim(),
      address: addrCtrl.text.trim(),
      city: cityCtrl.text.trim(),
      state: stateCtrl.text.trim(),
      pincode: widget.customer.pincode,
      branch: widget.customer.branch,
      gender: widget.customer.gender,
      dateOfBirth: widget.customer.dateOfBirth,
      profileImageUrl: widget.customer.profileImageUrl,
      mapLocation: locCtrl.text.trim(),
      createdAt: widget.customer.createdAt,
      updatedAt: DateTime.now(),
    );

    setState(() => isSaving = true);
    try {
      _dismissDialog(context, true);
      final ok = await widget.controller.saveCustomer(updated);
      if (ok) {
        Get.snackbar(
          "Customer Saved",
          "Customer profile updated successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF132219),
          colorText: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget _buildField(
    BuildContext context,
    String label,
    TextEditingController ctrl, {
    String? hint,
    Widget? prefixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color inputFill = isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: 1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('EDIT CLIENT PROFILE', style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: textColor)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: textColor.withValues(alpha: 0.5),
                      onPressed: () => _dismissDialog(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildField(
                        context,
                        'Full Name *',
                        nameCtrl,
                        hint: 'e.g., Shivadatt Goswami',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                      ),
                      _buildField(
                        context,
                        'Email Address',
                        emailCtrl,
                        hint: 'e.g., shivadatt@gmail.com',
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                      ),
                      _buildField(
                        context,
                        'Street Address',
                        addrCtrl,
                        hint: 'e.g., 403 Grand Imperial Heights',
                        prefixIcon: Icon(Icons.home_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              context,
                              'City',
                              cityCtrl,
                              hint: 'e.g., Ahmedabad',
                              prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              context,
                              'State',
                              stateCtrl,
                              hint: 'e.g., Gujarat',
                              prefixIcon: Icon(Icons.map_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                            ),
                          ),
                        ],
                      ),
                      _buildField(
                        context,
                        'Map Location / GPS URL',
                        locCtrl,
                        hint: 'e.g., https://maps.google.com/...',
                        prefixIcon: Icon(Icons.pin_drop_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.6), size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor, width: 1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isSaving ? null : () => _dismissDialog(context),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                      child: Text('CANCEL', style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.6))),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: isSaving ? null : _handleSave,
                      child: isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Text('SAVE CHANGES', style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
