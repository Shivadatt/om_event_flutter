/// Entity representing decoration inventory stock items.
class InventoryItem {
  final String id;
  final String name;
  final int stock;
  final int lowStockThreshold;
  final String supplierName;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.stock,
    required this.lowStockThreshold,
    required this.supplierName,
  });
}
