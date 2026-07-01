import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_collections.dart';
import '../../../core/constants/app_permissions.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/failures.dart';
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

      var adminRoleDoc =
          await firestore.collection(AppCollections.admin).doc(user.uid).get();

      if (!adminRoleDoc.exists) {
        final emailLower = user.email?.toLowerCase().trim() ?? '';
        final isSuper = emailLower == AppStrings.businessEmail;
        final isDemo = emailLower == AppStrings.demoAdminEmail;
        final roleType =
            isSuper
                ? AppRoles.superAdmin
                : (isDemo ? AppRoles.demoAdmin : AppRoles.customer);

        final Map<String, bool> permissions =
            isSuper
                ? AppPermissions.superAdminPermissions
                : (isDemo
                    ? AppPermissions.demoAdminPermissions
                    : AppPermissions.customerPermissions);

        await firestore.collection(AppCollections.admin).doc(user.uid).set({
          AppStrings.fieldUid: user.uid,
          AppStrings.fieldName:
              isSuper
                  ? AppStrings.superAdminName
                  : (isDemo
                      ? AppStrings.demoAdminName
                      : (user.displayName ??
                          user.email?.split('@').first ??
                          'Customer')),
          AppStrings.fieldEmail: user.email,
          AppStrings.fieldRole: roleType,
          AppStrings.fieldRoleType: roleType,
          AppStrings.fieldIsActive: true,
          AppStrings.fieldCreatedAt: DateTime.now().toIso8601String(),
          AppStrings.fieldUpdatedAt: DateTime.now().toIso8601String(),
          AppStrings.fieldCreatedBy: AppStrings.createdBySystem,
          AppStrings.fieldPermissions: permissions,
        });
        adminRoleDoc =
            await firestore
                .collection(AppCollections.admin)
                .doc(user.uid)
                .get();
      }

      final data = adminRoleDoc.data()!;
      final roleType =
          data[AppStrings.fieldRoleType] ??
          data[AppStrings.fieldRole] ??
          AppRoles.customer;
      if (roleType == AppRoles.customer) {
        await firebaseAuth.signOut();
        throw const AuthenticationFailure(AppStrings.errAdminNotFound);
      }

      final isActive =
          (data[AppStrings.fieldIsActive] ?? data[AppStrings.fieldIsActiveAlt])
              as bool? ??
          true;
      if (!isActive) {
        await firebaseAuth.signOut();
        throw const AuthenticationFailure(AppStrings.errAccountDisabled);
      }

      final token = await user.getIdToken();
      if (token != null) {
        await localStorage.saveAdminToken(token);
      }
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
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      final doc =
          await firestore.collection(AppCollections.admin).doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?[AppStrings.fieldRoleType] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Check whether an authenticated session exists.
  Future<bool> isLoggedIn() async {
    return firebaseAuth.currentUser != null;
  }
}
