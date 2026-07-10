import '../../domain/entities/quotation_attachment.dart';
import '../../core/utils/date_parser.dart';

class QuotationAttachmentModel extends QuotationAttachment {
  const QuotationAttachmentModel({
    required super.id,
    required super.quotationId,
    required super.messageId,
    required super.fileName,
    required super.fileUrl,
    required super.fileType,
    required super.uploadedAt,
    required super.uploadedBy,
  });

  factory QuotationAttachmentModel.fromJson(Map<String, dynamic> json) {
    return QuotationAttachmentModel(
      id: json['id'] ?? '',
      quotationId: json['quotationId'] ?? json['quotation_id'] ?? '',
      messageId: json['messageId'] ?? json['message_id'] ?? '',
      fileName: json['fileName'] ?? json['file_name'] ?? 'file',
      fileUrl: json['fileUrl'] ?? json['file_url'] ?? '',
      fileType: json['fileType'] ?? json['file_type'] ?? 'document',
      uploadedAt: json['uploadedAt'] != null 
          ? DateParser.parse(json['uploadedAt']) 
          : DateTime.now(),
      uploadedBy: json['uploadedBy'] ?? json['uploaded_by'] ?? 'User',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotationId': quotationId,
      'messageId': messageId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
    };
  }
}
