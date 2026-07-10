import '../entities/category.dart';
import '../repositories/catalog_repository.dart';

class GetCategories {
  final CatalogRepository repository;
  GetCategories(this.repository);

  Future<List<Category>> call() async {
    return await repository.getCategories();
  }

  Stream<List<Category>> executeStream() {
    return repository.streamCategories();
  }
}
