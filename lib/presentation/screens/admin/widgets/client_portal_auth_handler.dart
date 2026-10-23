import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/customer_auth_provisioning_service.dart';
import '../../../../data/models/customer_model.dart';
import '../../../controllers/admin_controller.dart';

class ClientPortalAuthHandler {
  static Future<void> sendPortalInvite({
    required BuildContext context,
    required CustomerModel customer,
    required ValueChanged<bool> onLoading,
    required VoidCallback onSuccess,
  }) async {
    if (customer.email.isEmpty) {
      Get.snackbar(
        "Email Required",
        "A valid email address is required to send client portal invitations.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    onLoading(true);
    try {
      final res = await CustomerAuthProvisioningService.sendPortalInvite(
        phone: customer.phone,
        email: customer.email,
        name: customer.name,
      );
      if (res.success) {
        onSuccess();
        Get.snackbar(
          "Invitation Dispatched",
          res.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF132219),
          colorText: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          "Could Not Send Invitation",
          res.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } finally {
      onLoading(false);
    }
  }

  static Future<void> confirmAndToggleLogin({
    required BuildContext context,
    required CustomerModel customer,
    required bool enable,
    required AdminController controller,
    required ValueChanged<bool> onLoading,
    required ValueChanged<bool> onStatusChanged,
  }) async {
    if (!enable) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF132219),
          title: const Text(
            "Disable Portal Login?",
            style: TextStyle(color: Color(0xFFD4AF37)),
          ),
          content: Text(
            "Are you sure you want to disable client portal access for ${customer.name}?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel", style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Disable", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    onLoading(true);
    try {
      final ok = await CustomerAuthProvisioningService.toggleCustomerLogin(
        phone: customer.phone,
        enable: enable,
      );
      if (!ok) {
        Get.snackbar(
          "Update Failed",
          "Could not update client login status.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return;
      }

      onStatusChanged(enable);
      await controller.loadCustomers();

      Get.snackbar(
        "Client Portal Status",
        enable ? "Client login has been enabled." : "Client login has been disabled.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF132219),
        colorText: const Color(0xFFD4AF37),
      );
    } finally {
      onLoading(false);
    }
  }
}
