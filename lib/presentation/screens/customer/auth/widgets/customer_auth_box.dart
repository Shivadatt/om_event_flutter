import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/config/app_routes.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (authController.isAuthenticatedCustomer && widget.onSuccess == null) {
        _navigateToDestination();
      }
    });
  }

  void _navigateToDestination() {
    final rawRedirect = Get.parameters['redirect'];
    if (rawRedirect != null && rawRedirect.isNotEmpty) {
      final decoded = Uri.decodeComponent(rawRedirect);
      if (decoded.startsWith('/') &&
          !decoded.startsWith('/client-login') &&
          !decoded.startsWith('/admin')) {
        Get.offAllNamed(decoded);
        return;
      }
    }
    Get.offAllNamed(AppRoutes.customerDashboard);
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar(
        "Email Required",
        "Please enter your email address to receive a password reset link.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar(
        "Password Reset Sent",
        "Instructions to reset your password have been sent to $email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF132219),
        colorText: const Color(0xFFD4AF37),
        duration: const Duration(seconds: 5),
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Reset Request Note",
        e.message ?? "Could not send password reset email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Reset Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
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
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final viewInsetsBottom = media.viewInsets.bottom;

    final isDesktop = screenWidth >= 1200;
    final isLaptop = screenWidth >= 1024 && screenWidth < 1200;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isMobile = screenWidth < 600;
    final isNarrowMobile = screenWidth < 360;

    // ── 1. Responsive Modal Width ──────────────────────────────────────────
    final double modalWidth;
    if (isDesktop) {
      modalWidth = 430.0;
    } else if (isLaptop) {
      modalWidth = 400.0;
    } else if (isTablet) {
      modalWidth = (screenWidth * 0.88).clamp(320.0, 410.0);
    } else {
      final margin = isNarrowMobile ? 12.0 : 16.0;
      modalWidth = (screenWidth - (margin * 2)).clamp(280.0, 390.0);
    }

    // ── 2. Responsive Internal Padding ─────────────────────────────────────
    final EdgeInsets contentPadding;
    if (isDesktop) {
      contentPadding = const EdgeInsets.symmetric(horizontal: 36, vertical: 34);
    } else if (isLaptop) {
      contentPadding = const EdgeInsets.symmetric(horizontal: 32, vertical: 28);
    } else if (isTablet) {
      contentPadding = const EdgeInsets.symmetric(horizontal: 26, vertical: 24);
    } else if (isNarrowMobile) {
      contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
    } else {
      contentPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 22);
    }

    // ── 3. Responsive Typography & Dimensions ──────────────────────────────
    final double headerFontSize = isDesktop
        ? 28.0
        : (isLaptop
            ? 26.0
            : (isTablet ? 25.0 : (isNarrowMobile ? 22.0 : 24.0)));

    final double subtitleFontSize = isDesktop
        ? 13.0
        : (isLaptop ? 12.5 : (isNarrowMobile ? 11.5 : 12.0));

    final double headerToFieldsGap = isDesktop ? 28.0 : (isLaptop ? 24.0 : 18.0);
    final double fieldGap = isDesktop ? 16.0 : (isLaptop ? 14.0 : 12.0);
    final double fieldToButtonGap = isDesktop ? 22.0 : (isLaptop ? 18.0 : 16.0);
    final double dividerGap = isDesktop ? 22.0 : (isLaptop ? 18.0 : 16.0);
    final double buttonHeight = isDesktop ? 52.0 : (isLaptop ? 50.0 : (isNarrowMobile ? 46.0 : 48.0));
    final double fieldVerticalPad = isDesktop ? 16.0 : (isLaptop ? 14.0 : 12.0);

    // ── 4. Viewport Height & Keyboard Constraints ─────────────────────────
    final verticalSafetyMargin = isMobile ? 24.0 : 48.0;
    final double maxModalHeight = (screenHeight - viewInsetsBottom - verticalSafetyMargin)
        .clamp(220.0, screenHeight);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: modalWidth,
          maxHeight: maxModalHeight,
        ),
        child: Container(
          width: modalWidth,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF162D24), // Soft deep forest green
                Color(0xFF0B1713), // Rich ebonized dark green
              ],
            ),
            borderRadius: BorderRadius.circular(isNarrowMobile ? 18 : 24),
            border: Border.all(
              color: const Color(0xFFC9A77E).withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: isMobile ? 20 : 30,
                spreadRadius: isMobile ? 1 : 2,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: const Color(0xFFC9A77E).withValues(alpha: 0.04),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isNarrowMobile ? 18 : 24),
            child: SingleChildScrollView(
              padding: contentPadding,
              physics: const ClampingScrollPhysics(),
              child: Obx(() {
                final anyLoading = isEmailLoading || isGoogleLoading || authController.isLoading.value;

                return AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isLogin ? "Welcome Back" : "Create Account",
                        textAlign: TextAlign.center,
                        style: AppTheme.serifHeader(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFC9A77E),
                          letterSpacing: isNarrowMobile ? 0.8 : 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isLogin ? "Access your event dashboard" : "Register for your personal client studio",
                        textAlign: TextAlign.center,
                        style: AppTheme.sansBody(
                          fontSize: subtitleFontSize,
                          color: Colors.white70,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: headerToFieldsGap),

                      if (!isLogin) ...[
                        _buildTextField(
                          nameCtrl,
                          "Full Name",
                          Icons.person_outline,
                          fieldVerticalPad: fieldVerticalPad,
                        ),
                        SizedBox(height: fieldGap),
                      ],
                      _buildTextField(
                        emailCtrl,
                        "Email Address",
                        Icons.email_outlined,
                        fieldVerticalPad: fieldVerticalPad,
                      ),
                      SizedBox(height: fieldGap),
                      _buildTextField(
                        passCtrl,
                        "Password",
                        Icons.lock_outline,
                        obscureText: true,
                        fieldVerticalPad: fieldVerticalPad,
                      ),
                      if (isLogin) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: (isEmailLoading || isGoogleLoading || authController.isLoading.value)
                                ? null
                                : _handleForgotPassword,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFC9A77E),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Forgot Password?",
                              style: AppTheme.sansBody(
                                fontSize: isNarrowMobile ? 11 : 12,
                                color: const Color(0xFFC9A77E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: fieldToButtonGap),
                      _buildSubmitButton(
                        isLogin ? "Login" : "Register",
                        buttonHeight: buttonHeight,
                        onPressed: () async {
                          setState(() {
                            isEmailLoading = true;
                          });
                          try {
                            bool success = false;
                            if (isLogin) {
                              success = await authController.loginWithEmail(
                                emailCtrl.text,
                                passCtrl.text,
                                navigateHome: widget.onSuccess == null,
                              );
                            } else {
                              success = await authController.registerWithEmail(
                                nameCtrl.text,
                                emailCtrl.text,
                                passCtrl.text,
                                navigateHome: widget.onSuccess == null,
                              );
                            }
                            if (success) {
                              if (widget.onSuccess != null) {
                                widget.onSuccess!();
                              } else {
                                _navigateToDestination();
                              }
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                isEmailLoading = false;
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: anyLoading
                              ? null
                              : () {
                                  setState(() {
                                    isLogin = !isLogin;
                                  });
                                },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFC9A77E),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: AppTheme.sansBody(
                                fontSize: isNarrowMobile ? 12 : 13,
                                color: anyLoading ? Colors.white24 : Colors.white60,
                              ),
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
                      ),

                      SizedBox(height: dividerGap),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white24, height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                      SizedBox(height: dividerGap),

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
                            fontSize: isNarrowMobile ? 13 : 14,
                            color: anyLoading ? Colors.white30 : Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          minimumSize: Size(double.infinity, buttonHeight),
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
                                  await authController.loginWithGoogle(
                                    navigateHome: widget.onSuccess == null,
                                  );
                                  if (authController.isAuthenticatedCustomer && widget.onSuccess != null) {
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscureText = false,
    double fieldVerticalPad = 16.0,
  }) {
    final anyLoading = isEmailLoading || isGoogleLoading || authController.isLoading.value;
    return TextField(
      controller: ctrl,
      obscureText: obscureText,
      enabled: !anyLoading,
      style: TextStyle(
        color: anyLoading ? Colors.white30 : Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: anyLoading ? Colors.white12 : Colors.white38,
          fontSize: 13.5,
        ),
        prefixIcon: Icon(
          icon,
          color: anyLoading ? const Color(0x33C9A77E) : const Color(0xFFC9A77E),
          size: 19,
        ),
        filled: true,
        fillColor: Colors.black26,
        contentPadding: EdgeInsets.symmetric(
          vertical: fieldVerticalPad,
          horizontal: 16,
        ),
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

  Widget _buildSubmitButton(
    String text, {
    required double buttonHeight,
    required VoidCallback onPressed,
  }) {
    final showLoading = isEmailLoading || (authController.isLoading.value && !isGoogleLoading);
    final anyLoading = isEmailLoading || isGoogleLoading || authController.isLoading.value;

    return ElevatedButton(
      onPressed: anyLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC9A77E),
        foregroundColor: const Color(0xFF091210),
        minimumSize: Size(double.infinity, buttonHeight),
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
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: anyLoading ? const Color(0x55091210) : const Color(0xFF091210),
                letterSpacing: 0.5,
              ),
            ),
    );
  }
}
