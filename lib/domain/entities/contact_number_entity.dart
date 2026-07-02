class ContactNumberEntity {
  final String id;
  final String label;
  final String number;
  final bool isPrimary;
  final bool isActive;
  final int displayOrder;

  const ContactNumberEntity({
    required this.id,
    required this.label,
    required this.number,
    required this.isPrimary,
    required this.isActive,
    required this.displayOrder,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactNumberEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          number == other.number &&
          isPrimary == other.isPrimary &&
          isActive == other.isActive &&
          displayOrder == other.displayOrder;

  @override
  int get hashCode =>
      id.hashCode ^
      label.hashCode ^
      number.hashCode ^
      isPrimary.hashCode ^
      isActive.hashCode ^
      displayOrder.hashCode;
}
