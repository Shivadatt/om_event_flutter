class QuotationItemModel {
  final String id;
  final String quotationId;
  final String decorationItemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final String color;
  final String theme;
  final String notes;

  QuotationItemModel({
    required this.id,
    required this.quotationId,
    required this.decorationItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.color,
    required this.theme,
    required this.notes,
  });

  factory QuotationItemModel.fromJson(Map<String, dynamic> json, String id) {
    return QuotationItemModel(
      id: id,
      quotationId: json['quotationId'] ?? '',
      decorationItemId: json['decorationItemId'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] ?? '',
      theme: json['theme'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quotationId': quotationId,
      'decorationItemId': decorationItemId,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'color': color,
      'theme': theme,
      'notes': notes,
    };
  }
}
