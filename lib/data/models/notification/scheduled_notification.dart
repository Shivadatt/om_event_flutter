import '../../../core/utils/date_parser.dart';

class ScheduledNotificationModel {
  final String id;
  final String eventId;
  final String eventType; // e.g. 'booking_reminder'
  final String recipient;
  final String recipientId;
  final DateTime triggerAt;
  final String title;
  final String body;
  final String channel;
  final String status; // 'pending' | 'sent' | 'cancelled'

  const ScheduledNotificationModel({
    required this.id,
    required this.eventId,
    required this.eventType,
    required this.recipient,
    required this.recipientId,
    required this.triggerAt,
    required this.title,
    required this.body,
    required this.channel,
    required this.status,
  });

  factory ScheduledNotificationModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ScheduledNotificationModel(
      id: documentId,
      eventId: json['eventId'] ?? '',
      eventType: json['eventType'] ?? '',
      recipient: json['recipient'] ?? '',
      recipientId: json['recipientId'] ?? '',
      triggerAt: DateParser.parse(json['triggerAt']),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      channel: json['channel'] ?? 'email',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventType': eventType,
      'recipient': recipient,
      'recipientId': recipientId,
      'triggerAt': triggerAt.toIso8601String(),
      'title': title,
      'body': body,
      'channel': channel,
      'status': status,
    };
  }
}
