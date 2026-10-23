import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper to safely dismiss modal dialogs without triggering GetX route collisions.
void safeDismissDialog(BuildContext context, [dynamic result]) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context, result);
  } else if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop(result);
  } else if (Get.isDialogOpen == true) {
    Get.back(result: result);
  } else {
    try {
      Get.back(result: result);
    } catch (_) {}
  }
}
