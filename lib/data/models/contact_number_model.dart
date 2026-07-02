class ContactNumberModel {
  final String id;
  final String label;
  final String number;
  final bool isPrimary;
  final bool isActive;
  final int displayOrder;

  const ContactNumberModel({
    required this.id,
    required this.label,
    required this.number,
    required this.isPrimary,
    required this.isActive,
    required this.displayOrder,
  });

  factory ContactNumberModel.fromJson(Map<String, dynamic> json) {
    return ContactNumberModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'number': number,
      'isPrimary': isPrimary,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }
}
