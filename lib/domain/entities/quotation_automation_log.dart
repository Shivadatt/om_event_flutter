class QuotationAutomationLog {
  final String title;
  final String description;
  final DateTime timestamp;

  const QuotationAutomationLog({
    required this.title,
    required this.description,
    required this.timestamp,
  });

  factory QuotationAutomationLog.fromJson(Map<String, dynamic> json) {
    return QuotationAutomationLog(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
