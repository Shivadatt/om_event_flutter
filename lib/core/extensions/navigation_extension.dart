import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Extension methods on [BuildContext] to simplify route-based navigation.
extension NavigationExtension on BuildContext {
  /// Navigates to a named route.
  Future<dynamic>? toNamed(String routeName, {dynamic arguments}) =>
      Get.toNamed(routeName, arguments: arguments);

  /// Closes the current screen / dialog / bottom sheet.
  void back() => Get.back();

  /// Replaces the current page with a named route.
  Future<dynamic>? offNamed(String routeName, {dynamic arguments}) =>
      Get.offNamed(routeName, arguments: arguments);

  /// Clears the navigation stack and sets the home/root route.
  Future<dynamic>? offAllNamed(String routeName, {dynamic arguments}) =>
      Get.offAllNamed(routeName, arguments: arguments);
}
