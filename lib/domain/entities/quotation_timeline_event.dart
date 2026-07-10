import 'quotation_status.dart';

class QuotationTimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final QuotationStatus status;

  const QuotationTimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
  });
}
