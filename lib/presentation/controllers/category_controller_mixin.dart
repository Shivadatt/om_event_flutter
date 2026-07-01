import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/catalog_repository.dart';

/// Mixin containing Category management state and logic for AdminController.
mixin CategoryControllerMixin on GetxController {
  final rxCategories = <Category>[].obs;
  final isLoadingCategories = false.obs;
  final activeCategoriesCount = 0.obs;

  /// Loads ALL categories from the repository (active + inactive).
  /// The Admin Panel must see every category regardless of visibility status.
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      final catalogRepository = Get.find<CatalogRepository>();
      final list = await catalogRepository.getAllCategories();
      rxCategories.assignAll(list);
      activeCategoriesCount.value = list.where((c) => c.isActive).length;
    } catch (e) {
      Get.snackbar("Categories Error", e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Saves a category record.
  Future<void> saveCategory(Category category, {bool isEdit = false}) async {
    try {
      isLoadingCategories.value = true;
      final catalogRepository = Get.find<CatalogRepository>();
      if (isEdit) {
        await catalogRepository.updateCategory(category);
      } else {
        await catalogRepository.createCategory(category);
      }
      await loadCategories();
      Get.snackbar("Category Saved", "Category saved successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Deletes a category by its slug.
  Future<void> deleteCategory(String slug) async {
    try {
      isLoadingCategories.value = true;
      final catalogRepository = Get.find<CatalogRepository>();
      await catalogRepository.deleteCategory(slug);
      await loadCategories();
      Get.snackbar("Category Deleted", "Category removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Toggle [is_active] status of a category.
  ///
  /// Deactivating → shows a confirmation dialog first.
  /// Activating → patches Firestore immediately and shows a success snackbar.
  Future<void> toggleCategoryStatus(
    String slug, {
    required bool isActive,
  }) async {
    if (!isActive) {
      // Deactivating – confirm before committing
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text(
            "Hide Category?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "This category and all its related experiences will no longer "
            "be visible to customers.\n\nNo data will be deleted — you can "
            "re-activate it at any time.",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Get.back(result: false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Hide Category"),
              onPressed: () => Get.back(result: true),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    try {
      isLoadingCategories.value = true;
      final catalogRepository = Get.find<CatalogRepository>();
      await catalogRepository.toggleCategoryStatus(slug, isActive: isActive);
      await loadCategories();

      if (isActive) {
        Get.snackbar(
          "Category Published",
          "Category is now visible to customers.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Category Hidden",
          "Category is now hidden from customers.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }
}
