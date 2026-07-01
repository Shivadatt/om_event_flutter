import '../../domain/repositories/catalog_repository.dart';
import '../datasources/firestore_remote_source.dart';
import 'mixins/category_repository_mixin.dart';
import 'mixins/item_repository_mixin.dart';
import 'mixins/review_repository_mixin.dart';

/// Repository implementation serving category & item catalog details mixed from domain-specific features.
class CatalogRepositoryImpl
    with CategoryRepositoryMixin, ItemRepositoryMixin, ReviewRepositoryMixin
    implements CatalogRepository {
  @override
  final FirestoreRemoteSource remoteSource;

  /// Creates a [CatalogRepositoryImpl] instance.
  CatalogRepositoryImpl(this.remoteSource);
}
