import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_constants.dart';

/// Modal dialog for requesting a password reset link.
class LoginForgotPasswordDialog {
  LoginForgotPasswordDialog._();

  static void show(BuildContext context, {String initialEmail = ''}) {
    final resetEmailCtrl = TextEditingController(text: initialEmail);
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF141A16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: LoginConstants.goldColor.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        title: Text(
          "RESET PASSWORD",
          style: GoogleFonts.italiana(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your registered administrator email to receive a password reset link.",
              style: GoogleFonts.dmSans(fontSize: 12.5, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              cursorColor: LoginConstants.goldColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: LoginConstants.inputBg,
                hintText: "admin@omevents.com",
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                prefixIcon: const Icon(
                  Icons.mail_outline_rounded,
                  size: 16,
                  color: LoginConstants.goldColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: LoginConstants.goldColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: LoginConstants.goldColor,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "CANCEL",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LoginConstants.goldColor,
              foregroundColor: const Color(0xFF09120E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final email = resetEmailCtrl.text.trim();
              if (email.isEmpty) {
                Get.snackbar("Error", "Please enter an email address.");
                return;
              }
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                Get.back();
                Get.snackbar("Success", "Password reset instructions sent to $email");
              } catch (e) {
                Get.snackbar("Error", e.toString());
              }
            },
            child: const Text(
              "SEND LINK",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
