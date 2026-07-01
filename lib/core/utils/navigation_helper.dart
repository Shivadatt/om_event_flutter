import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_routes.dart';

/// Enterprise-grade navigation helper ensuring back navigation always works.
class NavigationHelper {
  NavigationHelper._();

  /// Safely pops the current screen if a history exists on the navigation stack,
  /// otherwise redirects the user directly to the Admin Dashboard.
  static void safeBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.offAllNamed(AppRoutes.adminDashboard);
    }
  }
}
