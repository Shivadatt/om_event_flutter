import '../../../core/utils/date_parser.dart';

class NotificationLogModel {
  final String id;
  final String recipientId;
  final String type; // e.g., 'booking_confirmed', 'admin_alert'
  final String title;
  final String body;
  final String status; // 'success' | 'failed'
  final DateTime sentAt;
  final List<String> channelsUsed; // ['push', 'email', 'whatsapp']

  const NotificationLogModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    required this.status,
    required this.sentAt,
    required this.channelsUsed,
  });

  factory NotificationLogModel.fromJson(Map<String, dynamic> json, String documentId) {
    return NotificationLogModel(
      id: documentId,
      recipientId: json['recipientId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      status: json['status'] ?? 'success',
      sentAt: DateParser.parse(json['sentAt']),
      channelsUsed: List<String>.from(json['channelsUsed'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipientId': recipientId,
      'type': type,
      'title': title,
      'body': body,
      'status': status,
      'sentAt': sentAt.toIso8601String(),
      'channelsUsed': channelsUsed,
    };
  }
}
