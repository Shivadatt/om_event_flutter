import 'package:flutter/material.dart';

/// Extension methods on [BuildContext] to simplify media query and screen size access.
extension ContextExtension on BuildContext {
  /// The horizontal width of the screen viewport.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// The vertical height of the screen viewport.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns true if the screen width is mobile-sized (less than 600px).
  bool get isMobile => screenWidth < 600;

  /// Returns true if the screen width is tablet-sized (between 600px and 1024px).
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;

  /// Returns true if the screen width is desktop-sized (1024px or wider).
  bool get isDesktop => screenWidth >= 1024;
}
