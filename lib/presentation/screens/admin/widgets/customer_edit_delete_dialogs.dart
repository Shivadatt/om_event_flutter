import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/datasources/supabase_storage_source.dart';
import '../../../controllers/admin_controller.dart';
import '../../../../data/models/customer_model.dart';

/// Helper to safely dismiss modal dialogs without triggering GetX snackbar route collisions.
void _dismissDialog(BuildContext context, [dynamic result]) {
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

/// Dialog for confirming customer deletion from the admin directory.
class CustomerDeleteDialog extends StatelessWidget {
  final CustomerModel customer;
  final AdminController controller;

  const CustomerDeleteDialog({
    super.key,
    required this.customer,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    final displayName = customer.name.isNotEmpty ? customer.name : customer.phone;
    final displayPhone = customer.phone.isNotEmpty ? customer.phone : customer.id;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  'DELETE CLIENT',
                  style: AppTheme.sansBody(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Are you sure you want to permanently delete '$displayName' ($displayPhone)?\n\nThis customer record will be permanently deleted from the database. Historical quotations and bookings will remain preserved.",
              style: AppTheme.sansBody(fontSize: 13, color: textColor.withValues(alpha: 0.7), height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _dismissDialog(context),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  child: Text('CANCEL', style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.6))),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    _dismissDialog(context, true);
                    final targetId = customer.id.isNotEmpty ? customer.id : customer.phone;
                    final ok = await controller.deleteCustomer(targetId);
                    if (ok) {
                      Get.snackbar(
                        "Client Deleted",
                        "Client '$displayName' deleted successfully.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF132219),
                        colorText: const Color(0xFFD4AF37),
                        duration: const Duration(seconds: 3),
                      );
                    }
                  },
                  child: Text('CONFIRM DELETE', style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for creating a new customer profile in the admin directory.
class CustomerCreateDialog extends StatefulWidget {
  final AdminController controller;

  const CustomerCreateDialog({super.key, required this.controller});

  @override
  State<CustomerCreateDialog> createState() => _CustomerCreateDialogState();
}

class _CustomerCreateDialogState extends State<CustomerCreateDialog> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addrCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final locCtrl = TextEditingController();
  String selectedType = 'Individual';

  Uint8List? _selectedPhotoBytes;
  String? _selectedPhotoName;
  bool _isUploadingPhoto = false;
  bool isSaving = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addrCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    locCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) return;

      if (file.size > 2 * 1024 * 1024) {
        Get.snackbar(
          "File Too Large",
          "Profile photo must be less than 2MB.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return;
      }

      setState(() {
        _selectedPhotoBytes = file.bytes;
        _selectedPhotoName = file.name;
      });
    } catch (e) {
      Get.snackbar(
        "Photo Error",
        "Could not select photo: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleCreate() async {
    if (isSaving) return;

    final name = nameCtrl.text.trim();
    final rawPhone = phoneCtrl.text.trim();
    final rawEmail = emailCtrl.text.trim().toLowerCase();

    debugPrint('[CLIENT_CREATE][START]');
    debugPrint('[CLIENT_CREATE][START] name provided=${name.isNotEmpty}');
    debugPrint('[CLIENT_CREATE][START] phone provided=${rawPhone.isNotEmpty}');
    debugPrint('[CLIENT_CREATE][START] email provided=${rawEmail.isNotEmpty}');

    // 1. Validation
    debugPrint('[CLIENT_CREATE][VALIDATION] checking fields');
    if (name.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Full Name is required.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final normalizedPhone = normalizeCustomerPhone(rawPhone);
    if (normalizedPhone.length != 10) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid 10-digit phone number.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    if (rawEmail.isNotEmpty && !GetUtils.isEmail(rawEmail)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid email address.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final maskedPhone = normalizedPhone.length >= 4
        ? '******${normalizedPhone.substring(normalizedPhone.length - 2)}'
        : '****';

    setState(() => isSaving = true);

    try {
      // 2. Admin Authentication Verification
      final adminUser = FirebaseAuth.instance.currentUser;
      final isAdminAuth = adminUser != null;
      debugPrint('[CLIENT_CREATE][AUTH] admin authenticated=$isAdminAuth');
      if (!isAdminAuth) {
        throw Exception("Admin authentication required to create customer profiles.");
      }

      // 3. Firestore Prechecks: Duplicate phone & Duplicate email
      debugPrint('[CLIENT_CREATE][FIRESTORE_PRECHECK] phoneKey=$maskedPhone');
      final existingDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(normalizedPhone)
          .get();

      if (existingDoc.exists) {
        debugPrint('[CLIENT_CREATE][FIRESTORE_PRECHECK] phoneKey=$maskedPhone exists=true (duplicate)');
        Get.snackbar(
          "Duplicate Customer",
          "Customer with this phone number already exists in directory.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }
      debugPrint('[CLIENT_CREATE][FIRESTORE_PRECHECK] phoneKey=$maskedPhone exists=false');

      // Duplicate email check
      if (rawEmail.isNotEmpty) {
        final emailSnap = await FirebaseFirestore.instance
            .collection('customers')
            .where('email', isEqualTo: rawEmail)
            .limit(1)
            .get();

        if (emailSnap.docs.isNotEmpty) {
          final conflictId = emailSnap.docs.first.id;
          if (conflictId != normalizedPhone) {
            debugPrint('[CLIENT_CREATE][FIRESTORE_PRECHECK] email duplicate found on doc $conflictId');
            Get.snackbar(
              "Duplicate Email",
              "A customer with this email address already exists in directory.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade900,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
            return;
          }
        }
      }

      // 4. Resolve Auth UID if profile or user exists
      String authUid = '';
      if (rawEmail.isNotEmpty) {
        debugPrint('[CLIENT_CREATE][AUTH_UID] resolving Auth UID for $rawEmail');
        try {
          final profileSnap = await FirebaseFirestore.instance
              .collection('customer_profiles')
              .where('email', isEqualTo: rawEmail)
              .limit(1)
              .get();
          if (profileSnap.docs.isNotEmpty) {
            authUid = profileSnap.docs.first.id;
            debugPrint('[CLIENT_CREATE][AUTH_UID] resolved from customer_profiles: $authUid');
          } else {
            final userSnap = await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: rawEmail)
                .limit(1)
                .get();
            if (userSnap.docs.isNotEmpty) {
              authUid = userSnap.docs.first.id;
              debugPrint('[CLIENT_CREATE][AUTH_UID] resolved from users: $authUid');
            }
          }
        } catch (lookupErr) {
          debugPrint('[CLIENT_CREATE][AUTH_UID] Note on auth lookup: $lookupErr');
        }
      }

      // 5. Write Canonical Firestore Customer Document (customers/{normalizedPhone})
      debugPrint('[FS_WRITE][START]\ncollection=customers\noperation=set');
      debugPrint('[FS_WRITE_COUNT]\ncustomers/$normalizedPhone\ncount=1');
      debugPrint('[CLIENT_CREATE][FIRESTORE_WRITE_START] collection=customers docId=$normalizedPhone');

      final customerDocRef = FirebaseFirestore.instance
          .collection('customers')
          .doc(normalizedPhone);

      final Map<String, dynamic> customerData = {
        'id': normalizedPhone,
        'phone': normalizedPhone,
        'name': name,
        'full_name': name,
        'email': rawEmail,
        'address': addrCtrl.text.trim(),
        'city': cityCtrl.text.trim(),
        'state': stateCtrl.text.trim(),
        'map_location': locCtrl.text.trim(),
        'type': selectedType,
        'profile_image_url': '',
        'profileImageUrl': '',
        'auth_uid': authUid,
        'login_enabled': true,
        'login_method': 'email_password',
        'must_change_password': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      try {
        debugPrint('[CLIENT_CREATE][FIRESTORE_WRITE_EXEC] sending set() to Firestore...');
        await customerDocRef.set(customerData).timeout(
          const Duration(seconds: 8),
          onTimeout: () {
            debugPrint('[FS_WRITE][ERROR]\ncode=deadline-exceeded');
            debugPrint('[CLIENT_CREATE][FIRESTORE_ERROR]\ncode=deadline-exceeded');
            debugPrint('[CLIENT_CREATE][FIRESTORE_ERROR_MESSAGE]\nFirestore write timed out after 8 seconds');
            throw TimeoutException('Firestore write timed out after 8 seconds');
          },
        );
        debugPrint('[FS_WRITE][SUCCESS]\ncollection=customers');
        debugPrint('[CLIENT_CREATE][FIRESTORE_WRITE_SUCCESS] document customers/$normalizedPhone successfully written to Firestore backend!');
      } on FirebaseException catch (fe, st) {
        debugPrint('[FS_WRITE][ERROR]\ncode=${fe.code}');
        debugPrint('[CLIENT_CREATE][FIRESTORE_ERROR]\ncode=${fe.code}');
        debugPrint('[CLIENT_CREATE][FIRESTORE_ERROR_MESSAGE]\n${fe.message}');
        debugPrint('[CLIENT_CREATE][FIRESTORE_WRITE_STACK] $st');

        String userMessage;
        if (fe.code == 'resource-exhausted' || (fe.message != null && fe.message!.contains('Quota exceeded'))) {
          userMessage = "Firestore daily write limit has been reached. Please try again after the quota resets or upgrade the Firebase plan.";
        } else if (fe.code == 'permission-denied') {
          userMessage = "Permission Denied: Admin session not authorized.";
        } else if (fe.code == 'unavailable') {
          userMessage = "Firestore Service Unavailable: Network or service offline.";
        } else if (fe.code == 'deadline-exceeded') {
          userMessage = "Firestore Request Timeout: Operation took too long.";
        } else {
          userMessage = "Could not save customer: ${fe.message ?? fe.code}";
        }

        Get.snackbar(
          fe.code == 'resource-exhausted' ? "Firestore Daily Limit" : "Firestore Error",
          userMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
          duration: const Duration(seconds: 7),
        );
        return;
      } on TimeoutException {
        debugPrint('[FS_WRITE][ERROR]\ncode=deadline-exceeded');
        debugPrint('[CLIENT_CREATE][FIRESTORE_ERROR]\ncode=deadline-exceeded');
        Get.snackbar(
          "Request Timeout",
          "Firestore write timed out after 8 seconds. This typically occurs when Firebase daily write quota is exhausted or connection is offline.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
          duration: const Duration(seconds: 7),
        );
        return;
      } catch (writeErr, st) {
        debugPrint('[FS_WRITE][ERROR]\ncode=unknown');
        debugPrint('[CLIENT_CREATE][FIRESTORE_ERROR]\ncode=unknown');
        debugPrint('[CLIENT_CREATE][FIRESTORE_ERROR_MESSAGE]\n$writeErr');
        debugPrint('[CLIENT_CREATE][FIRESTORE_WRITE_STACK] $st');
        final errString = writeErr.toString();
        final isQuota = errString.contains('Quota exceeded') ||
            errString.contains('429') ||
            errString.contains('RESOURCE_EXHAUSTED');
        Get.snackbar(
          isQuota ? "Firestore Daily Limit" : "Creation Error",
          isQuota
              ? "Firestore daily write limit has been reached. Please try again after the quota resets or upgrade the Firebase plan."
              : "Could not save customer: $writeErr",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
          duration: const Duration(seconds: 7),
        );
        return;
      }

      // 6. Write/update customer_profiles/{authUid} if authUid is available
      if (authUid.isNotEmpty) {
        try {
          debugPrint('[FS_WRITE][START]\ncollection=customer_profiles\noperation=set');
          debugPrint('[FS_WRITE_COUNT]\ncustomer_profiles/$authUid\ncount=1');
          final profileRef = FirebaseFirestore.instance
              .collection('customer_profiles')
              .doc(authUid);
          await profileRef.set({
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
          debugPrint('[FS_WRITE][SUCCESS]\ncollection=customer_profiles');
          debugPrint('[CLIENT_CREATE][PROFILE_WRITE_SUCCESS] customer profile persisted=true');
        } catch (profileErr) {
          debugPrint('[FS_WRITE][ERROR]\ncode=profile-write-error');
          debugPrint('[CLIENT_CREATE][PROFILE_WRITE_WARN] Note on profile write: $profileErr');
        }
      }

      // 7. Supabase Media Upload (Executed ONLY after customer persistence succeeds)
      String uploadedPhotoUrl = '';
      bool photoUploadFailed = false;
      if (_selectedPhotoBytes != null && _selectedPhotoName != null) {
        debugPrint('[CLIENT_CREATE][PHOTO_UPLOAD_START] photo upload starting: name=$_selectedPhotoName bytes=${_selectedPhotoBytes!.length}');
        setState(() => _isUploadingPhoto = true);
        try {
          final ext = _selectedPhotoName!.split('.').last.toLowerCase();
          final sanitizedExt = (ext == 'png' || ext == 'webp' || ext == 'pdf') ? ext : 'jpg';
          final contentType = ext == 'png'
              ? 'image/png'
              : (ext == 'webp' ? 'image/webp' : (ext == 'pdf' ? 'application/pdf' : 'image/jpeg'));

          if (Get.isRegistered<SupabaseStorageSource>()) {
            final storage = Get.find<SupabaseStorageSource>();
            final path = 'customers/${normalizedPhone}_${DateTime.now().millisecondsSinceEpoch}.$sanitizedExt';
            uploadedPhotoUrl = await storage.uploadFile(
              path,
              _selectedPhotoBytes!,
              contentType,
              bucket: 'thumbnails',
            );
            debugPrint('[CLIENT_CREATE][PHOTO_UPLOAD_SUCCESS] url=$uploadedPhotoUrl');

            // 8. Update customers/{normalizedPhone} with media URL
            debugPrint('[FS_WRITE][START]\ncollection=customers\noperation=update');
            debugPrint('[FS_WRITE_COUNT]\ncustomers/$normalizedPhone\ncount=2');
            await customerDocRef.update({
              'profile_image_url': uploadedPhotoUrl,
              'profileImageUrl': uploadedPhotoUrl,
              'updated_at': FieldValue.serverTimestamp(),
            }).timeout(const Duration(seconds: 5));
            debugPrint('[FS_WRITE][SUCCESS]\ncollection=customers');

            if (authUid.isNotEmpty) {
              await FirebaseFirestore.instance
                  .collection('customer_profiles')
                  .doc(authUid)
                  .update({
                'profile_image_url': uploadedPhotoUrl,
                'updated_at': FieldValue.serverTimestamp(),
              }).timeout(const Duration(seconds: 5)).catchError((_) {});
            }
          }
        } catch (mediaErr) {
          photoUploadFailed = true;
          debugPrint('[CLIENT_CREATE][PHOTO_UPLOAD_ERROR] $mediaErr');
        } finally {
          if (mounted) setState(() => _isUploadingPhoto = false);
        }
      }

      // 9. Refresh Customer List from Firestore
      debugPrint('[CLIENT_CREATE][REFRESH] customer stream refreshed');
      await widget.controller.loadCustomers();
      debugPrint('[CLIENT_CREATE][SUCCESS] customer fully persisted');

      // 10. Close Dialog and notify user
      if (mounted) {
        _dismissDialog(context, true);
        if (photoUploadFailed) {
          Get.snackbar(
            "Customer Created",
            "Customer created, but profile media upload failed.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.amber.shade900,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        } else {
          Get.snackbar(
            "Client Created",
            "Client '$name' added to directory and verified in Firestore.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF132219),
            colorText: const Color(0xFFD4AF37),
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e, st) {
      debugPrint('[CLIENT_CREATE][ERROR] $e');
      debugPrint('[CLIENT_CREATE][STACK] $st');
      Get.snackbar(
        "Creation Error",
        "Could not save customer: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    required Color textColor,
    required Color borderColor,
    required Color subtitleColor,
    required Color fieldFill,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryAccent,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: AppTheme.sansBody(fontSize: 13, color: textColor),
            decoration: InputDecoration(
              filled: false,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              hintText: hint,
              hintStyle: AppTheme.sansBody(fontSize: 13, color: subtitleColor.withValues(alpha: 0.5)),
              prefixIcon: Icon(icon, color: AppColors.primaryAccent.withValues(alpha: 0.7), size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField({
    required TextEditingController ctrl,
    required Color textColor,
    required Color borderColor,
    required Color subtitleColor,
    required Color fieldFill,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHONE NUMBER *',
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryAccent,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(Icons.phone_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.7), size: 18),
              const SizedBox(width: 10),
              Text(
                '+91',
                style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 18, color: borderColor),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.phone,
                  style: AppTheme.sansBody(fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: '9876543210',
                    hintStyle: AppTheme.sansBody(fontSize: 13, color: subtitleColor.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown({
    required Color textColor,
    required Color borderColor,
    required Color fieldFill,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLIENT TYPE *',
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryAccent,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(Icons.person_pin_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.7), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    dropdownColor: fieldFill,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryAccent, size: 20),
                    items: const [
                      DropdownMenuItem(value: 'Individual', child: Text('Individual')),
                      DropdownMenuItem(value: 'Business', child: Text('Business')),
                      DropdownMenuItem(value: 'Corporate', child: Text('Corporate')),
                      DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                    style: AppTheme.sansBody(fontSize: 13, color: textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadBox({
    required Color borderColor,
    required Color textColor,
    required Color subtitleColor,
    required Color fieldFill,
    required double width,
    required double height,
  }) {
    return InkWell(
      onTap: _isUploadingPhoto ? null : _pickPhoto,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fieldFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryAccent.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _selectedPhotoBytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    _selectedPhotoBytes!,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit_outlined, size: 12, color: AppColors.primaryAccent),
                          const SizedBox(width: 4),
                          Text(
                            'Change',
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => setState(() {
                              _selectedPhotoBytes = null;
                              _selectedPhotoName = null;
                            }),
                            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isUploadingPhoto)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryAccent.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primaryAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Photo',
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'JPG, PNG (Max 2MB)',
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      color: subtitleColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color cardColor = isDark ? const Color(0xFF0F1511) : AppColors.lightPaper;
    final Color fieldFill = isDark ? const Color(0xFF131A15) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? const Color(0xFF1F3025) : AppColors.lightLine;
    final Color subtitleColor = isDark ? const Color(0xFF8E9893) : AppColors.lightMuted;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 750),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryAccent.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(28, 22, 20, 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Client',
                          style: AppTheme.serifHeader(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Create a new client profile with complete information.',
                          style: AppTheme.sansBody(fontSize: 12, color: subtitleColor),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: textColor.withValues(alpha: 0.6),
                      onPressed: () => _dismissDialog(context),
                    ),
                  ],
                ),
              ),

              // SCROLLABLE FORM
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 580;

                      if (isNarrow) {
                        // Stacked layout for mobile / small screen
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: _buildPhotoUploadBox(
                                borderColor: borderColor,
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                fieldFill: fieldFill,
                                width: 140,
                                height: 130,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildField(
                              label: 'Full Name *',
                              ctrl: nameCtrl,
                              hint: 'e.g. Shivadatt Goswami',
                              icon: Icons.person_outline_rounded,
                              textColor: textColor,
                              borderColor: borderColor,
                              subtitleColor: subtitleColor,
                              fieldFill: fieldFill,
                            ),
                            const SizedBox(height: 12),
                            _buildPhoneField(
                              ctrl: phoneCtrl,
                              textColor: textColor,
                              borderColor: borderColor,
                              subtitleColor: subtitleColor,
                              fieldFill: fieldFill,
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              label: 'Email Address',
                              ctrl: emailCtrl,
                              hint: 'e.g. shivadatt@gmail.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textColor: textColor,
                              borderColor: borderColor,
                              subtitleColor: subtitleColor,
                              fieldFill: fieldFill,
                            ),
                            const SizedBox(height: 12),
                            _buildTypeDropdown(
                              textColor: textColor,
                              borderColor: borderColor,
                              fieldFill: fieldFill,
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              label: 'Street Address',
                              ctrl: addrCtrl,
                              hint: 'e.g. 403 Grand Imperial Heights',
                              icon: Icons.home_outlined,
                              textColor: textColor,
                              borderColor: borderColor,
                              subtitleColor: subtitleColor,
                              fieldFill: fieldFill,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    label: 'City',
                                    ctrl: cityCtrl,
                                    hint: 'e.g. Ahmedabad',
                                    icon: Icons.location_city_outlined,
                                    textColor: textColor,
                                    borderColor: borderColor,
                                    subtitleColor: subtitleColor,
                                    fieldFill: fieldFill,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildField(
                                    label: 'State',
                                    ctrl: stateCtrl,
                                    hint: 'e.g. Gujarat',
                                    icon: Icons.map_outlined,
                                    textColor: textColor,
                                    borderColor: borderColor,
                                    subtitleColor: subtitleColor,
                                    fieldFill: fieldFill,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              label: 'Map Location / GPS URL',
                              ctrl: locCtrl,
                              hint: 'e.g. https://maps.google.com/...',
                              icon: Icons.pin_drop_outlined,
                              textColor: textColor,
                              borderColor: borderColor,
                              subtitleColor: subtitleColor,
                              fieldFill: fieldFill,
                            ),
                          ],
                        );
                      }

                      // Reference 2-column layout for Desktop / Tablet
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // UPPER SECTION: Photo on left, Rows 1 & 2 on right
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPhotoUploadBox(
                                borderColor: borderColor,
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                fieldFill: fieldFill,
                                width: 140,
                                height: 144,
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  children: [
                                    // Row 1: Full Name * | Phone Number *
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildField(
                                            label: 'Full Name *',
                                            ctrl: nameCtrl,
                                            hint: 'e.g. Shivadatt Goswami',
                                            icon: Icons.person_outline_rounded,
                                            textColor: textColor,
                                            borderColor: borderColor,
                                            subtitleColor: subtitleColor,
                                            fieldFill: fieldFill,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _buildPhoneField(
                                            ctrl: phoneCtrl,
                                            textColor: textColor,
                                            borderColor: borderColor,
                                            subtitleColor: subtitleColor,
                                            fieldFill: fieldFill,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    // Row 2: Email Address | Client Type *
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildField(
                                            label: 'Email Address',
                                            ctrl: emailCtrl,
                                            hint: 'e.g. shivadatt@gmail.com',
                                            icon: Icons.email_outlined,
                                            keyboardType: TextInputType.emailAddress,
                                            textColor: textColor,
                                            borderColor: borderColor,
                                            subtitleColor: subtitleColor,
                                            fieldFill: fieldFill,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _buildTypeDropdown(
                                            textColor: textColor,
                                            borderColor: borderColor,
                                            fieldFill: fieldFill,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // LOWER SECTION: Street Address (Full Width)
                          _buildField(
                            label: 'Street Address',
                            ctrl: addrCtrl,
                            hint: 'e.g. 403 Grand Imperial Heights',
                            icon: Icons.home_outlined,
                            textColor: textColor,
                            borderColor: borderColor,
                            subtitleColor: subtitleColor,
                            fieldFill: fieldFill,
                          ),
                          const SizedBox(height: 14),

                          // Row 4: City | State
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  label: 'City',
                                  ctrl: cityCtrl,
                                  hint: 'e.g. Ahmedabad',
                                  icon: Icons.location_city_outlined,
                                  textColor: textColor,
                                  borderColor: borderColor,
                                  subtitleColor: subtitleColor,
                                  fieldFill: fieldFill,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildField(
                                  label: 'State',
                                  ctrl: stateCtrl,
                                  hint: 'e.g. Gujarat',
                                  icon: Icons.map_outlined,
                                  textColor: textColor,
                                  borderColor: borderColor,
                                  subtitleColor: subtitleColor,
                                  fieldFill: fieldFill,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Row 5: Map Location / GPS URL (Full Width)
                          _buildField(
                            label: 'Map Location / GPS URL',
                            ctrl: locCtrl,
                            hint: 'e.g. https://maps.google.com/...',
                            icon: Icons.pin_drop_outlined,
                            textColor: textColor,
                            borderColor: borderColor,
                            subtitleColor: subtitleColor,
                            fieldFill: fieldFill,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // FOOTER ACTIONS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor, width: 0.8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isSaving ? null : () => _dismissDialog(context),
                      style: TextButton.styleFrom(
                        backgroundColor: fieldFill,
                        side: BorderSide(color: borderColor),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTheme.sansBody(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton.icon(
                      icon: isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.person_add_outlined, size: 18, color: Colors.black),
                      label: Text(isSaving ? 'Creating...' : 'Create Client'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      onPressed: isSaving ? null : _handleCreate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for editing a customer profile in the admin directory.
class CustomerEditDialog extends StatefulWidget {
  final CustomerModel customer;
  final AdminController controller;

  const CustomerEditDialog({super.key, required this.customer, required this.controller});

  @override
  State<CustomerEditDialog> createState() => _CustomerEditDialogState();
}

class _CustomerEditDialogState extends State<CustomerEditDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController addrCtrl;
  late final TextEditingController cityCtrl;
  late final TextEditingController stateCtrl;
  late final TextEditingController locCtrl;
  late String selectedType;

  Uint8List? _selectedPhotoBytes;
  String? _selectedPhotoName;
  bool _removedExistingPhoto = false;
  bool _isUploadingPhoto = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.customer.name);
    final rawPhone = widget.customer.phone.isNotEmpty ? widget.customer.phone : widget.customer.id;
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    final tenDigit = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
    phoneCtrl = TextEditingController(text: tenDigit);
    emailCtrl = TextEditingController(text: widget.customer.email);
    addrCtrl = TextEditingController(text: widget.customer.address);
    cityCtrl = TextEditingController(text: widget.customer.city);
    stateCtrl = TextEditingController(text: widget.customer.state);
    locCtrl = TextEditingController(text: widget.customer.mapLocation);
    selectedType = widget.customer.type.isNotEmpty ? widget.customer.type : 'Individual';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addrCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    locCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) return;

      if (file.size > 2 * 1024 * 1024) {
        Get.snackbar(
          "File Too Large",
          "Profile photo must be less than 2MB.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return;
      }

      setState(() {
        _selectedPhotoBytes = file.bytes;
        _selectedPhotoName = file.name;
        _removedExistingPhoto = false;
      });
    } catch (e) {
      Get.snackbar(
        "Photo Error",
        "Could not select photo: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleSave() async {
    if (isSaving) return;

    final name = nameCtrl.text.trim();
    final rawPhone = phoneCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Full Name cannot be empty.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final cleanDigits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.length < 10) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid 10-digit phone number.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid email address.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final tenDigit = cleanDigits.length >= 10
        ? cleanDigits.substring(cleanDigits.length - 10)
        : cleanDigits;

    setState(() => isSaving = true);

    String finalPhotoUrl = _removedExistingPhoto ? '' : widget.customer.profileImageUrl;

    if (_selectedPhotoBytes != null && _selectedPhotoName != null) {
      try {
        setState(() => _isUploadingPhoto = true);
        final ext = _selectedPhotoName!.split('.').last.toLowerCase();
        final sanitizedExt = (ext == 'png' || ext == 'webp') ? ext : 'jpg';
        final contentType = ext == 'png'
            ? 'image/png'
            : (ext == 'webp' ? 'image/webp' : 'image/jpeg');

        if (Get.isRegistered<SupabaseStorageSource>()) {
          final storage = Get.find<SupabaseStorageSource>();
          final phoneKey = tenDigit.isNotEmpty ? tenDigit : widget.customer.id;
          final path = 'customers/${phoneKey}_${DateTime.now().millisecondsSinceEpoch}.$sanitizedExt';
          finalPhotoUrl = await storage.uploadFile(
            path,
            _selectedPhotoBytes!,
            contentType,
            bucket: 'thumbnails',
          );
        }
      } catch (e) {
        debugPrint("[CustomerEditDialog] Photo upload failed, proceeding: $e");
      } finally {
        if (mounted) setState(() => _isUploadingPhoto = false);
      }
    }

    final updated = CustomerModel(
      id: widget.customer.id,
      name: name,
      phone: tenDigit.isNotEmpty ? tenDigit : widget.customer.phone,
      email: email,
      address: addrCtrl.text.trim(),
      city: cityCtrl.text.trim(),
      state: stateCtrl.text.trim(),
      pincode: widget.customer.pincode,
      branch: widget.customer.branch,
      gender: widget.customer.gender,
      dateOfBirth: widget.customer.dateOfBirth,
      profileImageUrl: finalPhotoUrl,
      mapLocation: locCtrl.text.trim(),
      type: selectedType,
      createdAt: widget.customer.createdAt,
      updatedAt: DateTime.now(),
    );

    if (mounted) {
      _dismissDialog(context, true);
    }

    try {
      final ok = await widget.controller.saveCustomer(updated);
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
      Get.snackbar(
        "Save Failed",
        "Could not update customer: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    required Color textColor,
    required Color borderColor,
    required Color subtitleColor,
    required Color fieldFill,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryAccent,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: AppTheme.sansBody(fontSize: 13, color: textColor),
            decoration: InputDecoration(
              filled: false,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              hintText: hint,
              hintStyle: AppTheme.sansBody(fontSize: 13, color: subtitleColor.withValues(alpha: 0.5)),
              prefixIcon: Icon(icon, color: AppColors.primaryAccent.withValues(alpha: 0.7), size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField({
    required TextEditingController ctrl,
    required Color textColor,
    required Color borderColor,
    required Color subtitleColor,
    required Color fieldFill,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHONE NUMBER *',
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryAccent,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(Icons.phone_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.7), size: 18),
              const SizedBox(width: 10),
              Text(
                '+91',
                style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 18, color: borderColor),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.phone,
                  style: AppTheme.sansBody(fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: '9876543210',
                    hintStyle: AppTheme.sansBody(fontSize: 13, color: subtitleColor.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown({
    required Color textColor,
    required Color borderColor,
    required Color fieldFill,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLIENT TYPE *',
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryAccent,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(Icons.person_pin_outlined, color: AppColors.primaryAccent.withValues(alpha: 0.7), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    dropdownColor: fieldFill,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryAccent, size: 20),
                    items: const [
                      DropdownMenuItem(value: 'Individual', child: Text('Individual')),
                      DropdownMenuItem(value: 'Business', child: Text('Business')),
                      DropdownMenuItem(value: 'Corporate', child: Text('Corporate')),
                      DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                    style: AppTheme.sansBody(fontSize: 13, color: textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadBox({
    required Color borderColor,
    required Color textColor,
    required Color subtitleColor,
    required Color fieldFill,
    required double width,
    required double height,
  }) {
    final hasMemoryPhoto = _selectedPhotoBytes != null;
    final hasRemotePhoto = !_removedExistingPhoto && widget.customer.profileImageUrl.isNotEmpty;

    return InkWell(
      onTap: _isUploadingPhoto ? null : _pickPhoto,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fieldFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryAccent.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: (hasMemoryPhoto || hasRemotePhoto)
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (hasMemoryPhoto)
                    Image.memory(
                      _selectedPhotoBytes!,
                      fit: BoxFit.cover,
                    )
                  else
                    Image.network(
                      widget.customer.profileImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.broken_image_outlined, color: subtitleColor, size: 36),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit_outlined, size: 12, color: AppColors.primaryAccent),
                          const SizedBox(width: 4),
                          Text(
                            'Change',
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => setState(() {
                              _selectedPhotoBytes = null;
                              _selectedPhotoName = null;
                              _removedExistingPhoto = true;
                            }),
                            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isUploadingPhoto)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryAccent.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primaryAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Photo',
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'JPG, PNG (Max 2MB)',
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      color: subtitleColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color cardColor = isDark ? const Color(0xFF0F1511) : AppColors.lightPaper;
    final Color fieldFill = isDark ? const Color(0xFF131A15) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? const Color(0xFF1F3025) : AppColors.lightLine;
    final Color subtitleColor = isDark ? const Color(0xFF8E9893) : AppColors.lightMuted;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 780),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryAccent.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(28, 22, 20, 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Client Profile',
                          style: AppTheme.serifHeader(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Manage client details with complete information.',
                          style: AppTheme.sansBody(fontSize: 12, color: subtitleColor),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: textColor.withValues(alpha: 0.6),
                      onPressed: () => _dismissDialog(context),
                    ),
                  ],
                ),
              ),

              // SCROLLABLE FORM
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 600;

                      if (isNarrow) {
                        // Stacked layout for mobile / small screen
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: _buildPhotoUploadBox(
                                borderColor: borderColor,
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                fieldFill: fieldFill,
                                width: 140,
                                height: 130,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildField(
                              label: 'Full Name *',
                              ctrl: nameCtrl,
                              hint: 'e.g. Shivadatt Goswami',
                              icon: Icons.person_outline_rounded,
                              textColor: textColor,
                              borderColor: borderColor,
                              subtitleColor: subtitleColor,
                              fieldFill: fieldFill,
                            ),
                            const SizedBox(height: 12),
                            _buildPhoneField(
                              ctrl: phoneCtrl,
                              textColor: textColor,
                              borderColor: borderColor,
                              subtitleColor: subtitleColor,
                              fieldFill: fieldFill,
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              label: 'Email Address *',
                              ctrl: emailCtrl,
                              hint: 'e.g. shivadatt@gmail.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textColor: textColor,
                              borderColor: borderColor,
                              subtitleColor: subtitleColor,
                              fieldFill: fieldFill,
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              label: 'Street Address',
                              ctrl: addrCtrl,
                              hint: 'e.g. 403 Grand Imperial Heights',
                              icon: Icons.home_outlined,
                              textColor: textColor,
                              borderColor: borderColor,
                              subtitleColor: subtitleColor,
                              fieldFill: fieldFill,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    label: 'City',
                                    ctrl: cityCtrl,
                                    hint: 'e.g. Ahmedabad',
                                    icon: Icons.location_city_outlined,
                                    textColor: textColor,
                                    borderColor: borderColor,
                                    subtitleColor: subtitleColor,
                                    fieldFill: fieldFill,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildField(
                                    label: 'State',
                                    ctrl: stateCtrl,
                                    hint: 'e.g. Gujarat',
                                    icon: Icons.map_outlined,
                                    textColor: textColor,
                                    borderColor: borderColor,
                                    subtitleColor: subtitleColor,
                                    fieldFill: fieldFill,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              label: 'Map Location / GPS URL',
                              ctrl: locCtrl,
                              hint: 'e.g. https://maps.google.com/...',
                              icon: Icons.pin_drop_outlined,
                              textColor: textColor,
                              borderColor: borderColor,
                              subtitleColor: subtitleColor,
                              fieldFill: fieldFill,
                            ),
                            const SizedBox(height: 12),
                            _buildTypeDropdown(
                              textColor: textColor,
                              borderColor: borderColor,
                              fieldFill: fieldFill,
                            ),
                          ],
                        );
                      }

                      // Reference 2-column layout for Desktop / Tablet
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT: Dedicated Photo Panel
                          _buildPhotoUploadBox(
                            borderColor: borderColor,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            fieldFill: fieldFill,
                            width: 160,
                            height: 220,
                          ),
                          const SizedBox(width: 20),

                          // RIGHT: Form Fields Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Row 1: Full Name * | Phone Number *
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildField(
                                        label: 'Full Name *',
                                        ctrl: nameCtrl,
                                        hint: 'e.g. Shivadatt Goswami',
                                        icon: Icons.person_outline_rounded,
                                        textColor: textColor,
                                        borderColor: borderColor,
                                        subtitleColor: subtitleColor,
                                        fieldFill: fieldFill,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _buildPhoneField(
                                        ctrl: phoneCtrl,
                                        textColor: textColor,
                                        borderColor: borderColor,
                                        subtitleColor: subtitleColor,
                                        fieldFill: fieldFill,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Row 2: Email Address * (Full width)
                                _buildField(
                                  label: 'Email Address *',
                                  ctrl: emailCtrl,
                                  hint: 'e.g. shivadatt@gmail.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  textColor: textColor,
                                  borderColor: borderColor,
                                  subtitleColor: subtitleColor,
                                  fieldFill: fieldFill,
                                ),
                                const SizedBox(height: 14),

                                // Row 3: Street Address (Full width)
                                _buildField(
                                  label: 'Street Address',
                                  ctrl: addrCtrl,
                                  hint: 'e.g. 403 Grand Imperial Heights',
                                  icon: Icons.home_outlined,
                                  textColor: textColor,
                                  borderColor: borderColor,
                                  subtitleColor: subtitleColor,
                                  fieldFill: fieldFill,
                                ),
                                const SizedBox(height: 14),

                                // Row 4: City | State
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildField(
                                        label: 'City',
                                        ctrl: cityCtrl,
                                        hint: 'e.g. Ahmedabad',
                                        icon: Icons.location_city_outlined,
                                        textColor: textColor,
                                        borderColor: borderColor,
                                        subtitleColor: subtitleColor,
                                        fieldFill: fieldFill,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _buildField(
                                        label: 'State',
                                        ctrl: stateCtrl,
                                        hint: 'e.g. Gujarat',
                                        icon: Icons.map_outlined,
                                        textColor: textColor,
                                        borderColor: borderColor,
                                        subtitleColor: subtitleColor,
                                        fieldFill: fieldFill,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Row 5: Map Location / GPS URL (Full width)
                                _buildField(
                                  label: 'Map Location / GPS URL',
                                  ctrl: locCtrl,
                                  hint: 'e.g. https://maps.google.com/...',
                                  icon: Icons.pin_drop_outlined,
                                  textColor: textColor,
                                  borderColor: borderColor,
                                  subtitleColor: subtitleColor,
                                  fieldFill: fieldFill,
                                ),
                                const SizedBox(height: 14),

                                // Row 6: Client Type * (Full width)
                                _buildTypeDropdown(
                                  textColor: textColor,
                                  borderColor: borderColor,
                                  fieldFill: fieldFill,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // FOOTER ACTIONS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor, width: 0.8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isSaving ? null : () => _dismissDialog(context),
                      style: TextButton.styleFrom(
                        backgroundColor: fieldFill,
                        side: BorderSide(color: borderColor),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTheme.sansBody(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton.icon(
                      icon: isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.bookmark_added_outlined, size: 18, color: Colors.black),
                      label: Text(isSaving ? 'Saving...' : 'Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      onPressed: isSaving ? null : _handleSave,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
