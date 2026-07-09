import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../controllers/auth_controller.dart';
import 'admin_sidebar.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDesktop = context.isDesktop;
    final isCollapsed = !isDesktop;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0B1714),
      body: Obx(() {
        final currentAdmin = authController.rxAdminRole.value;
        return Row(
          children: [
            Container(
              width: isCollapsed ? 72 : 240,
              color: const Color(0xFF0D1915),
              child: AdminSidebar(
                currentAdmin: currentAdmin,
                isCollapsed: isCollapsed,
              ),
            ),
            Expanded(
              child: child,
            ),
          ],
        );
      }),
    );
  }
}
