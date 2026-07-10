import '../../domain/entities/quotation_message.dart';
import '../../core/utils/date_parser.dart';
import 'quotation_attachment_model.dart';

class QuotationMessageModel extends QuotationMessage {
  const QuotationMessageModel({
    required super.id,
    required super.quotationId,
    required super.senderId,
    required super.senderName,
    required super.senderRole,
    required super.type,
    required super.content,
    required super.timestamp,
    required super.isReadByAdmin,
    required super.isReadByClient,
    required List<QuotationAttachmentModel> super.attachments,
  });

  factory QuotationMessageModel.fromJson(Map<String, dynamic> json, String id) {
    final rawAttach = json['attachments'] as List? ?? [];
    final attachList = rawAttach
        .map((e) => QuotationAttachmentModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return QuotationMessageModel(
      id: id,
      quotationId: json['quotationId'] ?? json['quotation_id'] ?? '',
      senderId: json['senderId'] ?? json['sender_id'] ?? '',
      senderName: json['senderName'] ?? json['sender_name'] ?? '',
      senderRole: json['senderRole'] ?? json['sender_role'] ?? 'client',
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateParser.parse(json['timestamp']) 
          : DateTime.now(),
      isReadByAdmin: json['isReadByAdmin'] ?? json['is_read_by_admin'] ?? false,
      isReadByClient: json['isReadByClient'] ?? json['is_read_by_client'] ?? false,
      attachments: attachList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quotationId': quotationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'type': type,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isReadByAdmin': isReadByAdmin,
      'isReadByClient': isReadByClient,
      'attachments': attachments
          .map((e) => (e as QuotationAttachmentModel).toJson())
          .toList(),
    };
  }
}
