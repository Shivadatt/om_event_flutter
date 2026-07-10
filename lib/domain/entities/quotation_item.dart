class QuotationItem {
  final String experienceId;
  final String name;
  final int quantity;
  final double unitPrice;
  final String color;
  final String theme;
  final String notes;

  const QuotationItem({
    required this.experienceId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.color,
    required this.theme,
    required this.notes,
  });

  double get totalPrice => unitPrice * quantity;
}
