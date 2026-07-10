import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/quotation_message.dart';
import '../../domain/repositories/quotation_collaboration_repository.dart';

class QuotationCollaborationController extends GetxController {
  final String quotationId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'admin' | 'client'
  
  final QuotationCollaborationRepository _collaborationRepo;
  
  final rxMessages = <QuotationMessage>[].obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  
  final isSending = false.obs;
  final isUploading = false.obs;

  QuotationCollaborationController({
    required this.quotationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    QuotationCollaborationRepository? collaborationRepo,
  }) : _collaborationRepo = collaborationRepo ?? Get.find<QuotationCollaborationRepository>();

  @override
  void onInit() {
    super.onInit();
    
    // Bind real-time stream of messages
    rxMessages.bindStream(_collaborationRepo.streamMessages(quotationId));
    
    // Mark messages as read whenever a new list is received
    ever(rxMessages, (messagesList) {
      _markAsRead();
      _scrollToBottom();
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _markAsRead() async {
    try {
      await _collaborationRepo.markMessagesAsRead(quotationId, senderRole);
    } catch (_) {}
  }

  Future<void> sendTextMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    try {
      isSending.value = true;
      textController.clear();

      final message = QuotationMessage(
        id: '',
        quotationId: quotationId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        type: 'text',
        content: text,
        timestamp: DateTime.now(),
        isReadByAdmin: senderRole == 'admin',
        isReadByClient: senderRole == 'client',
        attachments: const [],
      );

      await _collaborationRepo.sendMessage(message);
    } catch (e) {
      Get.snackbar("Error", "Failed to send message: ${e.toString()}");
    } finally {
      isSending.value = false;
    }
  }

  Future<void> pickAndUploadAttachment() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final fileBytes = file.bytes;
      if (fileBytes == null) {
        Get.snackbar("Error", "Cannot read selected file data.");
        return;
      }

      isUploading.value = true;

      // 1. Upload file attachment
      final attachment = await _collaborationRepo.uploadAttachment(
        quotationId: quotationId,
        messageId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        fileName: file.name,
        fileBytes: fileBytes,
        contentType: _getContentType(file.extension ?? 'bin'),
        uploadedBy: senderName,
      );

      // 3. Send final attachment message
      final message = QuotationMessage(
        id: '',
        quotationId: quotationId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        type: attachment.fileType, // 'image' | 'pdf' | 'document'
        content: attachment.fileUrl,
        timestamp: DateTime.now(),
        isReadByAdmin: senderRole == 'admin',
        isReadByClient: senderRole == 'client',
        attachments: [attachment],
      );

      await _collaborationRepo.sendMessage(message);
    } catch (e) {
      Get.snackbar("Error", "Failed to upload file: ${e.toString()}");
    } finally {
      isUploading.value = false;
    }
  }

  String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      default:
        return 'application/octet-stream';
    }
  }
}
