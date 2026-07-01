import 'package:flutter/material.dart';
import 'admin_sidebar.dart';

/// Reusable Admin Drawer widget.
class AdminDrawer extends StatelessWidget {
  final dynamic currentAdmin;

  const AdminDrawer({super.key, required this.currentAdmin});

  @override
  Widget build(BuildContext context) {
    return AdminSidebar(currentAdmin: currentAdmin, isMobileDrawer: true);
  }
}
