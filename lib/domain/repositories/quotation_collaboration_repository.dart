import '../entities/quotation_message.dart';
import '../entities/quotation_attachment.dart';

abstract class QuotationCollaborationRepository {
  Stream<List<QuotationMessage>> streamMessages(String quotationId);
  Future<void> sendMessage(QuotationMessage message);
  Future<void> markMessagesAsRead(String quotationId, String role);
  Future<QuotationAttachment> uploadAttachment({
    required String quotationId,
    required String messageId,
    required String fileName,
    required List<int> fileBytes,
    required String contentType,
    required String uploadedBy,
  });
  Future<List<QuotationAttachment>> getAttachments(String quotationId);
}
