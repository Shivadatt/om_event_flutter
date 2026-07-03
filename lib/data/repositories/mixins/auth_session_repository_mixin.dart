import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';
import '../../datasources/local_storage_source.dart';

/// Mixin responsibility to handle admin logins, tokens, and active user sessions.
mixin AuthSessionRepositoryMixin {
  /// Firebase Auth dependency.
  FirebaseAuth get firebaseAuth;

  /// Firestore dependency.
  FirebaseFirestore get firestore;

  /// Local Storage caching source.
  LocalStorageSource get localStorage;

  /// Perform secure administrator login checks.
  Future<void> loginAdmin(String email, String password) async {
    try {
      final credentials = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credentials.user;
      if (user == null) {
        throw const AuthenticationFailure(AppStrings.errUserAuthFailed);
      }

      final token = await user.getIdToken();
      if (token == null) {
        throw const AuthenticationFailure('Failed to retrieve authentication token.');
      }

      // Fetch role from Supabase Edge Function
      final role = await _fetchRoleFromEdgeFunction(token);
      if (role == null) {
        await firebaseAuth.signOut();
        throw const AuthenticationFailure('User not registered in database.');
      }

      if (role == 'customer') {
        await firebaseAuth.signOut();
        throw const AuthenticationFailure('Access denied: User is not an administrator.');
      }

      await localStorage.saveUserRole(role);
      await localStorage.saveAdminToken(token);
    } on FirebaseAuthException catch (e) {
      if (e.code == AppStrings.firebaseUserNotFound ||
          e.code == AppStrings.firebaseWrongPassword ||
          e.code == AppStrings.firebaseInvalidCredential) {
        throw const AuthenticationFailure(AppStrings.errInvalidCredentials);
      }
      throw AuthenticationFailure(e.message ?? AppStrings.errAuthFailed);
    } catch (e) {
      if (e is AuthenticationFailure) rethrow;
      throw AuthenticationFailure(e.toString());
    }
  }

  /// Perform user logout and token revocation.
  Future<void> logout() async {
    await firebaseAuth.signOut();
    await localStorage.clearAdminToken();
    await localStorage.clearUserRole();
  }

  /// Retrieve current active session bearer JWT token.
  Future<String?> getCurrentUserToken() async {
    final cached = localStorage.getAdminToken();
    if (cached != null) return cached;
    final user = firebaseAuth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) {
        await localStorage.saveAdminToken(token);
        return token;
      }
    }
    return null;
  }

  /// Retrieve current active user profile security role type.
  Future<String?> getCurrentUserRole() async {
    final cached = localStorage.getUserRole();
    if (cached != null) return cached;

    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    try {
      final token = await user.getIdToken();
      if (token != null) {
        final role = await _fetchRoleFromEdgeFunction(token);
        if (role != null) {
          await localStorage.saveUserRole(role);
          return role;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Check whether an authenticated session exists.
  Future<bool> isLoggedIn() async {
    return firebaseAuth.currentUser != null;
  }

  /// Fetch user role from Supabase Edge Function verify-firebase-token.
  Future<String?> _fetchRoleFromEdgeFunction(String token) async {
    try {
      final response = await http.post(
        Uri.parse('https://kwegyvbgdaednljyhcgm.supabase.co/functions/v1/verify-firebase-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['user'] != null) {
          return data['user']['role'] as String?;
        }
      }
    } catch (e) {
      AppLogger.error('Failed to fetch role from Edge Function', e);
    }
    return null;
  }
}
