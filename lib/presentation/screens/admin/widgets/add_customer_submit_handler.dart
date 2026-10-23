import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/validators.dart';
import '../../../controllers/admin_controller.dart';
import 'add_customer_created_dialog.dart';
import 'add_customer_dialog_helper.dart';
import 'add_customer_media_uploader.dart';

/// Handles customer validation, Firestore writes, and photo uploads.
class AddCustomerSubmitHandler {
  static Future<void> submit({
    required BuildContext context,
    required AdminController controller,
    required String name,
    required String rawPhone,
    required String rawEmail,
    required String address,
    required String city,
    required String state,
    required String mapLocation,
    required String selectedType,
    required Uint8List? photoBytes,
    required String? photoName,
    required Function(bool isUploading) onUploadStateChange,
  }) async {
    if (name.isEmpty) {
      _showError("Validation Error", "Full Name is required.");
      return;
    }

    final normalizedPhone = normalizeCustomerPhone(rawPhone);
    if (normalizedPhone.length != 10) {
      _showError("Validation Error", "Please enter a valid 10-digit phone number.");
      return;
    }

    if (rawEmail.isNotEmpty && !GetUtils.isEmail(rawEmail)) {
      _showError("Validation Error", "Please enter a valid email address.");
      return;
    }

    final adminUser = FirebaseAuth.instance.currentUser;
    if (adminUser == null) {
      throw Exception("Admin authentication required to create customer profiles.");
    }

    // Duplicate Phone Check
    final existingDoc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(normalizedPhone)
        .get();

    if (existingDoc.exists) {
      _showError("Duplicate Customer", "Customer with this phone number already exists in directory.");
      return;
    }

    // Duplicate Email Check
    if (rawEmail.isNotEmpty) {
      final emailSnap = await FirebaseFirestore.instance
          .collection('customers')
          .where('email', isEqualTo: rawEmail)
          .limit(1)
          .get();
      if (emailSnap.docs.isNotEmpty && emailSnap.docs.first.id != normalizedPhone) {
        _showError("Duplicate Email", "A customer with this email address already exists in directory.");
        return;
      }
    }

    // Auth UID Lookup
    String authUid = '';
    if (rawEmail.isNotEmpty) {
      try {
        final profileSnap = await FirebaseFirestore.instance
            .collection('customer_profiles')
            .where('email', isEqualTo: rawEmail)
            .limit(1)
            .get();
        if (profileSnap.docs.isNotEmpty) {
          authUid = profileSnap.docs.first.id;
        } else {
          final userSnap = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: rawEmail)
              .limit(1)
              .get();
          if (userSnap.docs.isNotEmpty) authUid = userSnap.docs.first.id;
        }
      } catch (_) {}
    }

    final customerDocRef = FirebaseFirestore.instance.collection('customers').doc(normalizedPhone);
    final customerData = {
      'id': normalizedPhone, 'phone': normalizedPhone, 'name': name, 'full_name': name,
      'email': rawEmail, 'address': address, 'city': city, 'state': state,
      'map_location': mapLocation, 'type': selectedType,
      'profile_image_url': '', 'profileImageUrl': '', 'auth_uid': authUid,
      'login_enabled': true, 'login_method': 'email_password', 'must_change_password': true,
      'created_at': FieldValue.serverTimestamp(), 'updated_at': FieldValue.serverTimestamp(),
    };

    try {
      await customerDocRef.set(customerData).timeout(const Duration(seconds: 8));
    } on FirebaseException catch (fe) {
      _handleFirebaseError(fe);
      return;
    } on TimeoutException {
      _showError("Request Timeout", "Firestore write timed out after 8 seconds. Please check network.");
      return;
    }

    if (authUid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('customer_profiles').doc(authUid).set({
          'id': authUid,
          'customer_phone_key': normalizedPhone,
          'full_name': name,
          'name': name,
          'phone': normalizedPhone,
          'email': rawEmail,
          'profile_image_url': '',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }

    // Supabase Media Upload
    bool photoUploadFailed = false;
    if (photoBytes != null && photoName != null) {
      onUploadStateChange(true);
      final uploaded = await AddCustomerMediaUploader.uploadPhoto(
        normalizedPhone: normalizedPhone,
        authUid: authUid,
        photoBytes: photoBytes,
        photoName: photoName,
        customerDocRef: customerDocRef,
      );
      if (!uploaded) photoUploadFailed = true;
      onUploadStateChange(false);
    }

    await controller.loadCustomers();

    if (context.mounted) {
      safeDismissDialog(context, true);
      showCustomerCreatedSuccessDialog(
        context,
        name: name,
        phone: normalizedPhone,
        email: rawEmail,
      );
      if (photoUploadFailed) {
        Get.snackbar("Media Upload Note", "Customer created successfully, but profile photo upload failed.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.amber.shade900,
            colorText: Colors.white);
      }
    }
  }

  static void _showError(String title, String message) {
    Get.snackbar(title, message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        duration: const Duration(seconds: 4));
  }

  static void _handleFirebaseError(FirebaseException fe) {
    String msg = fe.code == 'resource-exhausted'
        ? "Firestore daily write limit has been reached."
        : "Could not save customer: ${fe.message ?? fe.code}";
    Get.snackbar("Firestore Error", msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        duration: const Duration(seconds: 6));
  }
}
