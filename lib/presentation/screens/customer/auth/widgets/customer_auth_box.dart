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
  bool isEmailLoading = false;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.png',
        width: 14,
        height: 14,
        errorBuilder: (context, error, stackTrace) {
          return const Text(
            "G",
            style: TextStyle(
              color: Color(0xFF4285F4),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'sans-serif',
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF162D24), // Soft deep forest green
            Color(0xFF0B1713), // Rich ebonized dark green
          ],
        ),
        borderRadius: BorderRadius.circular(24), // 24px luxury rounded borders
        border: Border.all(
          color: const Color(0xFFC9A77E).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: const Color(0xFFC9A77E).withValues(alpha: 0.04),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() {
        final anyLoading = isEmailLoading || isGoogleLoading || authController.isLoading.value;

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLogin ? "Welcome Back" : "Create Account",
                style: AppTheme.serifHeader(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFC9A77E),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isLogin ? "Access your event dashboard" : "Register for your personal client studio",
                style: AppTheme.sansBody(
                  fontSize: 13,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),

              if (!isLogin) ...[
                _buildTextField(nameCtrl, "Full Name", Icons.person_outline),
                const SizedBox(height: 16),
              ],
              _buildTextField(emailCtrl, "Email Address", Icons.email_outlined),
              const SizedBox(height: 16),
              _buildTextField(passCtrl, "Password", Icons.lock_outline, obscureText: true),
              const SizedBox(height: 28),
              _buildSubmitButton(isLogin ? "Login" : "Register", () async {
                setState(() {
                  isEmailLoading = true;
                });
                try {
                  bool success = false;
                  if (isLogin) {
                    success = await authController.loginWithEmail(emailCtrl.text, passCtrl.text);
                  } else {
                    success = await authController.registerWithEmail(nameCtrl.text, emailCtrl.text, passCtrl.text);
                  }
                  if (success && widget.onSuccess != null) {
                    widget.onSuccess!();
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      isEmailLoading = false;
                    });
                  }
                }
              }),
              const SizedBox(height: 16),
              TextButton(
                onPressed: anyLoading
                    ? null
                    : () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFC9A77E),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.sansBody(fontSize: 13, color: anyLoading ? Colors.white24 : Colors.white60),
                    children: [
                      TextSpan(text: isLogin ? "Don't have an account? " : "Already have an account? "),
                      TextSpan(
                        text: isLogin ? "Register" : "Login",
                        style: TextStyle(
                          color: anyLoading ? const Color(0x33C9A77E) : const Color(0xFFC9A77E),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.white24, height: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "OR",
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        color: Colors.white38,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.white24, height: 1)),
                ],
              ),
              const SizedBox(height: 24),

              OutlinedButton.icon(
                icon: isGoogleLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : _buildGoogleIcon(),
                label: Text(
                  isGoogleLoading ? "Connecting..." : "Continue with Google",
                  style: AppTheme.sansBody(
                    fontSize: 14,
                    color: anyLoading ? Colors.white30 : Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(
                    color: anyLoading
                        ? const Color(0x22C9A77E)
                        : const Color(0xFFC9A77E).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.white.withValues(alpha: 0.03),
                ),
                onPressed: anyLoading
                    ? null
                    : () async {
                        setState(() {
                          isGoogleLoading = true;
                        });
                        try {
                          await authController.loginWithGoogle();
                          if (authController.rxIsLoggedIn.value && widget.onSuccess != null) {
                            widget.onSuccess!();
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              isGoogleLoading = false;
                            });
                          }
                        }
                      },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool obscureText = false}) {
    final anyLoading = isEmailLoading || isGoogleLoading || authController.isLoading.value;
    return TextField(
      controller: ctrl,
      obscureText: obscureText,
      enabled: !anyLoading,
      style: TextStyle(color: anyLoading ? Colors.white30 : Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: anyLoading ? Colors.white12 : Colors.white38, fontSize: 14),
        prefixIcon: Icon(icon, color: anyLoading ? const Color(0x33C9A77E) : const Color(0xFFC9A77E), size: 20),
        filled: true,
        fillColor: Colors.black26,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC9A77E), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String text, VoidCallback onPressed) {
    final showLoading = isEmailLoading || (authController.isLoading.value && !isGoogleLoading);
    final anyLoading = isEmailLoading || isGoogleLoading || authController.isLoading.value;

    return ElevatedButton(
      onPressed: anyLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC9A77E),
        foregroundColor: const Color(0xFF091210),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: showLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF091210)),
              ),
            )
          : Text(
              text,
              style: AppTheme.sansBody(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: anyLoading ? const Color(0x55091210) : const Color(0xFF091210),
                letterSpacing: 0.5,
              ),
            ),
    );
  }
}
