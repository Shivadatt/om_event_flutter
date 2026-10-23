import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/utils/auth_route_helper.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/login_constants.dart';
import 'widgets/login_forgot_password_dialog.dart';
import 'widgets/login_form_panel.dart';
import 'widgets/login_responsive_shell.dart';

/// Admin / Team Studio Login Screen with responsive luxury shell.
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        if (AuthRouteHelper.isCurrentAdminOrStaff()) {
          Get.offNamed(AppRoutes.adminDashboard);
        } else if (AuthRouteHelper.isVerifiedCustomer()) {
          Get.offNamed(AppRoutes.customerDashboard);
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin(AuthController auth) async {
    if (_formKey.currentState?.validate() == true) {
      await auth.login(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final role = auth.rxAdminRole.value?.roleType ?? auth.rxUserRole.value;
    final isStaffOrAdmin = auth.rxAdminRole.value != null ||
        role == AppRoles.superAdmin ||
        role == AppRoles.demoAdmin ||
        role == 'admin' ||
        role == 'manager';

    if (auth.rxIsLoggedIn.value && isStaffOrAdmin) {
      return const Scaffold(
        backgroundColor: LoginConstants.darkBg,
        body: SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: LoginConstants.darkBg,
      body: Stack(
        children: [
          const LoginAmbientGlow(
            top: -120,
            left: -100,
            color: Color(0xFF1B3D2F),
            opacity: 0.25,
            size: 450,
          ),
          const LoginAmbientGlow(
            bottom: -150,
            right: -100,
            color: LoginConstants.goldColor,
            opacity: 0.08,
            size: 500,
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final tier = LoginDeviceTier.fromWidth(width);
                final isMobile = tier == LoginDeviceTier.mobile;

                return Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: 20,
                    ),
                    child: isMobile
                        ? LoginMobileShell(
                            width: width,
                            height: height,
                            formWidget: _buildForm(auth, showBadge: false, isCompact: true),
                          )
                        : LoginTwoColumnShell(
                            tier: tier,
                            width: width,
                            height: height,
                            formWidget: _buildForm(
                              auth,
                              showBadge: true,
                              isCompact: tier == LoginDeviceTier.tablet || tier == LoginDeviceTier.laptop,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
    AuthController auth, {
    required bool showBadge,
    required bool isCompact,
  }) {
    return LoginFormPanel(
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      isPasswordVisible: _isPasswordVisible,
      onTogglePasswordVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
      rememberMe: _rememberMe,
      onRememberMeChanged: (val) => setState(() => _rememberMe = val ?? true),
      onForgotPassword: () => LoginForgotPasswordDialog.show(
        context,
        initialEmail: _emailController.text.trim(),
      ),
      onLoginPressed: () => _onLogin(auth),
      authController: auth,
      showTopBrandBadge: showBadge,
      isCompact: isCompact,
    );
  }
}
