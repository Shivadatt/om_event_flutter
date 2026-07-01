import 'package:get/get.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/catalog_repository.dart';

/// Mixin containing Category management state and logic for AdminController.
mixin CategoryControllerMixin on GetxController {
  final rxCategories = <Category>[].obs;
  final isLoadingCategories = false.obs;
  final activeCategoriesCount = 0.obs;

  /// Loads all categories from the repository.
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      final catalogRepository = Get.find<CatalogRepository>();
      final list = await catalogRepository.getCategories();
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
}
