import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/customer_auth_provisioning_service.dart';

/// Confirmation dialog displayed immediately after customer creation.
void showCustomerCreatedSuccessDialog(
  BuildContext context, {
  required String name,
  required String phone,
  required String email,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final isLoginReady = email.isNotEmpty;

  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1713) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.35), width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryAccent.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryAccent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customer Created Successfully",
                        style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                      Text(name, style: AppTheme.sansBody(fontSize: 12, color: AppColors.primaryAccent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16211B) : const Color(0xFFF7F5F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF26372E) : const Color(0xFFE5DFD5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "CLIENT PORTAL LOGIN",
                        style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryAccent, letterSpacing: 1.0),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isLoginReady ? Colors.green.withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isLoginReady ? "Ready for Invite" : "Email Required",
                          style: AppTheme.sansBody(fontSize: 9, fontWeight: FontWeight.bold, color: isLoginReady ? Colors.green : Colors.amber.shade800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email.isNotEmpty
                        ? "Account ready for $email. Customer sets their password via secure email link."
                        : "No email address provided. Client Portal login requires an email.",
                    style: AppTheme.sansBody(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isLoginReady) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text("Send Portal Invite"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      Get.back();
                      final inviteRes = await CustomerAuthProvisioningService.sendPortalInvite(phone: phone, email: email, name: name);
                      Get.snackbar(
                        inviteRes.success ? "Invitation Dispatched" : "Dispatch Note",
                        inviteRes.message,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: inviteRes.success ? const Color(0xFF132219) : Colors.red.shade900,
                        colorText: inviteRes.success ? const Color(0xFFD4AF37) : Colors.white,
                        duration: const Duration(seconds: 5),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                ],
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Done", style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
