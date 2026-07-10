import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/quotation_message.dart';
import '../../domain/entities/quotation_attachment.dart';
import '../../domain/repositories/quotation_collaboration_repository.dart';
import '../datasources/supabase_storage_source.dart';
import '../models/quotation_message_model.dart';
import '../models/quotation_attachment_model.dart';

class QuotationCollaborationRepositoryImpl implements QuotationCollaborationRepository {
  final FirebaseFirestore _firestore;
  final SupabaseStorageSource? _storageSource;

  QuotationCollaborationRepositoryImpl({
    FirebaseFirestore? firestore,
    SupabaseStorageSource? storageSource,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageSource = storageSource;

  @override
  Stream<List<QuotationMessage>> streamMessages(String quotationId) {
    return _firestore
        .collection('quotation_messages')
        .where('quotationId', isEqualTo: quotationId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => QuotationMessageModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> sendMessage(QuotationMessage message) async {
    try {
      final docRef = _firestore.collection('quotation_messages').doc();
      final model = QuotationMessageModel(
        id: docRef.id,
        quotationId: message.quotationId,
        senderId: message.senderId,
        senderName: message.senderName,
        senderRole: message.senderRole,
        type: message.type,
        content: message.content,
        timestamp: message.timestamp,
        isReadByAdmin: message.isReadByAdmin,
        isReadByClient: message.isReadByClient,
        attachments: message.attachments
            .map((e) => QuotationAttachmentModel(
                  id: e.id,
                  quotationId: e.quotationId,
                  messageId: docRef.id,
                  fileName: e.fileName,
                  fileUrl: e.fileUrl,
                  fileType: e.fileType,
                  uploadedAt: e.uploadedAt,
                  uploadedBy: e.uploadedBy,
                ))
            .toList(),
      );

      await docRef.set(model.toJson());

      // Automatic auditing and notification generation
      try {
        final quoteSnap = await _firestore.collection('quotations').doc(message.quotationId).get();
        if (quoteSnap.exists) {
          final quoteData = quoteSnap.data()!;
          final versionNum = quoteData['version'] ?? 1;
          final customerId = quoteData['customerId'] ?? quoteData['customer_id'] ?? '';
          final location = quoteData['location'] ?? '';

          final hasAttachments = message.attachments.isNotEmpty;
          final action = hasAttachments ? 'Files Uploaded' : 'Messages Sent';
          final details = hasAttachments 
              ? 'Uploaded file: ${message.attachments.map((a) => a.fileName).join(", ")}'
              : 'Sent message: ${message.content}';

          // 1. Audit Log
          await _firestore.collection('activity_logs').add({
            'action': action,
            'user': message.senderName,
            'role': message.senderRole,
            'timestamp': FieldValue.serverTimestamp(),
            'version': versionNum,
            'quotationId': message.quotationId,
            'details': details,
          });

          // 2. Notification
          final isFromAdmin = message.senderRole == 'admin';
          final String targetCustomerId = isFromAdmin ? customerId : 'admin';
          
          final String notifTitle = hasAttachments
              ? (isFromAdmin ? 'New File from Coordinator' : 'New File from Client')
              : (isFromAdmin ? 'New Message from Coordinator' : 'New Message from Client');

          final String notifBody = isFromAdmin
              ? message.content
              : '${message.senderName}: ${message.content}';

          if (targetCustomerId.isNotEmpty) {
            await _firestore.collection('customer_notifications').add({
              'customerId': targetCustomerId,
              'title': notifTitle,
              'body': notifBody,
              'type': hasAttachments ? 'file_uploaded' : 'message_sent',
              'isRead': false,
              'createdAt': DateTime.now().toIso8601String(),
              'branch': location,
              'quotationId': message.quotationId,
            });
          }
        }
      } catch (_) {}
    } catch (e) {
      throw ServerFailure("Failed to send message: ${e.toString()}");
    }
  }

  @override
  Future<void> markMessagesAsRead(String quotationId, String role) async {
    try {
      final field = role == 'admin' ? 'isReadByAdmin' : 'isReadByClient';
      final snap = await _firestore
          .collection('quotation_messages')
          .where('quotationId', isEqualTo: quotationId)
          .where(field, isEqualTo: false)
          .get();

      if (snap.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in snap.docs) {
        batch.update(doc.reference, {field: true});
      }
      await batch.commit();
    } catch (e) {
      throw ServerFailure("Failed to mark messages as read: ${e.toString()}");
    }
  }

  @override
  Future<QuotationAttachment> uploadAttachment({
    required String quotationId,
    required String messageId,
    required String fileName,
    required List<int> fileBytes,
    required String contentType,
    required String uploadedBy,
  }) async {
    try {
      if (_storageSource == null) {
        throw const ServerFailure("Storage source is not configured.");
      }

      final ext = fileName.split('.').last.toLowerCase();
      String fileType = 'document';
      if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
        fileType = 'image';
      } else if (ext == 'pdf') {
        fileType = 'pdf';
      }

      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final filePath = 'quotes/attachments/$quotationId/$uniqueName';

      final publicUrl = await _storageSource.uploadFile(
        filePath,
        fileBytes,
        contentType,
        bucket: 'gallery',
      );

      final docRef = _firestore.collection('quotation_attachments').doc();
      final model = QuotationAttachmentModel(
        id: docRef.id,
        quotationId: quotationId,
        messageId: messageId,
        fileName: fileName,
        fileUrl: publicUrl,
        fileType: fileType,
        uploadedAt: DateTime.now(),
        uploadedBy: uploadedBy,
      );

      await docRef.set(model.toJson());
      return model;
    } catch (e) {
      throw ServerFailure("Failed to upload attachment: ${e.toString()}");
    }
  }

  @override
  Future<List<QuotationAttachment>> getAttachments(String quotationId) async {
    try {
      final snap = await _firestore
          .collection('quotation_attachments')
          .where('quotationId', isEqualTo: quotationId)
          .get();

      return snap.docs
          .map((doc) => QuotationAttachmentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerFailure("Failed to load attachments: ${e.toString()}");
    }
  }
}
