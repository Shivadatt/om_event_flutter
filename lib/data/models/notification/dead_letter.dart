import '../../../core/utils/date_parser.dart';

class DeadLetterNotificationModel {
  final String id;
  final String reason;
  final String channel;
  final Map<String, dynamic> payload;
  final int retryCount;
  final DateTime timestamp;
  final String stackTrace;

  const DeadLetterNotificationModel({
    required this.id,
    required this.reason,
    required this.channel,
    required this.payload,
    required this.retryCount,
    required this.timestamp,
    required this.stackTrace,
  });

  factory DeadLetterNotificationModel.fromJson(Map<String, dynamic> json, String documentId) {
    return DeadLetterNotificationModel(
      id: documentId,
      reason: json['reason'] ?? '',
      channel: json['channel'] ?? '',
      payload: Map<String, dynamic>.from(json['payload'] ?? {}),
      retryCount: json['retryCount'] ?? 0,
      timestamp: DateParser.parse(json['timestamp']),
      stackTrace: json['stackTrace'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'channel': channel,
      'payload': payload,
      'retryCount': retryCount,
      'timestamp': timestamp.toIso8601String(),
      'stackTrace': stackTrace,
    };
  }
}
