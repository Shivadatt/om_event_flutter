import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';
import '../../domain/entities/customer_profile.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../models/customer_profile_model.dart';

class CustomerAuthRepositoryImpl implements CustomerAuthRepository {
  final FirebaseAuth _auth;
  final SupabaseClient _client = Supabase.instance.client;

  CustomerAuthRepositoryImpl(this._auth);

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
    final data = await _client
        .from('customer_profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (data != null) {
      return CustomerProfileModel.fromJson(SupabaseMapper.toCamelCase(data), uid);
    }
    return null;
  }

  @override
  Future<void> saveCustomerProfile(CustomerProfile profile, {bool isEdit = false}) async {
    final model = CustomerProfileModel(
      id: profile.id,
      fullName: profile.fullName,
      phone: profile.phone,
      email: profile.email,
      gender: profile.gender,
      address: profile.address,
      city: profile.city,
      state: profile.state,
      pincode: profile.pincode,
      branch: profile.branch,
      profileImageUrl: profile.profileImageUrl,
      createdAt: profile.createdAt,
      lastLogin: profile.lastLogin,
    );
    final payload = SupabaseMapper.toSnakeCase(model.toJson());
    await _client.from('customer_profiles').upsert({
      'id': profile.id,
      ...payload,
    });
  }
}
