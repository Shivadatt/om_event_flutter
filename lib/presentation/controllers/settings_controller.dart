import 'package:get/get.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsController extends GetxController {
  final SettingsRepository repository = Get.find<SettingsRepository>();
  final isLoading = false.obs;

  Future<void> publishDocument(String docId) async {
    isLoading.value = true;
    try {
      await repository.publishSettings(docId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchHistory(String docId) async {
    return await repository.getVersionHistory(docId);
  }

  Future<void> rollback(String docId, int version) async {
    isLoading.value = true;
    try {
      await repository.rollbackToVersion(docId, version);
    } finally {
      isLoading.value = false;
    }
  }
}
