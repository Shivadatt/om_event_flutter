import 'package:get/get.dart';
import 'fcm/fcm_service.dart';

/// Legacy compat wrapper delegating directly to [FcmService].
class FcmNotificationService extends GetxService {
  static FcmNotificationService get to => Get.find<FcmNotificationService>();

  final rxToken = ''.obs;

  Future<void> initializeUserFcm(String userId, {String role = 'customer'}) async {
    await FcmService.to.initialize(userId: userId, role: role);
    rxToken.value = FcmService.to.rxToken.value;
  }

  Future<void> removeToken(String userId) async {
    await FcmService.to.cleanup(userId);
    rxToken.value = '';
  }
}
