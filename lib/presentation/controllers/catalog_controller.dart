// ignore_for_file: avoid_print
import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_collections.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/lead.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_experiences.dart';
import '../../domain/usecases/submit_lead.dart';
import '../../data/datasources/database_migration_service.dart';
import 'customer_auth_controller.dart';

part 'parts/catalog_filter.dart';
part 'parts/catalog_lead.dart';

/// Customer-facing catalog controller backed by Firestore realtime streams.
class CatalogController extends GetxController {
  final GetCategories getCategories;
  final GetExperiences getExperiences;
  final SubmitLead submitLead;

  CatalogController({
    required this.getCategories,
    required this.getExperiences,
    required this.submitLead,
  });

  // ── Public Rx state ────────────────────────────────────────────────────────
  final rxCategories = <Category>[].obs;
  final rxExperiences = <Experience>[].obs;
  final rxReviews = <Review>[].obs;

  final isLoadingCategories = false.obs;
  final isLoadingExperiences = false.obs;
  final isSubmittingLead = false.obs;

  // Search & Filter state
  final selectedCategorySlug = ''.obs;
  final searchQuery = ''.obs;
  final sortBy = 'popular'.obs;
  final rxVisibleCount = 6.obs;

  // Raw unfiltered list of all active experiences from Firestore.
  final List<Experience> _allActiveExperiences = <Experience>[];

  void loadMore() {
    rxVisibleCount.value += 6;
  }

  void resetVisibleCount() {
    rxVisibleCount.value = 6;
  }

  /// Active Firestore stream subscriptions — cancelled in [onClose].
  StreamSubscription<List<Category>>? _categoriesSub;
  StreamSubscription<List<Experience>>? _experiencesSub;
  StreamSubscription<List<Review>>? _reviewsSub;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _checkAndRunMigration();
    _bindRealtimeStreams();

    // Re-apply experience filters whenever user changes any filter param.
    ever(selectedCategorySlug, (_) => applyExperienceFilters());
    ever(sortBy, (_) => applyExperienceFilters());

    // Re-apply when categories change (cascade: hide experiences of inactive category).
    ever(rxCategories, (_) => applyExperienceFilters());

    // Debounce keystroke-level search so we don't re-filter on every character.
    debounce(
      searchQuery,
      (_) => applyExperienceFilters(),
      time: const Duration(milliseconds: 400),
    );
  }

  @override
  void onClose() {
    _categoriesSub?.cancel();
    _experiencesSub?.cancel();
    _reviewsSub?.cancel();
    super.onClose();
  }

  // ── Realtime stream binding ────────────────────────────────────────────────
  void _bindRealtimeStreams() {
    final repo = Get.find<CatalogRepository>();

    // 1. Categories
    isLoadingCategories.value = true;
    _categoriesSub = repo.streamCategories().listen(
      (cats) {
        rxCategories.assignAll(cats);
        isLoadingCategories.value = false;
      },
      onError: (_) {
        isLoadingCategories.value = false;
      },
    );

    // 2. Experiences
    isLoadingExperiences.value = true;
    _experiencesSub = repo.streamAllActiveExperiences().listen(
      (experiences) {
        _allActiveExperiences
          ..clear()
          ..addAll(experiences);
        applyExperienceFilters();
        isLoadingExperiences.value = false;
      },
      onError: (_) {
        isLoadingExperiences.value = false;
      },
    );

    // 3. Reviews
    _reviewsSub = repo.streamPublishedReviews().listen(
      (reviews) => rxReviews.assignAll(reviews),
      onError: (_) {},
    );
  }

  // ── Public API (UI compatibility) ──────────────────────────────────────────
  Future<void> refreshCatalog() async {
    _categoriesSub?.cancel();
    _experiencesSub?.cancel();
    _reviewsSub?.cancel();
    _bindRealtimeStreams();
  }

  /// Kept for backward compatibility — streams handle this automatically.
  Future<void> loadCategories() async {}

  /// Kept for backward compatibility
  Future<void> loadExperiences() async {
    applyExperienceFilters();
  }

  void selectCategory(String slug) {
    // Toggle: tap the same category again to deselect
    selectedCategorySlug.value = selectedCategorySlug.value == slug ? '' : slug;
    resetVisibleCount();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    resetVisibleCount();
    applyExperienceFilters();
  }

  void updateSort(String option) {
    sortBy.value = option;
  }

  Future<bool> requestCallback({
    required String name,
    required String phone,
    required String dateStr,
    required String budgetStr,
    required String requirements,
  }) async {
    return handleRequestCallback(
      name: name,
      phone: phone,
      dateStr: dateStr,
      budgetStr: budgetStr,
      requirements: requirements,
    );
  }

  Future<void> _checkAndRunMigration() async {
    try {
      final migrationService = DatabaseMigrationService();
      // Execute mandatory customerId migration on startup to reconcile legacy quotation documents
      await migrationService.migrateQuotationsCustomerId();

      final isDone = await migrationService.isMigrationCompleted();
      if (!isDone) {
        print("DATABASE NOT SEEDED. Please run migration from Admin Seeder Screen.");
      } else {
        print("DATABASE MIGRATION: Already completed. Skipping startup migration.");
      }
    } catch (e) {
      print("Startup migration check error: $e");
    }
  }
}
