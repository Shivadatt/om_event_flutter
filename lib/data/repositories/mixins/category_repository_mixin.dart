import '../../../domain/entities/category.dart';
import '../../datasources/firestore_remote_source.dart';
import '../../models/category_model.dart';

/// Mixin responsibility to handle categories domain fetch & mutations.
mixin CategoryRepositoryMixin {
  /// Remote database data source.
  FirestoreRemoteSource get remoteSource;

  /// Retrieve all event decoration categories — active only.
  /// Used by the Customer Website.
  Future<List<Category>> getCategories() async {
    try {
      await remoteSource.ensureSeeded();
      final docs = await remoteSource.fetchCategories();
      return docs
          .map<Category>((doc) => CategoryModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Retrieve ALL categories regardless of [is_active] status.
  /// Used exclusively by the Admin Panel.
  Future<List<Category>> getAllCategories() async {
    try {
      await remoteSource.ensureSeeded();
      final docs = await remoteSource.fetchAllCategories();
      return docs
          .map<Category>((doc) => CategoryModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Patch [is_active] on a single category document in Firestore.
  Future<void> toggleCategoryStatus(
    String slug, {
    required bool isActive,
  }) async {
    await remoteSource.toggleCategoryStatus(slug, isActive: isActive);
  }

  /// Create a new category configuration.
  Future<void> createCategory(Category category) async {
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      description: category.description,
      icon: category.icon,
      color: category.color,
      imageUrl: category.imageUrl,
      sortOrder: category.sortOrder,
      itemCount: category.itemCount,
      isActive: category.isActive,
    );
    await remoteSource.createCategory(model.toJson());
  }

  /// Update an existing category details.
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      description: category.description,
      icon: category.icon,
      color: category.color,
      imageUrl: category.imageUrl,
      sortOrder: category.sortOrder,
      itemCount: category.itemCount,
      isActive: category.isActive,
    );
    await remoteSource.updateCategory(category.slug, model.toJson());
  }

  /// Delete a category from catalog index.
  Future<void> deleteCategory(String slug) async {
    await remoteSource.deleteCategory(slug);
  }

  // ── Realtime Streams ─────────────────────────────────────────────────────

  /// Realtime stream of active categories for the customer website.
  /// Emits a new list automatically whenever Firestore changes.
  Stream<List<Category>> streamCategories() {
    return remoteSource.streamActiveCategories().map<List<Category>>(
      (docs) => docs
          .map<Category>((doc) => CategoryModel.fromJson(doc.data(), doc.id))
          .toList(),
    );
  }

  /// Realtime stream of ALL categories (active + inactive) for the Admin Panel.
  /// Emits a new list automatically whenever Firestore changes.
  Stream<List<Category>> streamAllCategories() {
    return remoteSource.streamAllCategories().map<List<Category>>(
      (docs) => docs
          .map<Category>((doc) => CategoryModel.fromJson(doc.data(), doc.id))
          .toList(),
    );
  }
}
