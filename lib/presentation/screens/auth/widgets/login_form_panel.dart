import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import 'login_brand_header.dart';
import 'login_constants.dart';

/// Form inputs, options, and submission button for the Admin Login screen.
class LoginFormPanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final VoidCallback onTogglePasswordVisibility;
  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onForgotPassword;
  final VoidCallback onLoginPressed;
  final AuthController authController;
  final bool showTopBrandBadge;
  final bool isCompact;

  const LoginFormPanel({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.onTogglePasswordVisibility,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
    required this.onLoginPressed,
    required this.authController,
    required this.showTopBrandBadge,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTopBrandBadge) ...[
            Center(child: LoginFormBrandBadge(isCompact: isCompact)),
            SizedBox(height: isCompact ? 10 : 14),
          ],
          Text(
            "TEAM STUDIO",
            style: GoogleFonts.dmSans(
              fontSize: isCompact ? 8.0 : 8.5,
              fontWeight: FontWeight.bold,
              color: LoginConstants.goldColor,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            "Welcome back.",
            style: GoogleFonts.italiana(
              fontSize: isCompact ? 22 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Text(
            "EMAIL ADDRESS",
            style: GoogleFonts.dmSans(
              fontSize: isCompact ? 7.8 : 8.2,
              fontWeight: FontWeight.w700,
              color: LoginConstants.goldColor,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12),
            cursorColor: LoginConstants.goldColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: LoginConstants.inputBg,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: isCompact ? 8.5 : 9.5,
              ),
              prefixIcon: const Icon(
                Icons.mail_outline_rounded,
                size: 16,
                color: LoginConstants.goldColor,
              ),
              hintText: "Enter Your Email",
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 11.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: LoginConstants.goldColor.withValues(alpha: 0.28),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: LoginConstants.goldColor.withValues(alpha: 0.28),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: LoginConstants.goldColor,
                  width: 1.1,
                ),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return "Email is required.";
              }
              return null;
            },
          ),
          SizedBox(height: isCompact ? 8 : 10),
          Text(
            "PASSWORD",
            style: GoogleFonts.dmSans(
              fontSize: isCompact ? 7.8 : 8.2,
              fontWeight: FontWeight.w700,
              color: LoginConstants.goldColor,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: passwordController,
            obscureText: !isPasswordVisible,
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12),
            cursorColor: LoginConstants.goldColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: LoginConstants.inputBg,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: isCompact ? 8.5 : 9.5,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: LoginConstants.goldColor,
              ),
              suffixIcon: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 16,
                  color: Colors.white54,
                ),
                onPressed: onTogglePasswordVisibility,
              ),
              hintText: "••••••••",
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 11.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: LoginConstants.goldColor.withValues(alpha: 0.28),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                  color: LoginConstants.goldColor.withValues(alpha: 0.28),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: LoginConstants.goldColor,
                  width: 1.1,
                ),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Password is required.";
              }
              return null;
            },
          ),
          SizedBox(height: isCompact ? 7 : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: Checkbox(
                        value: rememberMe,
                        activeColor: LoginConstants.goldColor,
                        checkColor: const Color(0xFF09120E),
                        side: BorderSide(
                          color: LoginConstants.goldColor.withValues(alpha: 0.5),
                          width: 1.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.5),
                        ),
                        onChanged: onRememberMeChanged,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        "Remember me",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: isCompact ? 9.5 : 10.5,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onForgotPassword,
                child: Text(
                  "Forgot password?",
                  style: GoogleFonts.dmSans(
                    fontSize: isCompact ? 9.5 : 10.5,
                    color: LoginConstants.goldColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Obx(() {
            final isLoading = authController.isLoading.value;
            return InkWell(
              onTap: isLoading ? null : onLoginPressed,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                height: isCompact ? 38 : 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLoading
                        ? [Colors.grey.shade700, Colors.grey.shade800]
                        : const [
                            Color(0xFFE2B755),
                            Color(0xFFD4AF37),
                            Color(0xFFBF962E),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: LoginConstants.goldColor.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF09120E),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "ENTER THE STUDIO",
                              style: GoogleFonts.dmSans(
                                fontSize: isCompact ? 10.5 : 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF09120E),
                                letterSpacing: 1.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "→",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF09120E),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          }),
          SizedBox(height: isCompact ? 10 : 12),
          Center(
            child: Text(
              "Om Events · Celebration Studio Management",
              style: GoogleFonts.dmSans(
                fontSize: 8.5,
                color: Colors.white38,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
