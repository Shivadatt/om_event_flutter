import 'package:get/get.dart';
import '../../data/datasources/seeder_service.dart';

class SeederController extends GetxController {
  final SeederService _seederService = Get.find<SeederService>();

  final RxString statusMessage = 'Ready to migrate'.obs;
  final RxDouble progressPercent = 0.0.obs;
  final RxBool isMigrating = false.obs;
  final RxBool isCompleted = false.obs;
  final RxString errorMessage = ''.obs;

  /// Starts the Firebase and Supabase database seeding process.
  Future<void> runMigration() async {
    if (isMigrating.value) return;

    isMigrating.value = true;
    errorMessage.value = '';
    progressPercent.value = 0.0;
    statusMessage.value = 'Initializing migration...';

    try {
      await _seederService.runMigration(
        onProgress: (status, progress) {
          if (progress == -1.0) {
            errorMessage.value = status;
            isMigrating.value = false;
          } else {
            statusMessage.value = status;
            progressPercent.value = progress;
            if (progress >= 1.0) {
              isCompleted.value = true;
              isMigrating.value = false;
            }
          }
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      statusMessage.value = 'Migration failed';
      isMigrating.value = false;
    }
  }
}
