import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_routes.dart';
import 'video_splash_screen.dart';

/// Legacy splash entry point — consolidated with canonical VideoSplashScreen.
/// Renders the full video splash directly with zero simple logo flash.
class SplashScreen extends StatefulWidget {
  final bool isBootstrapGate;
  const SplashScreen({super.key, this.isBootstrapGate = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _kOnboardingKey = 'onboarding_complete';

  @override
  void initState() {
    super.initState();

    // Only run consumer onboarding timer when not acting as the app bootstrap gate
    if (!widget.isBootstrapGate) {
      Future.delayed(const Duration(milliseconds: 3500), () async {
        if (!mounted) return;
        final prefs = Get.find<SharedPreferences>();
        final hasSeenOnboarding = prefs.getBool(_kOnboardingKey) ?? false;
        if (!mounted) return;
        if (hasSeenOnboarding) {
          Get.offNamed(AppRoutes.home);
        } else {
          Get.offNamed(AppRoutes.onboarding);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoSplashScreen(isBootstrapGate: widget.isBootstrapGate);
  }
}
