import '../../../core/utils/date_parser.dart';

class QueueTaskModel {
  final String id;
  final String recipient;
  final String recipientId;
  final String type;
  final String title;
  final String body;
  final String status;
  final String channel;
  final int retryCount;
  final String errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QueueTaskModel({
    required this.id,
    required this.recipient,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    required this.status,
    required this.channel,
    required this.retryCount,
    required this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QueueTaskModel.fromJson(Map<String, dynamic> json, String documentId) {
    return QueueTaskModel(
      id: documentId,
      recipient: json['recipient'] ?? '',
      recipientId: json['recipientId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      status: json['status'] ?? 'pending',
      channel: json['channel'] ?? 'push',
      retryCount: json['retryCount'] ?? 0,
      errorMessage: json['errorMessage'] ?? '',
      createdAt: DateParser.parse(json['createdAt']),
      updatedAt: DateParser.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipient': recipient,
      'recipientId': recipientId,
      'type': type,
      'title': title,
      'body': body,
      'status': status,
      'channel': channel,
      'retryCount': retryCount,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
