import 'package:flutter/material.dart';

/// Design tokens for the luxury Admin Login presentation.
class LoginConstants {
  LoginConstants._();

  static const Color goldColor = Color(0xFFD4AF37);
  static const Color darkBg = Color(0xFF090E0C);
  static const Color cardBg = Color(0xFF0C120F);
  static const Color inputBg = Color(0xFF131916);
}

/// Responsive device tiers for the Admin Login screen.
enum LoginDeviceTier {
  desktop,
  laptop,
  tablet,
  mobile;

  static LoginDeviceTier fromWidth(double width) {
    if (width >= 1400) return LoginDeviceTier.desktop;
    if (width >= 992) return LoginDeviceTier.laptop;
    if (width >= 700) return LoginDeviceTier.tablet;
    return LoginDeviceTier.mobile;
  }
}
