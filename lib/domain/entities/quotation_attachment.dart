class QuotationAttachment {
  final String id;
  final String quotationId;
  final String messageId;
  final String fileName;
  final String fileUrl;
  final String fileType; // 'image' | 'pdf' | 'document'
  final DateTime uploadedAt;
  final String uploadedBy;

  const QuotationAttachment({
    required this.id,
    required this.quotationId,
    required this.messageId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedAt,
    required this.uploadedBy,
  });
}
