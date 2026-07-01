import 'package:get/get.dart';
import '../../domain/entities/experience.dart';
import '../../domain/repositories/catalog_repository.dart';

/// Mixin containing Experience management state and logic for AdminController.
mixin ExperienceControllerMixin on GetxController {
  final rxExperiences = <Experience>[].obs;
  final isLoadingExperiences = false.obs;

  /// Loads all experiences from catalog repository.
  Future<void> loadExperiences() async {
    try {
      isLoadingExperiences.value = true;
      final catalogRepository = Get.find<CatalogRepository>();
      final list = await catalogRepository.getExperiences(activeOnly: false);
      rxExperiences.assignAll(list);
    } catch (e) {
      Get.snackbar("Experiences Error", e.toString());
    } finally {
      isLoadingExperiences.value = false;
    }
  }

  /// Saves an experience record.
  Future<void> saveExperience(
    Experience experience, {
    bool isEdit = false,
  }) async {
    try {
      isLoadingExperiences.value = true;
      final catalogRepository = Get.find<CatalogRepository>();
      if (isEdit) {
        await catalogRepository.updateExperience(experience);
      } else {
        await catalogRepository.createExperience(experience);
      }
      await loadExperiences();
      Get.snackbar("Experience Saved", "Experience saved successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingExperiences.value = false;
    }
  }

  /// Deletes an experience record by slug.
  Future<void> deleteExperience(String slug) async {
    try {
      isLoadingExperiences.value = true;
      final catalogRepository = Get.find<CatalogRepository>();
      await catalogRepository.deleteExperience(slug);
      await loadExperiences();
      Get.snackbar("Experience Deleted", "Experience removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingExperiences.value = false;
    }
  }
}
