import '../../core/utils/date_parser.dart';

class FcmTokenModel {
  final String userId;
  final String deviceToken;
  final String platform;
  final DateTime updatedAt;

  const FcmTokenModel({
    required this.userId,
    required this.deviceToken,
    required this.platform,
    required this.updatedAt,
  });

  factory FcmTokenModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenModel(
      userId: json['userId'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      platform: json['platform'] ?? 'web',
      updatedAt: DateParser.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'deviceToken': deviceToken,
      'platform': platform,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

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

class NotificationTemplateModel {
  final String id;
  final String eventKey; // e.g., 'booking_confirmation'
  final String titleTemplate;
  final String bodyTemplate;
  final bool isPushEnabled;
  final bool isEmailEnabled;
  final bool isWhatsappEnabled;

  const NotificationTemplateModel({
    required this.id,
    required this.eventKey,
    required this.titleTemplate,
    required this.bodyTemplate,
    required this.isPushEnabled,
    required this.isEmailEnabled,
    required this.isWhatsappEnabled,
  });

  factory NotificationTemplateModel.fromJson(Map<String, dynamic> json, String documentId) {
    return NotificationTemplateModel(
      id: documentId,
      eventKey: json['eventKey'] ?? '',
      titleTemplate: json['titleTemplate'] ?? '',
      bodyTemplate: json['bodyTemplate'] ?? '',
      isPushEnabled: json['isPushEnabled'] ?? true,
      isEmailEnabled: json['isEmailEnabled'] ?? true,
      isWhatsappEnabled: json['isWhatsappEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventKey': eventKey,
      'titleTemplate': titleTemplate,
      'bodyTemplate': bodyTemplate,
      'isPushEnabled': isPushEnabled,
      'isEmailEnabled': isEmailEnabled,
      'isWhatsappEnabled': isWhatsappEnabled,
    };
  }
}

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

class NotificationPreferenceModel {
  final String uid;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool whatsappEnabled;
  final bool bookingEnabled;
  final bool paymentEnabled;
  final bool quotationEnabled;
  final bool reviewEnabled;
  final bool offerEnabled;
  final bool supportEnabled;
  final bool reminderEnabled;
  final bool marketingEnabled;
  final bool newsletterEnabled;
  final bool dndEnabled;
  final String quietHoursStart; // "HH:mm" format
  final String quietHoursEnd;   // "HH:mm" format
  final bool dailyDigestEnabled;

  const NotificationPreferenceModel({
    required this.uid,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.whatsappEnabled,
    required this.bookingEnabled,
    required this.paymentEnabled,
    required this.quotationEnabled,
    required this.reviewEnabled,
    required this.offerEnabled,
    required this.supportEnabled,
    required this.reminderEnabled,
    required this.marketingEnabled,
    required this.newsletterEnabled,
    required this.dndEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.dailyDigestEnabled,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json, String userId) {
    return NotificationPreferenceModel(
      uid: userId,
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      whatsappEnabled: json['whatsappEnabled'] ?? true,
      bookingEnabled: json['bookingEnabled'] ?? true,
      paymentEnabled: json['paymentEnabled'] ?? true,
      quotationEnabled: json['quotationEnabled'] ?? true,
      reviewEnabled: json['reviewEnabled'] ?? true,
      offerEnabled: json['offerEnabled'] ?? true,
      supportEnabled: json['supportEnabled'] ?? true,
      reminderEnabled: json['reminderEnabled'] ?? true,
      marketingEnabled: json['marketingEnabled'] ?? false,
      newsletterEnabled: json['newsletterEnabled'] ?? false,
      dndEnabled: json['dndEnabled'] ?? false,
      quietHoursStart: json['quietHoursStart'] ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '07:00',
      dailyDigestEnabled: json['dailyDigestEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'whatsappEnabled': whatsappEnabled,
      'bookingEnabled': bookingEnabled,
      'paymentEnabled': paymentEnabled,
      'quotationEnabled': quotationEnabled,
      'reviewEnabled': reviewEnabled,
      'offerEnabled': offerEnabled,
      'supportEnabled': supportEnabled,
      'reminderEnabled': reminderEnabled,
      'marketingEnabled': marketingEnabled,
      'newsletterEnabled': newsletterEnabled,
      'dndEnabled': dndEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'dailyDigestEnabled': dailyDigestEnabled,
    };
  }
}

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
