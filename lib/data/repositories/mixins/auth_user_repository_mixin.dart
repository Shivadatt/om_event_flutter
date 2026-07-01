import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

/// Mixin responsibility to handle standard user records CRUD.
mixin AuthUserRepositoryMixin {
  /// Firestore database source.
  FirebaseFirestore get firestore;

  /// Retrieve all registered mobile app users.
  Future<List<UserModel>> getUsers() async {
    final snap = await firestore.collection('users').get();
    return snap.docs
        .map((doc) => UserModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Create a new mobile user account index.
  Future<void> createUser(UserModel user) async {
    await firestore.collection('users').doc(user.id).set(user.toJson());
  }

  /// Update existing details for a user.
  Future<void> updateUser(UserModel user) async {
    await firestore.collection('users').doc(user.id).update(user.toJson());
  }

  /// Delete a user record.
  Future<void> deleteUser(String uid) async {
    await firestore.collection('users').doc(uid).delete();
  }
}
