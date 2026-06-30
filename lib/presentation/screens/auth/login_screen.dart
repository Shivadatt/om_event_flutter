import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;

    final loginForm = Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? AppTheme.darkGold : AppTheme.lightGold, width: 1),
              ),
              child: Center(
                child: Text(
                  "OE",
                  style: AppTheme.serifHeader(fontSize: 16, color: isDark ? AppTheme.darkInk : AppTheme.lightInk),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "TEAM STUDIO",
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Welcome back.",
            style: AppTheme.serifHeader(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          CustomInput(
            label: "Email Address",
            placeholder: "Enter Your Email",
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return "Email is required.";
              return null;
            },
          ),
          CustomInput(
            label: "Password",
            placeholder: "••••••••",
            controller: _passwordController,
            obscureText: true,
            validator: (val) {
              if (val == null || val.isEmpty) return "Password is required.";
              return null;
            },
          ),
          const SizedBox(height: 12),
          Obx(() => CustomButton(
                text: "Enter the studio",
                isLoading: authController.isLoading.value,
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    await authController.login(
                      _emailController.text,
                      _passwordController.text,
                    );
                  }
                },
              )),
          const SizedBox(height: 24),
          Center(
            child: Text(
              "Seed: omeventsanddecorators@gmail.com / Admin@gmail.com",
              style: AppTheme.sansBody(
                fontSize: 11,
                color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF141A18) : const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: isDesktop
              ? Container(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  height: 600,
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? AppTheme.darkLine : AppTheme.lightLine),
                  ),
                  child: Row(
                    children: [
                      // Left Column: Art Pane (login-art)
                      Expanded(
                        flex: 11,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [const Color(0xFF0F1815), const Color(0xFF1E2E2A)]
                                  : [const Color(0xFF1D2A26), const Color(0xFF2F413B)],
                            ),
                          ),
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "OE",
                                style: AppTheme.serifHeader(fontSize: 24, color: isDark ? AppTheme.darkGold : AppTheme.lightGold),
                              ),
                              Text(
                                "Beautiful work begins with a clear view.",
                                style: AppTheme.serifHeader(
                                  fontSize: 36,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                "Om Events · Celebration Studio Management",
                                style: AppTheme.sansBody(
                                  fontSize: 11,
                                  color: Colors.white54,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right Column: Form Pane (login-card)
                      Expanded(
                        flex: 9,
                        child: Container(
                          color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: loginForm,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
                      border: Border.all(color: isDark ? AppTheme.darkLine : AppTheme.lightLine),
                    ),
                    child: loginForm,
                  ),
                ),
        ),
      ),
    );
  }
}
