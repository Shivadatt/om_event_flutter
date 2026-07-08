import '../../../core/utils/date_parser.dart';

class DeliveryEventModel {
  final String id;
  final String logId;
  final String event; // 'sent' | 'delivered' | 'opened' | 'clicked' | 'read' | 'failed'
  final String status;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  const DeliveryEventModel({
    required this.id,
    required this.logId,
    required this.event,
    required this.status,
    required this.timestamp,
    required this.details,
  });

  factory DeliveryEventModel.fromJson(Map<String, dynamic> json, String documentId) {
    return DeliveryEventModel(
      id: documentId,
      logId: json['logId'] ?? '',
      event: json['event'] ?? '',
      status: json['status'] ?? '',
      timestamp: DateParser.parse(json['timestamp']),
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logId': logId,
      'event': event,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }
}
