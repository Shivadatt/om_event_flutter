import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/supabase_storage_source.dart';
import '../../../../data/models/customer_model.dart';
import '../../../controllers/admin_controller.dart';
import 'add_customer_dialog_helper.dart';

/// Handles validation, photo upload, and customer profile updates.
class EditCustomerSubmitHandler {
  static Future<void> save({
    required BuildContext context,
    required CustomerModel customer,
    required AdminController controller,
    required String name,
    required String rawPhone,
    required String email,
    required String address,
    required String city,
    required String state,
    required String mapLocation,
    required String selectedType,
    required Uint8List? selectedPhotoBytes,
    required String? selectedPhotoName,
    required bool removedExistingPhoto,
    required Function(bool isUploading) onUploadStateChange,
  }) async {
    if (name.isEmpty) {
      _showError("Validation Error", "Full Name cannot be empty.");
      return;
    }

    final cleanDigits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.length < 10) {
      _showError("Validation Error", "Please enter a valid 10-digit phone number.");
      return;
    }

    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      _showError("Validation Error", "Please enter a valid email address.");
      return;
    }

    final tenDigit = cleanDigits.length >= 10
        ? cleanDigits.substring(cleanDigits.length - 10)
        : cleanDigits;

    String finalPhotoUrl = removedExistingPhoto ? '' : customer.profileImageUrl;

    if (selectedPhotoBytes != null && selectedPhotoName != null) {
      try {
        onUploadStateChange(true);
        final ext = selectedPhotoName.split('.').last.toLowerCase();
        final sanitizedExt = (ext == 'png' || ext == 'webp') ? ext : 'jpg';
        final contentType = ext == 'png'
            ? 'image/png'
            : (ext == 'webp' ? 'image/webp' : 'image/jpeg');

        if (Get.isRegistered<SupabaseStorageSource>()) {
          final storage = Get.find<SupabaseStorageSource>();
          final phoneKey = tenDigit.isNotEmpty ? tenDigit : customer.id;
          final path = 'customers/${phoneKey}_${DateTime.now().millisecondsSinceEpoch}.$sanitizedExt';
          finalPhotoUrl = await storage.uploadFile(
            path,
            selectedPhotoBytes,
            contentType,
            bucket: 'thumbnails',
          );
        }
      } catch (e) {
        debugPrint("[EditCustomerSubmitHandler] Photo upload failed, proceeding: $e");
      } finally {
        onUploadStateChange(false);
      }
    }

    final updated = CustomerModel(
      id: customer.id,
      name: name,
      phone: tenDigit.isNotEmpty ? tenDigit : customer.phone,
      email: email,
      address: address,
      city: city,
      state: state,
      pincode: customer.pincode,
      branch: customer.branch,
      gender: customer.gender,
      dateOfBirth: customer.dateOfBirth,
      profileImageUrl: finalPhotoUrl,
      mapLocation: mapLocation,
      type: selectedType,
      authUid: customer.authUid,
      loginEnabled: customer.loginEnabled,
      loginMethod: customer.loginMethod,
      mustChangePassword: customer.mustChangePassword,
      createdAt: customer.createdAt,
      updatedAt: DateTime.now(),
    );

    if (context.mounted) {
      safeDismissDialog(context, true);
    }

    try {
      final ok = await controller.saveCustomer(updated);
      if (ok) {
        Get.snackbar(
          "Customer Saved",
          "Customer profile updated successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF132219),
          colorText: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _showError("Save Failed", "Could not update customer: $e");
    }
  }

  static void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade900,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
