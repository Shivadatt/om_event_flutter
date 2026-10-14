import '../entities/faq_item.dart';

abstract class FaqRepository {
  /// Realtime stream of FAQ items.
  /// If [activeOnly] is true, only returns active FAQs for public views.
  /// Otherwise returns all records for Admin Studio.
  Stream<List<FaqItem>> streamFaqs({bool activeOnly = false});

  /// Future fetch of FAQ items.
  Future<List<FaqItem>> getFaqs({bool activeOnly = false});

  /// Saves or updates a single FAQ item in the canonical Firestore document.
  Future<void> saveFaq(FaqItem faq);

  /// Saves the complete list of FAQ items in the canonical Firestore document.
  Future<void> saveAllFaqs(List<FaqItem> faqs);

  /// Deletes or soft-deletes an FAQ item.
  Future<void> deleteFaq(String id, {bool permanent = false});

  /// Idempotent seed procedure to initialize default FAQs if Firestore is empty.
  Future<void> seedDefaultFaqsIfEmpty();
}
