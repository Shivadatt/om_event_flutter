import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/services/customer_auth_provisioning_service.dart';
import '../../../../core/utils/auth_route_helper.dart';

enum _InviteStep {
  loading,
  adminDetected,
  invalidLink,
  enterEmail,
  setupPassword,
  success,
  error,
}

/// Dedicated page handling Firebase Email-Link verification, canonical customer linking,
/// and self-service password setup without requiring Cloud Functions or Supabase Auth.
class CustomerCompleteInviteScreen extends StatefulWidget {
  const CustomerCompleteInviteScreen({super.key});

  @override
  State<CustomerCompleteInviteScreen> createState() => _CustomerCompleteInviteScreenState();
}

class _CustomerCompleteInviteScreenState extends State<CustomerCompleteInviteScreen> {
  _InviteStep _step = _InviteStep.loading;
  String _statusMessage = 'Verifying invitation link...';
  String _errorMessage = '';
  String _verifiedEmail = '';
  String _customerPhone = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFlow();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _initializeFlow() async {
    // 1. Guard against admin session mixing (Phase 11)
    if (AuthRouteHelper.isCurrentAdminOrStaff()) {
      setState(() {
        _step = _InviteStep.adminDetected;
      });
      return;
    }

    final currentUrl = Uri.base.toString();
    debugPrint('[CLIENT_INVITE][URL_DETECT] Checking incoming URL: $currentUrl');

    final isEmailLink = FirebaseAuth.instance.isSignInWithEmailLink(currentUrl);

    if (!isEmailLink) {
      debugPrint('[CLIENT_INVITE][URL_DETECT] Current URL is not a valid email sign-in link');
      setState(() {
        _step = _InviteStep.invalidLink;
        _errorMessage = 'This page was opened without a valid invitation link. Please check your email and click the link sent to you.';
      });
      return;
    }

    // 2. Try to recover email from local device storage (Phase 5)
    final storedEmail = await CustomerAuthProvisioningService.getPendingInviteEmail();
    if (storedEmail != null && storedEmail.isNotEmpty) {
      _emailController.text = storedEmail;
      _executeLinkVerification(storedEmail, currentUrl);
    } else {
      // If customer opened link on another device or browser, prompt for email
      setState(() {
        _step = _InviteStep.enterEmail;
      });
    }
  }

  Future<void> _executeLinkVerification(String email, String link) async {
    setState(() {
      _step = _InviteStep.loading;
      _statusMessage = 'Verifying your email and activating client portal...';
    });

    final res = await CustomerAuthProvisioningService.completeInviteAndLinkCustomer(
      email: email,
      emailLink: link,
    );

    if (res.success) {
      setState(() {
        _verifiedEmail = res.email;
        _customerPhone = res.phone;
        _step = _InviteStep.setupPassword;
      });
    } else {
      setState(() {
        _step = _InviteStep.error;
        _errorMessage = res.message;
      });
    }
  }

  Future<void> _handleSetPassword() async {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password.length < 6) {
      Get.snackbar(
        'Weak Password',
        'Password must be at least 6 characters long.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    if (password != confirm) {
      Get.snackbar(
        'Passwords Do Not Match',
        'Please verify that both password fields match.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await CustomerAuthProvisioningService.setCustomerPassword(password);

      // Sign out customer so they can sign in cleanly with their new credentials (Phase 8)
      await FirebaseAuth.instance.signOut();

      setState(() {
        _step = _InviteStep.success;
      });

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Get.offAllNamed(AppRoutes.customerLogin);
      }
    } catch (e) {
      Get.snackbar(
        'Setup Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091210),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF162D24),
                  Color(0xFF0B1713),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFC9A77E).withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case _InviteStep.loading:
        return _buildLoadingState();
      case _InviteStep.adminDetected:
        return _buildAdminDetectedState();
      case _InviteStep.invalidLink:
      case _InviteStep.error:
        return _buildErrorState();
      case _InviteStep.enterEmail:
        return _buildEnterEmailState();
      case _InviteStep.setupPassword:
        return _buildPasswordSetupState();
      case _InviteStep.success:
        return _buildSuccessState();
    }
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC9A77E)),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: AppTheme.sansBody(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildAdminDetectedState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber.withValues(alpha: 0.15),
          ),
          child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.amber, size: 32),
        ),
        const SizedBox(height: 18),
        Text(
          "Admin Session Active",
          style: AppTheme.serifHeader(fontSize: 22, color: const Color(0xFFC9A77E)),
        ),
        const SizedBox(height: 12),
        Text(
          "You are currently signed into an administrator account (${FirebaseAuth.instance.currentUser?.email}).\n\nTo activate this customer portal account, please open the link in a private/incognito window, or sign out of Admin Studio.",
          textAlign: TextAlign.center,
          style: AppTheme.sansBody(fontSize: 13, color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC9A77E),
            foregroundColor: const Color(0xFF091210),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Get.offAllNamed(AppRoutes.adminDashboard),
          child: const Text("Go to Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white24),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            _initializeFlow();
          },
          child: const Text("Sign Out Admin & Continue"),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.15),
          ),
          child: const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 32),
        ),
        const SizedBox(height: 18),
        Text(
          "Invitation Notice",
          style: AppTheme.serifHeader(fontSize: 22, color: const Color(0xFFC9A77E)),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage.isNotEmpty ? _errorMessage : "Unable to complete invitation verification.",
          textAlign: TextAlign.center,
          style: AppTheme.sansBody(fontSize: 13, color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC9A77E),
            foregroundColor: const Color(0xFF091210),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Get.offAllNamed(AppRoutes.customerLogin),
          child: const Text("Go to Client Portal Login", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildEnterEmailState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Welcome to OM Events",
          style: AppTheme.serifHeader(fontSize: 24, color: const Color(0xFFC9A77E)),
        ),
        const SizedBox(height: 8),
        Text(
          "Please confirm your email address to complete client portal activation.",
          textAlign: TextAlign.center,
          style: AppTheme.sansBody(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter your email address",
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFC9A77E)),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC9A77E)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC9A77E),
            foregroundColor: const Color(0xFF091210),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final email = _emailController.text.trim();
            if (email.isEmpty || !email.contains('@')) {
              Get.snackbar('Invalid Email', 'Please enter a valid email address.');
              return;
            }
            _executeLinkVerification(email, Uri.base.toString());
          },
          child: const Text("Verify Invitation", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPasswordSetupState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            "Welcome to OM Events",
            style: AppTheme.serifHeader(fontSize: 24, color: const Color(0xFFC9A77E)),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            _verifiedEmail.isNotEmpty ? "Verified: $_verifiedEmail" : "Your email has been verified.",
            style: AppTheme.sansBody(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
        if (_customerPhone.isNotEmpty) ...[
          const SizedBox(height: 2),
          Center(
            child: Text(
              "Account: +91 $_customerPhone",
              style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
            ),
          ),
        ],
        const SizedBox(height: 4),
        Center(
          child: Text(
            "Create your Client Portal password to complete registration.",
            textAlign: TextAlign.center,
            style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "New Password (min. 6 characters)",
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFC9A77E)),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC9A77E)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Confirm Password",
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFC9A77E)),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC9A77E)),
            ),
          ),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC9A77E),
            foregroundColor: const Color(0xFF091210),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isSubmitting ? null : _handleSetPassword,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF091210)),
                )
              : const Text("Set Password & Complete Setup", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withValues(alpha: 0.15),
          ),
          child: const Icon(Icons.celebration_rounded, color: Colors.green, size: 32),
        ),
        const SizedBox(height: 18),
        Text(
          "Setup Complete!",
          style: AppTheme.serifHeader(fontSize: 24, color: const Color(0xFFC9A77E)),
        ),
        const SizedBox(height: 10),
        Text(
          "Your password has been created successfully.\nRedirecting to Client Portal Login...",
          textAlign: TextAlign.center,
          style: AppTheme.sansBody(fontSize: 13, color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC9A77E),
            foregroundColor: const Color(0xFF091210),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Get.offAllNamed(AppRoutes.customerLogin),
          child: const Text("Go to Client Login Now", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
