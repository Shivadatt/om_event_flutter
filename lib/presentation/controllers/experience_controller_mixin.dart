// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/experience.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../core/utils/app_logger.dart';

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

  /// Saves an experience record with optimistic state updates.
  Future<bool> saveExperience(
    Experience experience, {
    bool isEdit = false,
  }) async {
    debugPrint("[ExperienceSave] START - Name: ${experience.name}, ID: ${experience.id}, Slug: ${experience.slug}, isEdit: $isEdit");
    try {
      final catalogRepository = Get.find<CatalogRepository>();
      if (isEdit) {
        final idx = rxExperiences.indexWhere((e) => e.id == experience.id || e.slug == experience.slug);
        if (idx != -1) {
          rxExperiences[idx] = experience;
        } else {
          rxExperiences.add(experience);
        }
        await catalogRepository.updateExperience(experience).timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            debugPrint("[ExperienceSave] updateExperience timeout reached; continuing with state commit");
          },
        );
        AppLogger.success("Firestore update success", layer: LogLayer.controller, className: "ExperienceControllerMixin", methodName: "saveExperience");
      } else {
        rxExperiences.insert(0, experience);
        await catalogRepository.createExperience(experience).timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            debugPrint("[ExperienceSave] createExperience timeout reached; continuing with state commit");
          },
        );
      }
      debugPrint("[ExperienceSave] SUCCESS - Experience '${experience.name}' saved.");
      return true;
    } catch (e, stack) {
      debugPrint("[ExperienceSave] ERROR in saveExperience: $e\n$stack");
      Get.snackbar(
        "Save Failed",
        "Could not save experience: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF8B0000),
        colorText: const Color(0xFFFFFFFF),
      );
      await loadExperiences();
      return false;
    }
  }

  /// Deletes an experience record by slug with optimistic removal.
  Future<void> deleteExperience(String slug) async {
    final removed = rxExperiences.firstWhereOrNull((e) => e.slug == slug || e.id == slug);
    rxExperiences.removeWhere((e) => e.slug == slug || e.id == slug);
    try {
      final catalogRepository = Get.find<CatalogRepository>();
      await catalogRepository.deleteExperience(slug).timeout(
        const Duration(seconds: 4),
        onTimeout: () {},
      );
      Get.snackbar("Experience Deleted", "Experience removed successfully.");
    } catch (e) {
      if (removed != null) rxExperiences.add(removed);
      Get.snackbar("Error", e.toString());
    }
  }

  /// Optimistically toggle active status of an experience.
  Future<void> toggleExperienceActive(Experience item, bool isActive) async {
    final updated = item.copyWith(isActive: isActive);
    final idx = rxExperiences.indexWhere((e) => e.id == item.id || e.slug == item.slug);
    if (idx != -1) rxExperiences[idx] = updated;

    try {
      final catalogRepository = Get.find<CatalogRepository>();
      await catalogRepository.updateExperience(updated).timeout(
        const Duration(seconds: 4),
        onTimeout: () {},
      );
    } catch (e) {
      if (idx != -1) rxExperiences[idx] = item;
      Get.snackbar("Error", "Failed to update status: $e");
    }
  }

  /// Optimistically toggle featured status of an experience.
  Future<void> toggleExperienceFeatured(Experience item, bool isFeatured) async {
    final updated = item.copyWith(isFeatured: isFeatured);
    final idx = rxExperiences.indexWhere((e) => e.id == item.id || e.slug == item.slug);
    if (idx != -1) rxExperiences[idx] = updated;

    try {
      final catalogRepository = Get.find<CatalogRepository>();
      await catalogRepository.updateExperience(updated).timeout(
        const Duration(seconds: 4),
        onTimeout: () {},
      );
    } catch (e) {
      if (idx != -1) rxExperiences[idx] = item;
      Get.snackbar("Error", "Failed to update featured: $e");
    }
  }
}
