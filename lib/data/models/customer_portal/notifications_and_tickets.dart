import '../../../domain/entities/customer_notification.dart';
import '../../../domain/entities/customer_document.dart';
import '../../../domain/entities/support_ticket.dart';
import '../../../core/utils/date_parser.dart';

class CustomerNotificationModel extends CustomerNotification {
  const CustomerNotificationModel({
    required super.id,
    required super.customerId,
    required super.title,
    required super.body,
    required super.type,
    required super.isRead,
    super.branch,
    required super.createdAt,
    super.isArchived,
    super.priority,
    super.expiresAt,
  });

  factory CustomerNotificationModel.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return CustomerNotificationModel(
      id: id,
      customerId: json['customerId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'Announcement',
      isRead: json['isRead'] ?? false,
      branch: json['branch'] ?? '',
      createdAt: DateParser.parse(json['createdAt']),
      isArchived: json['isArchived'] ?? false,
      priority: json['priority'] ?? 'normal',
      expiresAt: json['expiresAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'branch': branch,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
      'priority': priority,
      'expiresAt': expiresAt,
    };
  }
}

class CustomerDocumentModel extends CustomerDocument {
  const CustomerDocumentModel({
    required super.id,
    required super.customerId,
    required super.bookingId,
    required super.name,
    required super.url,
    required super.type,
    required super.createdAt,
  });

  factory CustomerDocumentModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerDocumentModel(
      id: id,
      customerId: json['customerId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'Invoice',
      createdAt: DateParser.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'bookingId': bookingId,
      'name': name,
      'url': url,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SupportTicketModel extends SupportTicket {
  const SupportTicketModel({
    required super.id,
    required super.customerId,
    required super.subject,
    required super.status,
    required super.messages,
    required super.createdAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json, String id) {
    return SupportTicketModel(
      id: id,
      customerId: json['customerId'] ?? '',
      subject: json['subject'] ?? '',
      status: json['status'] ?? 'Open',
      messages: List<String>.from(json['messages'] ?? []),
      createdAt: DateParser.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'subject': subject,
      'status': status,
      'messages': messages,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
