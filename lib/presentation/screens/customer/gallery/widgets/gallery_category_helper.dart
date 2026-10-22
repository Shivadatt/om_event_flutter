import 'package:get/get.dart';
import '../../../../controllers/catalog_controller.dart';

class GalleryCategoryHelper {
  static String getCategoryImageUrl(String catName, List<dynamic> allItems) {
    if (Get.isRegistered<CatalogController>()) {
      final catalog = Get.find<CatalogController>();
      final matchedCat = catalog.rxCategories.firstWhereOrNull(
        (c) => c.name.trim().toLowerCase() == catName.trim().toLowerCase(),
      );
      if (matchedCat != null && matchedCat.imageUrl.isNotEmpty) {
        return matchedCat.imageUrl;
      }
    }
    final matchedItem = allItems.firstWhereOrNull(
      (i) =>
          i.categoryName.trim().toLowerCase() == catName.trim().toLowerCase() &&
          (i.imageUrl as String).isNotEmpty,
    );
    if (matchedItem != null) return matchedItem.imageUrl as String;
    return '';
  }

  static String formatCategoryLabel(String raw) {
    if (raw.toUpperCase() == 'ALL') return 'ALL';
    final words =
        raw
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((w) {
              if (w.length <= 1) return w.toUpperCase();
              return w[0].toUpperCase() + w.substring(1).toLowerCase();
            })
            .toList();

    if (words.length <= 1) return words.first;
    if (words.length == 2) return '${words[0]}\n${words[1]}';
    if (words.contains('&')) {
      final idx = words.indexOf('&');
      final firstPart = words.sublist(0, idx + 1).join(' ');
      final secondPart = words.sublist(idx + 1).join(' ');
      return '$firstPart\n$secondPart';
    }
    final mid = (words.length / 2).ceil();
    return '${words.sublist(0, mid).join(' ')}\n${words.sublist(mid).join(' ')}';
  }
}
