import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable utility helper to display snackbars across the app.
class SnackbarHelper {
  SnackbarHelper._();

  /// Displays a success message.
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
  }

  /// Displays an error or failure message.
  static void showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
  }

  /// Displays an informational alert or toast message.
  static void showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueGrey.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
  }
}
