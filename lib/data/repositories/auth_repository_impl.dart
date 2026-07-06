import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_storage_source.dart';
import 'mixins/auth_session_repository_mixin.dart';
import 'mixins/auth_user_repository_mixin.dart';
import 'mixins/auth_role_repository_mixin.dart';

/// Repository implementation for administrator authentication, users CRUD, and RBAC roles on Supabase.
class AuthRepositoryImpl
    with
        AuthSessionRepositoryMixin,
        AuthUserRepositoryMixin,
        AuthRoleRepositoryMixin
    implements AuthRepository {
  @override
  final FirebaseAuth firebaseAuth;
  @override
  final LocalStorageSource localStorage;

  /// Creates an [AuthRepositoryImpl] instance.
  AuthRepositoryImpl(this.firebaseAuth, this.localStorage);
}
