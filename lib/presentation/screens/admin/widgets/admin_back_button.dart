import 'package:flutter/material.dart';
import '../../../../core/utils/navigation_helper.dart';

/// Reusable enterprise back navigation button for all admin screens.
class AdminBackButton extends StatelessWidget {
  final Color? color;
  const AdminBackButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: color ?? Colors.white,
      onPressed: () => NavigationHelper.safeBack(context),
    );
  }
}
