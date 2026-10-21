import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/feature_flags.dart';
import '../constants/app_routes.dart';
import '../utils/app_logger.dart';

/// Route guard preventing direct URL or internal route access to Notifications
/// when notification delivery/UI is disabled via [FeatureFlags.notifications].
class NotificationGuardMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (!FeatureFlags.notifications) {
      AppLogger.info(
        "NotificationGuardMiddleware: Notifications feature is disabled. Redirecting to Customer Dashboard Overview.",
        layer: LogLayer.core,
        className: "NotificationGuardMiddleware",
        methodName: "redirect",
      );
      return const RouteSettings(name: AppRoutes.customerDashboard);
    }
    return null;
  }
}
