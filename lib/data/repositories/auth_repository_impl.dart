import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_storage_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final LocalStorageSource _localStorage;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore, this._localStorage);

  @override
  Future<void> loginAdmin(String email, String password) async {
    try {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credentials.user;
      if (user == null) {
        throw const AuthenticationFailure("User authentication failed.");
      }

      // Query role from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // Create user record in firestore with default role if it doesn't exist
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? user.email?.split('@').first ?? 'Staff User',
          'email': user.email,
          'role': 'staff',
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
        });
      } else {
        final data = userDoc.data()!;
        final isActive = (data['is_active'] ?? data['isActive']) as bool? ?? true;
        if (!isActive) {
          await _firebaseAuth.signOut();
          throw const AuthenticationFailure("This staff account is deactivated.");
        }
      }

      // Fetch JWT ID token
      final token = await user.getIdToken();
      if (token != null) {
        await _localStorage.saveAdminToken(token);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw const AuthenticationFailure("Invalid email or password.");
      }
      throw AuthenticationFailure(e.message ?? "Authentication failed.");
    } catch (e) {
      throw AuthenticationFailure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _localStorage.clearAdminToken();
  }

  @override
  Future<String?> getCurrentUserToken() async {
    final cached = _localStorage.getAdminToken();
    if (cached != null) return cached;
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) {
        await _localStorage.saveAdminToken(token);
        return token;
      }
    }
    return null;
  }

  @override
  Future<String?> getCurrentUserRole() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
    } catch (_) {}
    return 'staff'; // Fallback
  }

  @override
  Future<bool> isLoggedIn() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<List<UserModel>> getUsers() async {
    final snap = await _firestore.collection('users').get();
    return snap.docs.map((doc) => UserModel.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}
