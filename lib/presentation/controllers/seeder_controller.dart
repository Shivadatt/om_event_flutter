import 'package:get/get.dart';
import '../../data/datasources/seeder_service.dart';
import '../../data/datasources/database_migration_service.dart';

class SeederController extends GetxController {
  final SeederService _seederService = Get.find<SeederService>();
  final DatabaseMigrationService _migrationService = DatabaseMigrationService();

  final RxString statusMessage = 'Ready to migrate'.obs;
  final RxDouble progressPercent = 0.0.obs;
  final RxBool isMigrating = false.obs;
  final RxBool isCompleted = false.obs;
  final RxString errorMessage = ''.obs;

  /// Starts the Firebase and Supabase database seeding process.
  Future<void> runMigration({bool force = false}) async {
    if (isMigrating.value) return;

    isMigrating.value = true;
    errorMessage.value = '';
    progressPercent.value = 0.0;
    statusMessage.value = 'Initializing migration...';

    try {
      await _seederService.runMigration(
        force: force,
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

  Future<void> runSeedCategories() async {
    if (isMigrating.value) return;
    isMigrating.value = true;
    errorMessage.value = '';
    statusMessage.value = 'Seeding Categories...';
    try {
      await _migrationService.seedCategoriesOnly();
      statusMessage.value = 'Categories seeded successfully!';
      isCompleted.value = true;
    } catch (e) {
      errorMessage.value = e.toString();
      statusMessage.value = 'Seeding categories failed';
    } finally {
      isMigrating.value = false;
    }
  }

  Future<void> runSeedServices() async {
    if (isMigrating.value) return;
    isMigrating.value = true;
    errorMessage.value = '';
    statusMessage.value = 'Seeding Services...';
    try {
      await _migrationService.insertNewServices();
      statusMessage.value = 'Services seeded successfully!';
      isCompleted.value = true;
    } catch (e) {
      errorMessage.value = e.toString();
      statusMessage.value = 'Seeding services failed';
    } finally {
      isMigrating.value = false;
    }
  }

  Future<void> runFixRelationships() async {
    if (isMigrating.value) return;
    isMigrating.value = true;
    errorMessage.value = '';
    statusMessage.value = 'Fixing Relationships...';
    try {
      await _migrationService.correctDatabaseRelationships();
      statusMessage.value = 'Relationships corrected successfully!';
      isCompleted.value = true;
    } catch (e) {
      errorMessage.value = e.toString();
      statusMessage.value = 'Fixing relationships failed';
    } finally {
      isMigrating.value = false;
    }
  }

  Future<void> runFullMigrationManual() async {
    if (isMigrating.value) return;
    isMigrating.value = true;
    errorMessage.value = '';
    statusMessage.value = 'Running Full Migration...';
    try {
      await _migrationService.runFullMigration();
      statusMessage.value = 'Full migration completed successfully!';
      isCompleted.value = true;
    } catch (e) {
      errorMessage.value = e.toString();
      statusMessage.value = 'Full migration failed';
    } finally {
      isMigrating.value = false;
    }
  }
}
