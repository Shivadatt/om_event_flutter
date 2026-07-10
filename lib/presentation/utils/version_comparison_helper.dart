import '../../domain/entities/quotation.dart';

class ItemDiff {
  final List<QuotationItem> added;
  final List<QuotationItem> removed;
  final List<ModifiedItemDiff> modified;

  const ItemDiff({
    required this.added,
    required this.removed,
    required this.modified,
  });

  bool get hasChanges => added.isNotEmpty || removed.isNotEmpty || modified.isNotEmpty;
}

class ModifiedItemDiff {
  final QuotationItem oldItem;
  final QuotationItem newItem;

  const ModifiedItemDiff({
    required this.oldItem,
    required this.newItem,
  });

  bool get quantityChanged => oldItem.quantity != newItem.quantity;
  bool get priceChanged => oldItem.unitPrice != newItem.unitPrice;
  bool get notesChanged => oldItem.notes != newItem.notes;
  bool get themeChanged => oldItem.theme != newItem.theme;
  bool get colorChanged => oldItem.color != newItem.color;
}

class VersionComparisonHelper {
  static ItemDiff compareItems(List<QuotationItem> oldItems, List<QuotationItem> newItems) {
    final Map<String, QuotationItem> oldMap = {for (var item in oldItems) item.experienceId: item};
    final Map<String, QuotationItem> newMap = {for (var item in newItems) item.experienceId: item};

    final List<QuotationItem> added = [];
    final List<QuotationItem> removed = [];
    final List<ModifiedItemDiff> modified = [];

    // Find added and modified
    for (var newItem in newItems) {
      final oldItem = oldMap[newItem.experienceId];
      if (oldItem == null) {
        added.add(newItem);
      } else {
        if (oldItem.quantity != newItem.quantity ||
            oldItem.unitPrice != newItem.unitPrice ||
            oldItem.notes != newItem.notes ||
            oldItem.theme != newItem.theme ||
            oldItem.color != newItem.color) {
          modified.add(ModifiedItemDiff(oldItem: oldItem, newItem: newItem));
        }
      }
    }

    // Find removed
    for (var oldItem in oldItems) {
      if (!newMap.containsKey(oldItem.experienceId)) {
        removed.add(oldItem);
      }
    }

    return ItemDiff(added: added, removed: removed, modified: modified);
  }
}
