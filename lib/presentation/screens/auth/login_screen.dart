import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_roles.dart';
import '../../controllers/auth_controller.dart';

/// Redesigned Admin / Team Studio Login Screen.
/// Matches the Option 1 Elegant Classic Style reference design:
/// - Centered split-screen luxury shell with thin champagne-gold border
/// - Left visual panel with high-res event photograph and brand typography
/// - Right panel with OE emblem, TEAM STUDIO eyebrow, Italiana typography,
///   gold-accented inputs with prefix icons, Remember Me, Forgot Password,
///   and gold gradient [ ENTER THE STUDIO → ] CTA button.
/// - Naturally responsive stacked layout on mobile with hero visual.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _rememberMe = true;

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _darkBg = Color(0xFF090E0C);
  static const Color _cardBg = Color(0xFF0C120F);
  static const Color _inputBg = Color(0xFF131916);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authController = Get.find<AuthController>();
      final role = authController.rxAdminRole.value?.roleType ?? authController.rxUserRole.value;
      final isStaffOrAdmin = authController.rxAdminRole.value != null ||
          role == AppRoles.superAdmin ||
          role == AppRoles.demoAdmin ||
          role == 'admin' ||
          role == 'manager';

      if (authController.rxIsLoggedIn.value && isStaffOrAdmin) {
        Get.offNamed(AppRoutes.adminDashboard);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog() {
    final resetEmailCtrl = TextEditingController(text: _emailController.text.trim());
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF141A16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _goldColor.withValues(alpha: 0.4), width: 1.2),
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
              cursorColor: _goldColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: _inputBg,
                hintText: "admin@omevents.com",
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                prefixIcon: const Icon(Icons.mail_outline_rounded, size: 16, color: _goldColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _goldColor.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _goldColor, width: 1.2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _goldColor,
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
            child: const Text("SEND LINK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 860;
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // ── Ambient Background Glow ─────────────────────────────
          Positioned(
            top: -120,
            left: -100,
            width: 450,
            height: 450,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1B3D2F).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            width: 500,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _goldColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),


          // ── Main Centered Login Shell ───────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: isDesktop
                    ? _buildDesktopLayout(authController)
                    : _buildMobileLayout(authController),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop / Tablet Landscape 2-Column Split Layout ───────────────
  Widget _buildDesktopLayout(AuthController authController) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 920,
        maxHeight: 535,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _goldColor.withValues(alpha: 0.35),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: _goldColor.withValues(alpha: 0.06),
              blurRadius: 30,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Left Visual Panel (~54%) ─────────────────────────
            Expanded(
              flex: 11,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      AppAssets.imageLuxuryEveningDecor,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    // Dark contrast gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.82),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBrandHeader(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Beautiful work\nbegins with a\nclear view.",
                                style: GoogleFonts.italiana(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  height: 1.25,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: 34,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: _goldColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Om Events · Celebration Studio Management",
                            style: GoogleFonts.dmSans(
                              fontSize: 9.5,
                              color: Colors.white60,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Right Login Form Panel (~46%) ─────────────────────
            Expanded(
              flex: 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                child: Container(
                  color: _cardBg,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildLoginForm(authController),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile Stacked Layout with Compact Hero ────────────────────────
  Widget _buildMobileLayout(AuthController authController) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _goldColor.withValues(alpha: 0.35),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Mobile Hero Visual ──────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 135,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      AppAssets.imageLuxuryEveningDecor,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.black.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBrandHeader(isCompact: true),
                          Text(
                            "Beautiful work begins with a clear view.",
                            style: GoogleFonts.italiana(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Mobile Form Area ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: _buildLoginForm(authController),
            ),
          ],
        ),
      ),
    );
  }

  // ── Brand Logo Header (Circle Emblem + Text) ───────────────────────
  Widget _buildBrandHeader({bool isCompact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCompact ? 34 : 36,
          height: isCompact ? 34 : 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _goldColor, width: 1.2),
            color: Colors.black.withValues(alpha: 0.3),
            boxShadow: [
              BoxShadow(
                color: _goldColor.withValues(alpha: 0.18),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              "OE",
              style: GoogleFonts.italiana(
                fontSize: isCompact ? 16 : 18,
                color: _goldColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "OM EVENTS\nAND DECORATORS",
          style: GoogleFonts.dmSans(
            fontSize: isCompact ? 7.0 : 7.5,
            fontWeight: FontWeight.w700,
            color: _goldColor,
            letterSpacing: 1.4,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // ── Right Form Component ──────────────────────────────────────────
  Widget _buildLoginForm(AuthController authController) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Centered Top Brand Badge on the form panel
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _goldColor, width: 1.2),
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                  child: Center(
                    child: Text(
                      "OE",
                      style: GoogleFonts.italiana(
                        fontSize: 19,
                        color: _goldColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "OM EVENTS\nAND DECORATORS",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 7.2,
                    fontWeight: FontWeight.w700,
                    color: _goldColor,
                    letterSpacing: 1.3,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Eyebrow & Title
          Text(
            "TEAM STUDIO",
            style: GoogleFonts.dmSans(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: _goldColor,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            "Welcome back.",
            style: GoogleFonts.italiana(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 16),

          // Email Input Field
          Text(
            "EMAIL ADDRESS",
            style: GoogleFonts.dmSans(
              fontSize: 8.2,
              fontWeight: FontWeight.w700,
              color: _goldColor,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12),
            cursorColor: _goldColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: _inputBg,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
              prefixIcon: const Icon(Icons.mail_outline_rounded, size: 16, color: _goldColor),
              hintText: "Enter Your Email",
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 11.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: _goldColor.withValues(alpha: 0.28)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: _goldColor.withValues(alpha: 0.28)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _goldColor, width: 1.1),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return "Email is required.";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Password Input Field
          Text(
            "PASSWORD",
            style: GoogleFonts.dmSans(
              fontSize: 8.2,
              fontWeight: FontWeight.w700,
              color: _goldColor,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12),
            cursorColor: _goldColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: _inputBg,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 16, color: _goldColor),
              suffixIcon: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 16,
                  color: Colors.white54,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              hintText: "••••••••",
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 11.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: _goldColor.withValues(alpha: 0.28)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: _goldColor.withValues(alpha: 0.28)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _goldColor, width: 1.1),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Password is required.";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Options Row: Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: _goldColor,
                      checkColor: const Color(0xFF09120E),
                      side: BorderSide(color: _goldColor.withValues(alpha: 0.5), width: 1.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.5)),
                      onChanged: (val) => setState(() => _rememberMe = val ?? true),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    "Remember me",
                    style: GoogleFonts.dmSans(fontSize: 10.5, color: Colors.white70),
                  ),
                ],
              ),
              InkWell(
                onTap: _showForgotPasswordDialog,
                child: Text(
                  "Forgot password?",
                  style: GoogleFonts.dmSans(
                    fontSize: 10.5,
                    color: _goldColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gold Gradient CTA Button: [ ENTER THE STUDIO → ]
          Obx(() {
            final isLoading = authController.isLoading.value;
            return InkWell(
              onTap: isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() == true) {
                        await authController.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                    },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                height: 40,
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
                      color: _goldColor.withValues(alpha: 0.22),
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
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF09120E),
                                letterSpacing: 1.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Color(0xFF09120E),
                            ),
                          ],
                        ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),

          // Bottom Tagline
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
