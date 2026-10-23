import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../controllers/admin_controller.dart';
import 'add_customer_dialog.dart';

/// Loading, empty, error, and search-result states for Customer Directory.
class CustomerDirectoryStates {
  static Widget buildLoading(Color subtitleColor, Color primaryAccent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: primaryAccent, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text(
            'Loading client directory...',
            style: AppTheme.sansBody(fontSize: 13, color: subtitleColor),
          ),
        ],
      ),
    );
  }

  static Widget buildError({
    required AdminController controller,
    required Color textColor,
    required Color subtitleColor,
    required Color primaryAccent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text('Unable to load customers', style: AppTheme.serifHeader(fontSize: 18, color: textColor)),
          const SizedBox(height: 6),
          Text(controller.customerLoadError.value, style: AppTheme.sansBody(fontSize: 12, color: subtitleColor)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('RETRY'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () => controller.loadCustomers(),
          ),
        ],
      ),
    );
  }

  static Widget buildEmpty({
    required AdminController controller,
    required Color textColor,
    required Color subtitleColor,
    required Color primaryAccent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: primaryAccent.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No Customers Found', style: AppTheme.serifHeader(fontSize: 20, color: textColor)),
          const SizedBox(height: 8),
          Text(
            'Your customer directory is currently empty.',
            style: AppTheme.sansBody(fontSize: 13, color: subtitleColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('ADD FIRST CLIENT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: () => Get.dialog(CustomerCreateDialog(controller: controller)),
          ),
        ],
      ),
    );
  }

  static Widget buildNoResults({
    required String query,
    required VoidCallback onClear,
    required Color textColor,
    required Color subtitleColor,
    required Color primaryAccent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: subtitleColor),
          const SizedBox(height: 12),
          Text("No clients match '$query'", style: AppTheme.serifHeader(fontSize: 18, color: textColor)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onClear,
            child: Text(
              'CLEAR SEARCH',
              style: AppTheme.sansBody(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: primaryAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
