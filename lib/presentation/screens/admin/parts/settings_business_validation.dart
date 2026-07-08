part of '../system_settings_screen.dart';

extension _SettingsBusinessValidationExtension on _SystemSettingsScreenState {
  bool _validateBranchInputs() {
    if (_busName.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Business name is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    // Branch 1
    if (_b1Name.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 Name is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b1Address.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 Address is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b1City.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 City is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b1State.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 State is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b1Country.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 Country is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b1Phone1.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 Primary Phone is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // Branch 2
    if (_b2Name.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 Name is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b2Address.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 Address is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b2City.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 City is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b2State.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 State is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b2Country.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 Country is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b2Phone1.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 Primary Phone is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }
}
