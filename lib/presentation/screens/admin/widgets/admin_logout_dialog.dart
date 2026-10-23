import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../controllers/auth_controller.dart';

/// Shows an administrative logout confirmation dialog with dark/gold styling.
void showAdminLogoutDialog(BuildContext context, AuthController authController) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  Get.dialog(
    AlertDialog(
      backgroundColor: isDark ? const Color(0xFF141A18) : const Color(0xFFFBF9F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFC9A77E).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      title: Text(
        "LOG OUT",
        style: AppTheme.serifHeader(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
          letterSpacing: 1.5,
        ),
      ),
      content: Text(
        "Are you sure you want to log out of OM Events CMS?",
        style: AppTheme.sansBody(
          fontSize: 14,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            "CANCEL",
            style: AppTheme.sansBody(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC9A77E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () async {
            Get.back();
            await authController.logout();
          },
          child: Text(
            "CONFIRM",
            style: AppTheme.sansBody(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF091210),
            ),
          ),
        ),
      ],
    ),
  );
}
