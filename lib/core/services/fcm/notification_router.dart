import 'package:get/get.dart';
import '../../../core/constants/app_routes.dart';
import '../../utils/app_logger.dart';
import '../../utils/auth_route_helper.dart';

/// Maps FCM notification payload data to in-app navigation routes with role-based routing.
///
/// Ensures:
///   - Admins/Staff are never sent to customer lounge routes.
///   - Customers are never sent to admin dashboard routes.
class NotificationRouter {
  NotificationRouter._();

  /// Parse payload and navigate to the matching route.
  /// Safe to call from any context — catches all navigation exceptions.
  static void navigate(Map<String, dynamic> data) {
    try {
      final type = (data['type'] ?? '').toString().toLowerCase();
      final url = (data['url'] ?? '').toString();
      final isAdmin = AuthRouteHelper.isCurrentAdminOrStaff();

      AppLogger.info('NotificationRouter: type=$type url=$url isAdmin=$isAdmin');

      if (isAdmin) {
        if (type == 'booking') {
          Get.toNamed(AppRoutes.adminBookings);
        } else if (type == 'quote') {
          Get.toNamed(AppRoutes.manageQuotes);
        } else if (type == 'admin' || url.contains('/admin')) {
          Get.toNamed(AppRoutes.adminDashboard);
        } else if (url.isNotEmpty && !url.contains('/dashboard')) {
          Get.toNamed(url);
        } else {
          Get.toNamed(AppRoutes.adminDashboard);
        }
      } else {
        if (type == 'booking' ||
            type == 'quote' ||
            type == 'payment' ||
            url.contains('/dashboard')) {
          Get.toNamed(AppRoutes.customerDashboard);
        } else if (url.isNotEmpty && !url.contains('/admin')) {
          Get.toNamed(url);
        }
      }
    } catch (e) {
      AppLogger.error('NotificationRouter: navigation failed', e);
    }
  }
}
