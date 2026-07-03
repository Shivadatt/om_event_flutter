import 'package:get/get.dart';

/// Legacy compat handler. Listeners migrated to clean architecture [NotificationHandler].
class NotificationHandlerService extends GetxService {
  static NotificationHandlerService get to => Get.find<NotificationHandlerService>();
  // Consolidated under NotificationHandler.
}
