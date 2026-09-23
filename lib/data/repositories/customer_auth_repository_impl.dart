import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../domain/entities/customer_profile.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../models/customer_profile_model.dart';

class CustomerAuthRepositoryImpl implements CustomerAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CustomerAuthRepositoryImpl(this._auth, this._firestore);

  @override
  Future<void> loginWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> registerWithEmail(String email, String password, String fullName) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (cred.user != null) {
      final profile = CustomerProfileModel(
        id: cred.user!.uid,
        fullName: fullName,
        phone: '',
        email: email,
        gender: '',
        address: '',
        city: '',
        state: '',
        pincode: '',
        branch: '',
        profileImageUrl: '',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await saveCustomerProfile(profile);
    }
  }

  @override
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String verificationId) codeSent,
    Function(String error) verificationFailed,
  ) async {
    // Basic Web implementation using ConfirmationResult
    // Note: In a full app, this requires reCAPTCHA setup
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Future<void> signInWithSmsCode(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> signInWithGoogle() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();
    await _auth.signInWithPopup(googleProvider);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  @override
  Future<CustomerProfile?> getCustomerProfile(String uid) async {
    final doc = await _firestore.collection(AppCollections.customerProfiles).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return CustomerProfileModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> saveCustomerProfile(CustomerProfile profile, {bool isEdit = false}) async {
    final model = profile as CustomerProfileModel;
    if (isEdit) {
      await _firestore.collection(AppCollections.customerProfiles).doc(profile.id).update(model.toJson());
    } else {
      await _firestore.collection(AppCollections.customerProfiles).doc(profile.id).set(model.toJson());
    }
  }

  @override
  Future<CustomerProfile> ensureGuestSession({
    required String name,
    required String phone,
    String? email,
  }) async {
    String uid = '';
    final existingUser = _auth.currentUser;

    if (existingUser != null) {
      uid = existingUser.uid;
    } else {
      try {
        final cred = await _auth.signInAnonymously();
        uid = cred.user?.uid ?? '';
      } catch (_) {
        // Fallback if anonymous auth is disabled on Firebase project
        final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
        uid = 'guest_${DateTime.now().millisecondsSinceEpoch}_$cleanDigits';
      }
    }

    if (uid.isEmpty) {
      uid = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Check if profile exists
    CustomerProfile? profile;
    try {
      profile = await getCustomerProfile(uid);
    } catch (_) {}

    if (profile == null) {
      final newProfile = CustomerProfileModel(
        id: uid,
        fullName: name.trim(),
        phone: phone.trim(),
        email: email?.trim() ?? '',
        gender: '',
        address: '',
        city: 'Ahmedabad',
        state: 'Gujarat',
        pincode: '',
        branch: '',
        profileImageUrl: '',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      try {
        await saveCustomerProfile(newProfile);
      } catch (_) {
        // Best-effort profile save
      }
      return newProfile;
    }

    return profile;
  }
}
