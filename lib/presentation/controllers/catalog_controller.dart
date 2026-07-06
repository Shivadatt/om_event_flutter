import 'dart:async';
import 'package:get/get.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/lead.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_experiences.dart';
import '../../domain/usecases/submit_lead.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'customer_auth_controller.dart';
/// Customer-facing catalog controller backed by Firestore realtime streams.
///
/// Architecture:
/// - Categories  → direct Firestore snapshot stream via [CatalogRepository.streamCategories]
/// - Experiences → snapshot stream of ALL active items; filters (category,
///                 search, sort) applied in-memory via [_applyExperienceFilters]
/// - Reviews     → direct Firestore snapshot stream via [CatalogRepository.streamPublishedReviews]
///
/// Any Firestore write (admin toggle, edit, delete) is automatically pushed to
/// the customer UI within milliseconds. No manual refresh or app restart needed.
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

  // ── Internal ───────────────────────────────────────────────────────────────
  /// Raw unfiltered list of all active experiences from Firestore.
  final _allActiveExperiences = <Experience>[];

  /// Active Firestore stream subscriptions — cancelled in [onClose].
  StreamSubscription<List<Category>>? _categoriesSub;
  StreamSubscription<List<Experience>>? _experiencesSub;
  StreamSubscription<List<Review>>? _reviewsSub;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _bindRealtimeStreams();

    // Re-apply experience filters whenever user changes any filter param.
    ever(selectedCategorySlug, (_) => _applyExperienceFilters());
    ever(sortBy, (_) => _applyExperienceFilters());

    // Re-apply when categories change (cascade: hide experiences of inactive category).
    ever(rxCategories, (_) => _applyExperienceFilters());

    // Debounce keystroke-level search so we don't re-filter on every character.
    debounce(
      searchQuery,
      (_) => _applyExperienceFilters(),
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

    // 2. Experiences — stream ALL active items; filter in-memory so that:
    //    (a) changing a filter param does not create a new Firestore listener
    //    (b) disabling a category auto-hides its experiences via cascade filter
    isLoadingExperiences.value = true;
    _experiencesSub = repo.streamAllActiveExperiences().listen(
      (experiences) {
        _allActiveExperiences
          ..clear()
          ..addAll(experiences);
        _applyExperienceFilters();
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

  // ── In-memory filtering ────────────────────────────────────────────────────

  /// Filters [_allActiveExperiences] by active categories, selected category,
  /// search query, and sort order, then assigns the result to [rxExperiences].
  void _applyExperienceFilters() {
    // Cascade filter: exclude experiences from inactive (hidden) categories.
    final activeSlugs = rxCategories.map((c) => c.slug).toSet();
    var list =
        activeSlugs.isEmpty
            ? List<Experience>.from(_allActiveExperiences)
            : _allActiveExperiences
                .where((e) => activeSlugs.contains(e.categorySlug))
                .toList();

    // Category tab filter
    final catFilter = selectedCategorySlug.value;
    if (catFilter.isNotEmpty) {
      list = list.where((e) => e.categorySlug == catFilter).toList();
    }

    // Keyword search
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      list =
          list.where((e) {
            return e.name.toLowerCase().contains(query) ||
                e.description.toLowerCase().contains(query) ||
                e.tags.any((t) => t.toLowerCase().contains(query));
          }).toList();
    }

    // Sort
    switch (sortBy.value) {
      case 'price_low':
        list.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price_high':
        list.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      default:
        // 'popular' and 'latest' both sort by popularity
        list.sort((a, b) => b.popularity.compareTo(a.popularity));
    }

    rxExperiences.assignAll(list);
  }

  // ── Public API (UI compatibility) ──────────────────────────────────────────

  /// Force re-subscription to all Firestore streams (pull-to-refresh).
  /// Streams auto-refresh on Firestore changes; this is a fallback.
  Future<void> refreshCatalog() async {
    _categoriesSub?.cancel();
    _experiencesSub?.cancel();
    _reviewsSub?.cancel();
    _bindRealtimeStreams();
  }

  /// Kept for backward compatibility — streams handle this automatically.
  Future<void> loadCategories() async {}

  /// Kept for backward compatibility — [_applyExperienceFilters] handles this.
  Future<void> loadExperiences() async {
    _applyExperienceFilters();
  }

  void selectCategory(String slug) {
    // Toggle: tap the same category again to deselect
    selectedCategorySlug.value = selectedCategorySlug.value == slug ? '' : slug;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateSort(String option) {
    sortBy.value = option;
  }

  // ── Lead / Callback form ───────────────────────────────────────────────────

  Future<bool> requestCallback({
    required String name,
    required String phone,
    required String dateStr,
    required String budgetStr,
    required String requirements,
  }) async {
    if (!AppValidators.isValidName(name)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid name (at least 2 letters).",
      );
      return false;
    }
    if (!AppValidators.isValidPhone(phone)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid 10-digit phone number.",
      );
      return false;
    }

    try {
      isSubmittingLead.value = true;
      final cleanedPhone = AppValidators.cleanPhone(phone);
      final budget = double.tryParse(budgetStr) ?? 0.0;
      final eventDate = DateTime.tryParse(dateStr);

      final lead = Lead(
        id: '',
        name: name.trim(),
        phone: cleanedPhone,
        email: '',
        requestType: 'callback',
        eventDate: eventDate,
        budget: budget > 0 ? budget : null,
        requirements: requirements.trim(),
        status: 'new',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await submitLead(lead);

      // If customer is logged in, link lead to customer portal
      final authCtrl = Get.find<CustomerAuthController>();
      final customerId = authCtrl.rxCustomerProfile.value?.id ?? '';
      if (customerId.isNotEmpty) {
        final leadId = DateTime.now().millisecondsSinceEpoch.toString();
        final client = Supabase.instance.client;
        await client.from('customer_leads').upsert({
          'id': leadId,
          'customer_id': customerId,
          'lead_number': 'L-${DateTime.now().millisecondsSinceEpoch}',
          'date': DateTime.now().toIso8601String(),
          'service': requirements.trim().isNotEmpty ? requirements.trim() : 'Event Inquiry',
          'branch': authCtrl.rxCustomerProfile.value?.branch ?? 'Ahmedabad',
          'budget': budget,
          'event_date': eventDate?.toIso8601String() ?? DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'status': 'Pending',
          'admin_notes': '',
        });
      }

      Get.snackbar(
        "Inquiry Received",
        "Thank you! Our event manager will call you shortly.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on Failure catch (e) {
      Get.snackbar("Inquiry Failed", e.message);
      return false;
    } catch (e) {
      Get.snackbar("Inquiry Failed", e.toString());
      return false;
    } finally {
      isSubmittingLead.value = false;
    }
  }
}
