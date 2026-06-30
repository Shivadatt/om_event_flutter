import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Route to Onboarding after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2600), () {
      Get.offNamed(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkCream : AppTheme.lightCream,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "OE",
                      style: AppTheme.serifHeader(
                        fontSize: 34,
                        color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "OM EVENTS",
                  style: AppTheme.serifHeader(
                    fontSize: 20,
                    color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "MAKE IT MEMORABLE",
                  style: AppTheme.sansBody(
                    fontSize: 8,
                    color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
