import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';

/// Navigation Drawer for mobile and tablet views of the Customer portal.
class NavDrawer extends StatelessWidget {
  final GlobalKey categoriesKey;
  final GlobalKey catalogKey;
  final GlobalKey storiesKey;
  final GlobalKey contactKey;

  /// Creates a [NavDrawer] with keys targeting section scroll boundaries.
  const NavDrawer({
    super.key,
    required this.categoriesKey,
    required this.catalogKey,
    required this.storiesKey,
    required this.contactKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? AppTheme.darkGold : AppTheme.lightGold;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            Text(
              "OE",
              style: AppTheme.serifHeader(fontSize: 32, color: goldColor),
            ),
            Text(
              "OM EVENTS",
              style: AppTheme.sansBody(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const Divider(height: 40),
            _drawerTile("Collections", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(
                categoriesKey.currentContext!,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }),
            _drawerTile("Experiences", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(
                catalogKey.currentContext!,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }),
            _drawerTile("Stories", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(
                storiesKey.currentContext!,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }),
            _drawerTile("Contact", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(
                contactKey.currentContext!,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }),
            _drawerTile("Developer API", () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.docs);
            }),
            _drawerTile("Team Studio", () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.login);
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(String label, VoidCallback onTap) {
    return ListTile(
      title: Text(
        label,
        style: AppTheme.sansBody(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      onTap: onTap,
    );
  }
}
