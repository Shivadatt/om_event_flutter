import 'quotation_attachment.dart';

class QuotationMessage {
  final String id;
  final String quotationId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'admin' | 'client'
  final String type; // 'text' | 'image' | 'pdf' | 'document' | 'system' | 'priceChange' | 'revision'
  final String content;
  final DateTime timestamp;
  final bool isReadByAdmin;
  final bool isReadByClient;
  final List<QuotationAttachment> attachments;

  const QuotationMessage({
    required this.id,
    required this.quotationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.type,
    required this.content,
    required this.timestamp,
    required this.isReadByAdmin,
    required this.isReadByClient,
    this.attachments = const [],
  });
}
