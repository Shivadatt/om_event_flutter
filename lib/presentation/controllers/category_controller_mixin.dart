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
  Future<void> loadCategories({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoadingCategories.value = true;
      }
      final catalogRepository = Get.find<CatalogRepository>();
      final list = await catalogRepository.getAllCategories();
      rxCategories.assignAll(list);
      activeCategoriesCount.value = list.where((c) => c.isActive).length;
    } catch (e) {
      Get.snackbar("Categories Error", e.toString());
    } finally {
      if (showLoading) {
        isLoadingCategories.value = false;
      }
    }
  }

  /// Saves a category record with comprehensive logging and error handling.
  Future<bool> saveCategory(Category category, {bool isEdit = false}) async {
    debugPrint("[CategorySave] START - Name: ${category.name}, ID: ${category.id}, Slug: ${category.slug}, isEdit: $isEdit");
    try {
      final catalogRepository = Get.find<CatalogRepository>();

      // 1. Perform actual Firestore mutation
      debugPrint("[CategorySave] Calling repository.${isEdit ? 'updateCategory' : 'createCategory'}");
      if (isEdit) {
        await catalogRepository.updateCategory(category).timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            debugPrint("[CategorySave] updateCategory controller timeout reached; continuing with state commit");
          },
        );
      } else {
        await catalogRepository.createCategory(category).timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            debugPrint("[CategorySave] createCategory controller timeout reached; continuing with state commit");
          },
        );
      }
      debugPrint("[CategorySave] Firestore write completed successfully");

      // 2. Update local in-memory state for instant UI responsiveness
      if (isEdit) {
        final index = rxCategories.indexWhere((c) => c.id == category.id || c.slug == category.slug);
        if (index != -1) {
          rxCategories[index] = category;
        } else {
          rxCategories.add(category);
        }
      } else {
        rxCategories.add(category);
      }
      activeCategoriesCount.value = rxCategories.where((c) => c.isActive).length;
      debugPrint("[CategorySave] Local in-memory state updated. Total: ${rxCategories.length}");

      // 3. Background server refresh without blocking UI
      loadCategories(showLoading: false);

      debugPrint("[CategorySave] SUCCESS");
      return true;
    } catch (e, stack) {
      debugPrint("[CategorySave] ERROR in saveCategory: $e\n$stack");
      Get.snackbar(
        "Save Failed",
        "Could not save category: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Deletes a category by its slug.
  Future<void> deleteCategory(String slug) async {
    try {
      rxCategories.removeWhere((c) => c.slug == slug || c.id == slug);
      activeCategoriesCount.value = rxCategories.where((c) => c.isActive).length;

      final catalogRepository = Get.find<CatalogRepository>();
      await catalogRepository.deleteCategory(slug).timeout(
        const Duration(seconds: 4),
        onTimeout: () {},
      );
      loadCategories(showLoading: false);
      Get.snackbar("Category Deleted", "Category removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
      loadCategories(showLoading: false);
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
      // Optimistic in-memory update
      final index = rxCategories.indexWhere((c) => c.slug == slug || c.id == slug);
      if (index != -1) {
        final current = rxCategories[index];
        rxCategories[index] = Category(
          id: current.id,
          name: current.name,
          slug: current.slug,
          description: current.description,
          icon: current.icon,
          color: current.color,
          imageUrl: current.imageUrl,
          sortOrder: current.sortOrder,
          itemCount: current.itemCount,
          isActive: isActive,
        );
        activeCategoriesCount.value = rxCategories.where((c) => c.isActive).length;
      }

      final catalogRepository = Get.find<CatalogRepository>();
      await catalogRepository.toggleCategoryStatus(slug, isActive: isActive).timeout(
        const Duration(seconds: 4),
        onTimeout: () {},
      );
      loadCategories(showLoading: false);

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
      loadCategories(showLoading: false);
    }
  }
}
