import 'package:get/get.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/admin_repository.dart';

/// Mixin containing Review management state and logic for AdminController.
mixin ReviewControllerMixin on GetxController {
  final rxReviews = <ReviewModel>[].obs;
  final isLoadingReviews = false.obs;

  final totalReviewsCount = 0.obs;
  final pendingReviewsCount = 0.obs;
  final approvedReviewsCount = 0.obs;
  final averageReviewsRating = 0.0.obs;

  /// Loads all review records.
  Future<void> loadReviews() async {
    try {
      isLoadingReviews.value = true;
      final adminRepo = Get.find<AdminRepository>();
      final list = await adminRepo.getReviews();
      rxReviews.assignAll(list);

      // Recalculate review metrics
      totalReviewsCount.value = list.length;
      pendingReviewsCount.value = list.where((r) => !r.isPublished).length;
      approvedReviewsCount.value = list.where((r) => r.isPublished).length;
      if (list.isNotEmpty) {
        final sum = list.fold<int>(0, (prev, element) => prev + element.rating);
        averageReviewsRating.value = sum / list.length;
      } else {
        averageReviewsRating.value = 5.0;
      }
    } catch (e) {
      Get.snackbar("Reviews Error", e.toString());
    } finally {
      isLoadingReviews.value = false;
    }
  }

  /// Saves a review record.
  Future<void> saveReview(ReviewModel review, {required bool isEdit}) async {
    try {
      isLoadingReviews.value = true;
      final adminRepo = Get.find<AdminRepository>();
      await adminRepo.saveReview(review, isEdit: isEdit);
      await loadReviews();
      Get.snackbar(
        "Review Saved",
        "Review configuration updated successfully.",
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingReviews.value = false;
    }
  }

  /// Deletes a review record by ID.
  Future<void> deleteReview(String id) async {
    try {
      isLoadingReviews.value = true;
      final adminRepo = Get.find<AdminRepository>();
      await adminRepo.deleteReview(id);
      await loadReviews();
      Get.snackbar("Review Deleted", "Review removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingReviews.value = false;
    }
  }
}
