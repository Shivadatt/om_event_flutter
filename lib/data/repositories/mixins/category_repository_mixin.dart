import '../../../domain/entities/category.dart';
import '../../datasources/firestore_remote_source.dart';
import '../../models/category_model.dart';

/// Mixin responsibility to handle categories domain fetch & mutations.
mixin CategoryRepositoryMixin {
  /// Remote database data source.
  FirestoreRemoteSource get remoteSource;

  static final List<Category> _fallbackCategories = [
    Category(
      id: 'birthday',
      name: 'Birthday Celebrations',
      slug: 'birthday',
      description: 'Joyful themes designed around their favorite things.',
      icon: '🎈',
      color: '#e58b9d',
      imageUrl:
          'https://raw.githubusercontent.com/omevents/assets/main/categories/birthday.jpg',
      sortOrder: 0,
      isActive: true,
    ),
    Category(
      id: 'wedding',
      name: 'Wedding & Engagement',
      slug: 'wedding',
      description: 'Elegant stages and entrances for once-in-a-lifetime vows.',
      icon: '💍',
      color: '#c79b61',
      imageUrl:
          'https://raw.githubusercontent.com/omevents/assets/main/categories/wedding.jpg',
      sortOrder: 1,
      isActive: true,
    ),
    Category(
      id: 'baby',
      name: 'Baby Celebrations',
      slug: 'baby',
      description: 'Soft, playful worlds for showers and welcome-home moments.',
      icon: '☁',
      color: '#75a9a6',
      imageUrl:
          'https://raw.githubusercontent.com/omevents/assets/main/categories/baby.jpg',
      sortOrder: 2,
      isActive: true,
    ),
    Category(
      id: 'corporate',
      name: 'Corporate Events',
      slug: 'corporate',
      description: 'Polished launches, openings, and branded experiences.',
      icon: '✦',
      color: '#7c86bd',
      imageUrl:
          'https://raw.githubusercontent.com/omevents/assets/main/categories/corporate.jpg',
      sortOrder: 3,
      isActive: true,
    ),
    Category(
      id: 'proposal',
      name: 'Surprise & Proposal',
      slug: 'proposal',
      description: 'Thoughtful romantic settings with a cinematic reveal.',
      icon: '♡',
      color: '#c96f64',
      imageUrl:
          'https://raw.githubusercontent.com/omevents/assets/main/categories/proposal.jpg',
      sortOrder: 4,
      isActive: true,
    ),
    Category(
      id: 'entries',
      name: 'Grand Entries',
      slug: 'entries',
      description: 'Fog, flowers, cold fire, and choreography for impact.',
      icon: '⚡',
      color: '#a483c0',
      imageUrl:
          'https://raw.githubusercontent.com/omevents/assets/main/categories/entries.jpg',
      sortOrder: 5,
      isActive: true,
    ),
  ];

  /// Get fallback categories.
  List<Category> get fallbackCategories => _fallbackCategories;

  /// Retrieve all event decoration categories.
  Future<List<Category>> getCategories() async {
    try {
      await remoteSource.ensureSeeded();
      final docs = await remoteSource.fetchCategories();
      return docs
          .map((doc) => CategoryModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return _fallbackCategories;
    }
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
}
