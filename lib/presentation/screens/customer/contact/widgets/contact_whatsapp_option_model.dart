class WhatsAppOption {
  final String label;
  final String rawPhone;
  final String displayPhone;
  final bool isPrimary;

  const WhatsAppOption({
    required this.label,
    required this.rawPhone,
    required this.displayPhone,
    this.isPrimary = false,
  });

  String get displayText {
    final suffix = isPrimary ? " (Primary)" : "";
    return "$label: $displayPhone$suffix";
  }
}
