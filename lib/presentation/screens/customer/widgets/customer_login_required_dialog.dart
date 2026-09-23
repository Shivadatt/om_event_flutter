import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../auth/widgets/customer_auth_box.dart';

/// Centralized Luxury Dialog enforcing Customer Login before booking or quotation creation.
void showCustomerLoginRequiredDialog(
  BuildContext context, {
  String? subtitle,
  VoidCallback? onLoginSuccess,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (dialogCtx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1915),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFC9A77E).withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.75),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A77E).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFFC9A77E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Login Required",
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFC9A77E),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle ?? "Please login to continue with your booking.",
                          style: AppTheme.sansBody(
                            fontSize: 12.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                    tooltip: "Close",
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E3A32), height: 28),
            // Embed existing CustomerAuthBox
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: CustomerAuthBox(
                  onSuccess: () {
                    Navigator.of(dialogCtx).pop();
                    if (onLoginSuccess != null) {
                      onLoginSuccess();
                    } else {
                      Get.snackbar(
                        "Welcome Back",
                        "You are now logged in. Please click Book to continue.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF12271F),
                        colorText: const Color(0xFFC9A77E),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 4),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
