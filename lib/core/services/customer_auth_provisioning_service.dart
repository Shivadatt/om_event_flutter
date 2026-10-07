import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_route_helper.dart';

class CustomerInviteResult {
  final bool success;
  final String message;
  final String? email;
  final String? errorCode;

  const CustomerInviteResult({
    required this.success,
    required this.message,
    this.email,
    this.errorCode,
  });
}

class CustomerInviteCompletionResult {
  final bool success;
  final String message;
  final String authUid;
  final String phone;
  final String email;

  const CustomerInviteCompletionResult({
    required this.success,
    required this.message,
    this.authUid = '',
    this.phone = '',
    this.email = '',
  });
}

/// Service managing Customer Portal Invitation and Authentication Provisioning
/// entirely using Firebase Client SDK (Zero Cloud Functions, Zero Supabase Auth).
class CustomerAuthProvisioningService {
  CustomerAuthProvisioningService._();

  static const String _pendingEmailStorageKey = 'pending_customer_invite_email';

  /// Resolves the canonical action-link redirect URL based on current environment.
  /// Uses production domain unless running in local development web session.
  static String getInviteRedirectUrl() {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty && (origin.contains('localhost') || origin.contains('127.0.0.1'))) {
        return '$origin/customer/complete-invite';
      }
    }
    return 'https://om-event.web.app/customer/complete-invite';
  }

  /// Sends a Firebase Authentication email sign-in link directly to the customer.
  /// Uses purely Firebase Client SDK [FirebaseAuth.instance.sendSignInLinkToEmail].
  static Future<CustomerInviteResult> sendPortalInvite({
    required String phone,
    required String email,
    String? name,
  }) async {
    final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
    final normalizedPhone = cleanDigits.length >= 10
        ? cleanDigits.substring(cleanDigits.length - 10)
        : cleanDigits;
    final normalizedEmail = email.trim().toLowerCase();

    final maskedPhone = normalizedPhone.length >= 4
        ? '***${normalizedPhone.substring(normalizedPhone.length - 4)}'
        : '***';

    debugPrint('[CLIENT_INVITE][START]');
    debugPrint('[CLIENT_INVITE][CUSTOMER] phoneKey = $maskedPhone emailExists = ${normalizedEmail.isNotEmpty}');

    // 1. Session verification: Caller must be authenticated admin/staff
    final adminUser = FirebaseAuth.instance.currentUser;
    final currentAdminUidExists = adminUser != null;
    debugPrint('[CLIENT_INVITE][AUTH] currentAdminUidExists = $currentAdminUidExists');

    if (!currentAdminUidExists || !AuthRouteHelper.isCurrentAdminOrStaff()) {
      debugPrint('[CLIENT_INVITE][ERROR] Unauthorized caller. Admin session required.');
      return const CustomerInviteResult(
        success: false,
        message: 'Admin session required. Please sign in to Admin Studio.',
        errorCode: 'unauthorized',
      );
    }

    // 2. Validate email
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      debugPrint('[CLIENT_INVITE][ERROR] Invalid or empty email provided: $normalizedEmail');
      return const CustomerInviteResult(
        success: false,
        message: 'A valid email address is required to send portal invitations.',
        errorCode: 'invalid-email',
      );
    }

    // 3. Verify canonical customer document exists in Firestore
    try {
      debugPrint('[CLIENT_INVITE][CUSTOMER_LOOKUP] Checking customers/$normalizedPhone');
      final custDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(normalizedPhone)
          .get();

      if (!custDoc.exists) {
        debugPrint('[CLIENT_INVITE][ERROR] Canonical customer document not found: $normalizedPhone');
        return const CustomerInviteResult(
          success: false,
          message: 'Customer profile was not found in records.',
          errorCode: 'customer-not-found',
        );
      }
    } catch (e) {
      debugPrint('[CLIENT_INVITE][ERROR] Firestore lookup failed: $e');
      return CustomerInviteResult(
        success: false,
        message: 'Failed to verify customer record: $e',
        errorCode: 'firestore-error',
      );
    }

    // 4. Construct ActionCodeSettings using official Firebase client specifications
    final redirectUrl = getInviteRedirectUrl();
    final actionCodeSettings = ActionCodeSettings(
      url: redirectUrl,
      handleCodeInApp: true,
      androidPackageName: 'com.om.event',
      androidInstallApp: true,
      androidMinimumVersion: '12',
      iOSBundleId: 'com.omevents.omEvent',
    );

    // 5. Store pending email locally (for browser completion on the same device)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingEmailStorageKey, normalizedEmail);
    } catch (_) {}

    // 6. Execute Firebase Client SDK sendSignInLinkToEmail
    debugPrint('[CLIENT_INVITE][EMAIL_LINK] calling sendSignInLinkToEmail for $normalizedEmail');
    try {
      await FirebaseAuth.instance.sendSignInLinkToEmail(
        email: normalizedEmail,
        actionCodeSettings: actionCodeSettings,
      );

      debugPrint('[CLIENT_INVITE][EMAIL_LINK] success = true');

      // Update canonical customer in Firestore: record invite timestamp & enable portal flag
      try {
        await FirebaseFirestore.instance.collection('customers').doc(normalizedPhone).set({
          'login_enabled': true,
          'login_method': 'email_password',
          'invite_sent_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (updateErr) {
        debugPrint('[CLIENT_INVITE][ERROR] Failed to update invite timestamp in Firestore: $updateErr');
      }

      debugPrint('[CLIENT_INVITE][RESULT] Portal invite sent successfully to $normalizedEmail');
      return CustomerInviteResult(
        success: true,
        email: normalizedEmail,
        message: 'Portal invitation sent successfully. Please ask the customer to check their email.',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[CLIENT_INVITE][EMAIL_LINK] success = false');
      debugPrint('[CLIENT_INVITE][FIREBASE_ERROR] code = ${e.code} message = ${e.message}');

      String friendlyMessage = 'Could not send portal invitation.';
      if (e.code == 'invalid-email') {
        friendlyMessage = 'The customer email address is formatted incorrectly.';
      } else if (e.code == 'quota-exceeded') {
        friendlyMessage = 'Email delivery quota exceeded. Please try again later.';
      } else if (e.code == 'unauthorized-continue-uri') {
        friendlyMessage = 'The portal domain is not authorized in Firebase Authentication.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        friendlyMessage = e.message!;
      }

      return CustomerInviteResult(
        success: false,
        message: friendlyMessage,
        errorCode: e.code,
      );
    } catch (e) {
      debugPrint('[CLIENT_INVITE][EMAIL_LINK] success = false');
      debugPrint('[CLIENT_INVITE][FIREBASE_ERROR] code = unknown message = $e');
      return CustomerInviteResult(
        success: false,
        message: 'An unexpected error occurred while sending the invitation: $e',
        errorCode: 'unknown',
      );
    }
  }

  /// Retrieves any pending email stored on the local device for completing an invite.
  static Future<String?> getPendingInviteEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_pendingEmailStorageKey);
    } catch (_) {
      return null;
    }
  }

  /// Saves or updates the pending invite email in local storage.
  static Future<void> savePendingInviteEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingEmailStorageKey, email.trim().toLowerCase());
    } catch (_) {}
  }

  /// Clears the pending email from local storage upon completion.
  static Future<void> clearPendingInviteEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingEmailStorageKey);
    } catch (_) {}
  }

  /// Completes email link sign in, verifies the customer record in Firestore,
  /// and links the new Firebase Auth UID to the canonical `customers/{phone}` document.
  /// Does NOT create duplicate `customers/{uid}` documents.
  static Future<CustomerInviteCompletionResult> completeInviteAndLinkCustomer({
    required String email,
    required String emailLink,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    debugPrint('[CLIENT_INVITE][COMPLETION_START] email=$normalizedEmail');

    try {
      // 1. Sign in with the Firebase email link
      final userCredential = await FirebaseAuth.instance.signInWithEmailLink(
        email: normalizedEmail,
        emailLink: emailLink,
      );

      final user = userCredential.user ?? FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const CustomerInviteCompletionResult(
          success: false,
          message: 'Authentication failed. Please request a fresh invitation link.',
        );
      }

      final authUid = user.uid;
      debugPrint('[CLIENT_INVITE][AUTH_SUCCESS] UID: $authUid');

      // 2. Query canonical Firestore customers by email (Phase 10 Duplicate Protection)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('email', isEqualTo: normalizedEmail)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('[CLIENT_INVITE][ERROR] No customer record matches $normalizedEmail');
        return const CustomerInviteCompletionResult(
          success: false,
          message: 'Customer profile not found. Please contact administration.',
        );
      }

      if (querySnapshot.docs.length > 1) {
        debugPrint('[CLIENT_INVITE][ERROR] Multiple customer records found for $normalizedEmail');
        return const CustomerInviteCompletionResult(
          success: false,
          message: 'Multiple customer profiles use this email. Please contact admin.',
        );
      }

      final customerDoc = querySnapshot.docs.first;
      final phone = customerDoc.id;
      final customerData = customerDoc.data();
      final existingAuthUid = (customerData['auth_uid'] ?? '').toString();

      // Check if auth_uid already belongs to someone else
      if (existingAuthUid.isNotEmpty && existingAuthUid != authUid) {
        debugPrint('[CLIENT_INVITE][ERROR] auth_uid collision: existing=$existingAuthUid, current=$authUid');
        return const CustomerInviteCompletionResult(
          success: false,
          message: 'This customer profile is already linked to another account.',
        );
      }

      // Check if this UID is linked to another customer record
      final otherDocsWithUid = await FirebaseFirestore.instance
          .collection('customers')
          .where('auth_uid', isEqualTo: authUid)
          .get();

      for (final doc in otherDocsWithUid.docs) {
        if (doc.id != phone) {
          debugPrint('[CLIENT_INVITE][ERROR] UID $authUid already claimed by ${doc.id}');
          return const CustomerInviteCompletionResult(
            success: false,
            message: 'This authentication identity is already linked to another customer.',
          );
        }
      }

      // 3. Link Firebase Auth UID to canonical customer record (Phase 7)
      await customerDoc.reference.set({
        'auth_uid': authUid,
        'login_enabled': true,
        'login_method': 'email_password',
        'login_enabled_at': FieldValue.serverTimestamp(),
        if (customerData['login_created_at'] == null)
          'login_created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[CLIENT_INVITE][LINK_SUCCESS] Linked UID $authUid to customers/$phone');

      return CustomerInviteCompletionResult(
        success: true,
        authUid: authUid,
        phone: phone,
        email: normalizedEmail,
        message: 'Email verified and customer profile linked successfully.',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[CLIENT_INVITE][ERROR] FirebaseAuthException: ${e.code} ${e.message}');
      String msg = 'Could not verify invitation link.';
      if (e.code == 'invalid-action-code') {
        msg = 'This invitation link has expired or has already been used.';
      } else if (e.code == 'invalid-email') {
        msg = 'The email address does not match the invitation link.';
      }
      return CustomerInviteCompletionResult(
        success: false,
        message: msg,
      );
    } catch (e) {
      debugPrint('[CLIENT_INVITE][ERROR] Exception during completion: $e');
      return CustomerInviteCompletionResult(
        success: false,
        message: 'Failed to verify invitation: $e',
      );
    }
  }

  /// Sets the customer's permanent Client Portal password (Phase 8).
  /// Updates Firebase Auth user directly; NEVER stores the password in Firestore or local storage.
  static Future<bool> setCustomerPassword(String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw 'No authenticated user session found.';
    }

    if (newPassword.length < 6) {
      throw 'Password must be at least 6 characters.';
    }

    await user.updatePassword(newPassword);
    await clearPendingInviteEmail();
    debugPrint('[CLIENT_INVITE][PASSWORD_SET] Password set successfully for UID: ${user.uid}');
    return true;
  }

  /// Toggles login enabled status for a customer in Firestore.
  static Future<bool> toggleCustomerLogin({
    required String phone,
    required bool enable,
  }) async {
    final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
    final normalizedPhone = cleanDigits.length >= 10
        ? cleanDigits.substring(cleanDigits.length - 10)
        : cleanDigits;

    try {
      await FirebaseFirestore.instance.collection('customers').doc(normalizedPhone).update({
        'login_enabled': enable,
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('[CLIENT_INVITE][LOGIN] Login toggled for $normalizedPhone: enabled=$enable');
      return true;
    } catch (e) {
      debugPrint('[CLIENT_INVITE][ERROR] Failed to toggle login: $e');
      return false;
    }
  }
}
