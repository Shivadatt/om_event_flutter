import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/constants/app_roles.dart';
import '../../core/utils/app_logger.dart';
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
    try {
      // 1. Guard: Check if UID belongs to an administrator or staff - Never treat as customer profile
      final adminDoc = await _firestore.collection(AppCollections.admin).doc(uid).get();
      if (adminDoc.exists && adminDoc.data() != null) {
        final data = adminDoc.data()!;
        final role = (data['roleType'] ?? data['role'] ?? '').toString().toLowerCase();
        if (AppRoles.isAdminRole(role)) {
          return null;
        }
      }

      CustomerProfileModel? profile;
      final doc = await _firestore.collection(AppCollections.customerProfiles).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        profile = CustomerProfileModel.fromJson(doc.data()!, doc.id);
      }

      // Check users collection fallback if profile is null
      if (profile == null) {
        try {
          final userDoc = await _firestore.collection(AppCollections.users).doc(uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            final userData = userDoc.data()!;
            final role = (userData['role'] ?? '').toString().toLowerCase();
            if (AppRoles.isAdminRole(role)) {
              return null; // Users collection lists this user as admin/staff
            }
            profile = CustomerProfileModel(
              id: uid,
              fullName: userData['name'] ?? userData['fullName'] ?? 'Valued Client',
              phone: userData['phone'] ?? '',
              email: userData['email'] ?? '',
              gender: userData['gender'] ?? '',
              address: userData['address'] ?? '',
              city: userData['city'] ?? 'Ahmedabad',
              state: userData['state'] ?? 'Gujarat',
              pincode: userData['pincode'] ?? '',
              branch: userData['branch'] ?? '',
              profileImageUrl: userData['profileImageUrl'] ?? userData['photoUrl'] ?? '',
              createdAt: DateTime.now(),
              lastLogin: DateTime.now(),
            );
          }
        } catch (_) {}
      }

      // Reconstruct or enrich from master customers collection
      try {
        final currentUser = _auth.currentUser;
        final targetEmail = (profile?.email.isNotEmpty == true) ? profile!.email : (currentUser?.email ?? '');
        final targetPhone = (profile?.phone.isNotEmpty == true) ? profile!.phone : (currentUser?.phoneNumber ?? '');

        DocumentSnapshot<Map<String, dynamic>>? custDoc;

        // A. Search by linked auth_uid first
        try {
          final linkedSnap = await _firestore
              .collection(AppCollections.customers)
              .where('auth_uid', isEqualTo: uid)
              .limit(1)
              .get();
          if (linkedSnap.docs.isNotEmpty) {
            custDoc = linkedSnap.docs.first;
          }
        } catch (_) {}

        // B. Search by phone
        if (custDoc == null && targetPhone.isNotEmpty) {
          final cleanDigits = targetPhone.replaceAll(RegExp(r'\D'), '');
          final tenDigit = cleanDigits.length >= 10 ? cleanDigits.substring(cleanDigits.length - 10) : cleanDigits;
          final d1 = await _firestore.collection(AppCollections.customers).doc(tenDigit).get();
          if (d1.exists && d1.data() != null) {
            custDoc = d1;
          } else {
            final d2 = await _firestore.collection(AppCollections.customers).doc(targetPhone).get();
            if (d2.exists && d2.data() != null) custDoc = d2;
          }
        }

        // C. If not found by phone, search by email
        if ((custDoc == null || !custDoc.exists) && targetEmail.isNotEmpty) {
          final snap = await _firestore
              .collection(AppCollections.customers)
              .where('email', isEqualTo: targetEmail)
              .limit(1)
              .get();
          if (snap.docs.isNotEmpty) {
            custDoc = snap.docs.first;
          }
        }

        if (custDoc != null && custDoc.exists && custDoc.data() != null) {
          // Link auth_uid to customer document if needed
          final currentAuthUid = custDoc.data()?['auth_uid'];
          if (currentAuthUid == null || currentAuthUid != uid) {
            custDoc.reference.set({
              'auth_uid': uid,
              'login_enabled': true,
            }, SetOptions(merge: true)).catchError((_) {});
          }

          final cData = custDoc.data()!;
          final cName = cData['name'] ?? cData['full_name'] ?? '';
          final cPhone = cData['phone'] ?? '';
          final cEmail = cData['email'] ?? '';
          final cAddr = cData['address'] ?? '';
          final cCity = cData['city'] ?? '';
          final cState = cData['state'] ?? '';
          final cPin = cData['pincode'] ?? '';
          final cBranch = cData['branch'] ?? '';
          final cGender = cData['gender'] ?? '';
          final cDobRaw = cData['date_of_birth'] ?? cData['dateOfBirth'];
          DateTime? cDob;
          if (cDobRaw is Timestamp) {
            cDob = cDobRaw.toDate();
          } else if (cDobRaw is String && cDobRaw.isNotEmpty) {
            cDob = DateTime.tryParse(cDobRaw);
          }
          final cImg = cData['profile_image_url'] ?? cData['profileImageUrl'] ?? cData['photoUrl'] ?? '';

          if (profile != null) {
            // Enrich missing fields
            profile = CustomerProfileModel(
              id: profile.id,
              fullName: profile.fullName.isNotEmpty ? profile.fullName : cName,
              phone: profile.phone.isNotEmpty ? profile.phone : cPhone,
              email: profile.email.isNotEmpty ? profile.email : cEmail,
              gender: profile.gender.isNotEmpty ? profile.gender : cGender,
              dateOfBirth: profile.dateOfBirth ?? cDob,
              address: profile.address.isNotEmpty ? profile.address : cAddr,
              city: profile.city.isNotEmpty ? profile.city : (cCity.isNotEmpty ? cCity : 'Ahmedabad'),
              state: profile.state.isNotEmpty ? profile.state : (cState.isNotEmpty ? cState : 'Gujarat'),
              pincode: profile.pincode.isNotEmpty ? profile.pincode : cPin,
              branch: profile.branch.isNotEmpty ? profile.branch : cBranch,
              profileImageUrl: profile.profileImageUrl.isNotEmpty ? profile.profileImageUrl : cImg,
              createdAt: profile.createdAt,
              lastLogin: profile.lastLogin,
            );
          } else {
            // Build profile from customers document
            final currentUser = _auth.currentUser;
            profile = CustomerProfileModel(
              id: uid,
              fullName: cName.isNotEmpty ? cName : (currentUser?.displayName ?? 'Valued Client'),
              phone: cPhone.isNotEmpty ? cPhone : (currentUser?.phoneNumber ?? ''),
              email: cEmail.isNotEmpty ? cEmail : (currentUser?.email ?? ''),
              gender: cGender,
              dateOfBirth: cDob,
              address: cAddr,
              city: cCity.isNotEmpty ? cCity : 'Ahmedabad',
              state: cState.isNotEmpty ? cState : 'Gujarat',
              pincode: cPin,
              branch: cBranch,
              profileImageUrl: cImg.isNotEmpty ? cImg : (currentUser?.photoURL ?? ''),
              createdAt: DateTime.now(),
              lastLogin: DateTime.now(),
            );
          }
        }
      } catch (e) {
        AppLogger.warning("Enrichment from customers collection error: $e");
      }

      if (profile != null) {
        return profile;
      }

      // Check current Firebase Auth user fallback only for verified non-admin users
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        final emailLower = currentUser.email?.toLowerCase().trim() ?? '';
        // If email indicates admin account, do not create customer profile
        if (emailLower == 'omeventsanddecorators@gmail.com' ||
            emailLower == 'demo@omevents.com' ||
            emailLower.contains('admin@')) {
          return null;
        }

        final displayName = currentUser.displayName?.trim();
        final emailPrefix = currentUser.email?.split('@').first;
        final name = (displayName != null && displayName.isNotEmpty)
            ? displayName
            : (emailPrefix != null && emailPrefix.isNotEmpty ? emailPrefix : 'Valued Client');

        final fallbackProfile = CustomerProfileModel(
          id: uid,
          fullName: name,
          phone: currentUser.phoneNumber ?? '',
          email: currentUser.email ?? '',
          gender: '',
          address: '',
          city: 'Ahmedabad',
          state: 'Gujarat',
          pincode: '',
          branch: '',
          profileImageUrl: currentUser.photoURL ?? '',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        await saveCustomerProfile(fallbackProfile).catchError((_) {});
        return fallbackProfile;
      }

      return null;
    } catch (e) {
      AppLogger.warning("Failed to fetch customer profile for $uid: $e");
      return null;
    }
  }

  @override
  Future<void> saveCustomerProfile(CustomerProfile profile, {bool isEdit = false}) async {
    AppLogger.info("PROFILE_SAVE_STARTED: Initiating atomic dual profile save for ${profile.id}", layer: LogLayer.repository, className: "CustomerAuthRepositoryImpl", methodName: "saveCustomerProfile");
    final model = profile as CustomerProfileModel;
    final profileJson = model.toJson();

    final phoneDigits = profile.phone.replaceAll(RegExp(r'\D'), '');
    final tenDigit = phoneDigits.length >= 10
        ? phoneDigits.substring(phoneDigits.length - 10)
        : phoneDigits;
    final targetPhoneKey = tenDigit.isNotEmpty ? tenDigit : profile.phone.trim();

    // Canonical customer document fields for customers collection
    final Map<String, dynamic> customerDocData = {
      'name': profile.fullName.trim(),
      'full_name': profile.fullName.trim(),
      'phone': profile.phone.trim(),
      if (profile.email.trim().isNotEmpty) 'email': profile.email.trim(),
      'address': profile.address.trim(),
      'city': profile.city.trim(),
      'state': profile.state.trim(),
      'pincode': profile.pincode.trim(),
      'branch': profile.branch.trim(),
      'gender': profile.gender.trim(),
      if (profile.dateOfBirth != null) 'date_of_birth': profile.dateOfBirth!.toIso8601String(),
      'profile_image_url': profile.profileImageUrl.trim(),
      'profileImageUrl': profile.profileImageUrl.trim(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    // Use WriteBatch for atomic logical synchronization between customer_profiles and customers
    final batch = _firestore.batch();

    // 1. Queue write to customer_profiles/{profile.id}
    final profileDocRef = _firestore.collection(AppCollections.customerProfiles).doc(profile.id);
    batch.set(
      profileDocRef,
      {
        ...profileJson,
        'updated_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 2. Queue write to canonical customers collection
    if (targetPhoneKey.isNotEmpty) {
      final customerDocRef = _firestore.collection(AppCollections.customers).doc(targetPhoneKey);
      batch.set(customerDocRef, customerDocData, SetOptions(merge: true));
    } else {
      final fallbackRef = _firestore.collection(AppCollections.customers).doc(profile.id);
      batch.set(fallbackRef, customerDocData, SetOptions(merge: true));
    }

    // 3. Atomically commit both operations
    // If either write fails, the entire batch fails and an exception is raised
    try {
      await batch.commit();
      AppLogger.info("PROFILE_FIREBASE_UPDATE_SUCCESS: Dual persistence succeeded for customer_profiles/${profile.id} and customers/${targetPhoneKey.isNotEmpty ? targetPhoneKey : profile.id}", layer: LogLayer.repository, className: "CustomerAuthRepositoryImpl", methodName: "saveCustomerProfile");
    } catch (e) {
      AppLogger.errorDetailed("PROFILE_SAVE_FAILED: Batch commit failed for customer profile synchronization", layer: LogLayer.repository, className: "CustomerAuthRepositoryImpl", methodName: "saveCustomerProfile", error: e);
      rethrow; // Crucial: surface error so UI does not display false success
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
