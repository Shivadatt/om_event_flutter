import 'package:get/get.dart';
import 'fcm/notification_token_service.dart';

/// Legacy compat wrapper delegating directly to [NotificationTokenService].
class TokenService extends GetxService {
  static TokenService get to => Get.find<TokenService>();

  Future<void> saveToken({
    required String userId,
    required String role,
    required String token,
  }) async {
    await NotificationTokenService.to.persistToken(
      userId: userId,
      role: role,
      token: token,
    );
  }

  Future<void> removeToken({
    required String userId,
  }) async {
    await NotificationTokenService.to.removeToken(userId: userId);
  }
}
