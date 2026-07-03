import 'package:get/get.dart';
import '../../../core/constants/app_routes.dart';

/// Maps FCM notification payload data to in-app navigation routes.
///
/// Routing rules (priority order):
///   1. `data['type']` — semantic type key
///   2. `data['url']`  — explicit route path
///   3. Fallback       — no navigation (keeps app stable)
///
/// Supported types:
///   booking → /dashboard (customer)
///   admin   → /admin-dashboard
///   quote   → /dashboard
///   payment → /dashboard
class NotificationRouter {
  NotificationRouter._();

  /// Parse payload and navigate to the matching route.
  /// Safe to call from any context — catches all navigation exceptions.
  static void navigate(Map<String, dynamic> data) {
    try {
      final type = (data['type'] ?? '').toString().toLowerCase();
      final url = (data['url'] ?? '').toString();

      print("INFO: NotificationRouter: type=$type url=$url");

      if (type == 'booking' ||
          type == 'quote' ||
          type == 'payment' ||
          type.contains('customer') ||
          url.contains('/dashboard')) {
        print("INFO: NotificationRouter: Routing user to Customer Dashboard");
        Get.toNamed(AppRoutes.customerDashboard);
      } else if (type == 'admin' ||
          type.contains('alert') ||
          type.contains('created') ||
          url.contains('/admin')) {
        print("INFO: NotificationRouter: Routing user to Admin Dashboard");
        Get.toNamed(AppRoutes.adminDashboard);
      } else if (url.isNotEmpty) {
        print("INFO: NotificationRouter: Routing user to explicit path: $url");
        Get.toNamed(url);
      } else {
        print("WARNING: NotificationRouter: Unknown notification type and empty URL. Navigation skipped.");
      }
    } catch (e) {
      print("ERROR: NotificationRouter: navigation failed: $e");
    }
  }
}
