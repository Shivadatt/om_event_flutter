import '../../domain/entities/customer_profile.dart';

abstract class CustomerAuthRepository {
  Future<void> loginWithEmail(String email, String password);
  Future<void> registerWithEmail(String email, String password, String fullName);
  
  // Mobile OTP Auth
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String verificationId) codeSent,
    Function(String error) verificationFailed,
  );
  Future<void> signInWithSmsCode(String verificationId, String smsCode);
  
  // Google Auth
  Future<void> signInWithGoogle();
  
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getCurrentUserId();
  
  // Profile Management
  Future<CustomerProfile?> getCustomerProfile(String uid);
  Future<void> saveCustomerProfile(CustomerProfile profile, {bool isEdit = false});
}
