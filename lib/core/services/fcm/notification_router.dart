import 'package:get/get.dart';
import '../../../core/constants/app_routes.dart';
import '../../utils/app_logger.dart';

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

      AppLogger.info('NotificationRouter: type=$type url=$url');

      if (type == 'booking' ||
          type == 'quote' ||
          type == 'payment' ||
          url.contains('/dashboard')) {
        Get.toNamed(AppRoutes.customerDashboard);
      } else if (type == 'admin' || url.contains('/admin')) {
        Get.toNamed(AppRoutes.adminDashboard);
      } else if (url.isNotEmpty) {
        Get.toNamed(url);
      }
      // Unknown type — intentionally do nothing to keep app stable
    } catch (e) {
      AppLogger.error('NotificationRouter: navigation failed', e);
    }
  }
}
