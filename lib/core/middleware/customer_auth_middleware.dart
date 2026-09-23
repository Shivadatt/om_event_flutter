import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_routes.dart';
import '../../presentation/controllers/customer_auth_controller.dart';

/// Route guard for customer protected routes (e.g. Dashboard/Tracker).
///
/// Ensures the visitor has a valid non-anonymous customer session.
/// If not authenticated, redirects to [AppRoutes.customerLogin]
/// preserving the originally requested path in query parameter `redirect`.
class CustomerAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (Get.isRegistered<CustomerAuthController>()) {
      final authCtrl = Get.find<CustomerAuthController>();
      if (authCtrl.isAuthenticatedCustomer) return null;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.isAnonymous) return null;
    }

    final encodedRoute = Uri.encodeComponent(route ?? '');
    return RouteSettings(
      name: '${AppRoutes.customerLogin}?redirect=$encodedRoute',
    );
  }
}
