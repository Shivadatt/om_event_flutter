import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_auth_controller.dart';

/// Reusable, premium Authentication Card containing Email sign-in forms and Google authentication.
class CustomerAuthBox extends StatefulWidget {
  final VoidCallback? onSuccess;

  const CustomerAuthBox({
    super.key,
    this.onSuccess,
  });

  @override
  State<CustomerAuthBox> createState() => _CustomerAuthBoxState();
}

class _CustomerAuthBoxState extends State<CustomerAuthBox> {
  final CustomerAuthController authController = Get.find<CustomerAuthController>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();

  bool isLogin = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(201, 167, 126, 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLogin ? "Welcome Back" : "Create Account",
              style: AppTheme.serifHeader(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              "Access your event dashboard",
              style: AppTheme.sansBody(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 32),

            if (!isLogin) ...[
              _buildTextField(nameCtrl, "Full Name", Icons.person),
              const SizedBox(height: 16),
            ],
            _buildTextField(emailCtrl, "Email Address", Icons.email),
            const SizedBox(height: 16),
            _buildTextField(passCtrl, "Password", Icons.lock, obscureText: true),
            const SizedBox(height: 24),
            _buildSubmitButton(isLogin ? "Login" : "Register", () async {
              bool success = false;
              if (isLogin) {
                success = await authController.loginWithEmail(emailCtrl.text, passCtrl.text);
              } else {
                success = await authController.registerWithEmail(nameCtrl.text, emailCtrl.text, passCtrl.text);
              }
              if (success && widget.onSuccess != null) {
                widget.onSuccess!();
              }
            }),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(
                isLogin ? "Don't have an account? Register" : "Already have an account? Login",
                style: AppTheme.sansBody(fontSize: 13, color: const Color(0xFFC9A77E)),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider(color: Colors.white24)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("OR", style: AppTheme.sansBody(fontSize: 12, color: Colors.white54)),
                ),
                const Expanded(child: Divider(color: Colors.white24)),
              ],
            ),
            const SizedBox(height: 24),

            OutlinedButton.icon(
              icon: const Icon(Icons.g_mobiledata, color: Colors.white),
              label: Text(
                "Continue with Google",
                style: AppTheme.sansBody(fontSize: 14, color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await authController.loginWithGoogle();
                if (authController.rxIsLoggedIn.value && widget.onSuccess != null) {
                  widget.onSuccess!();
                }
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFFC9A77E), size: 20),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC9A77E)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: authController.isLoading.value ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC9A77E),
        foregroundColor: const Color(0xFF091210),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: authController.isLoading.value
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF091210)),
            )
          : Text(
              text,
              style: AppTheme.sansBody(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF091210)),
            ),
    );
  }
}
