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
  final pendingMessages = <QuotationMessage>[].obs;
  
  List<QuotationMessage> get combinedMessages {
    return [...rxMessages, ...pendingMessages];
  }

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

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final message = QuotationMessage(
      id: tempId,
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

    // Instant clear of input and add to pending list
    textController.clear();
    pendingMessages.add(message);
    _scrollToBottom();

    try {
      debugPrint("sendTextMessage: Setting isSending=true, text='$text'");
      isSending.value = true;

      debugPrint("sendTextMessage: Calling sendMessage...");
      await _collaborationRepo.sendMessage(message);
      debugPrint("sendTextMessage: sendMessage completed successfully.");
    } catch (e) {
      debugPrint("sendTextMessage Exception: $e");
      Get.snackbar("Error", "Failed to send message: ${e.toString()}");
    } finally {
      debugPrint("sendTextMessage: finally — removing tempId=$tempId and setting isSending=false");
      pendingMessages.removeWhere((m) => m.id == tempId);
      isSending.value = false;
    }
  }

  Future<void> pickAndUploadAttachment() async {
    try {
      debugPrint("pickAndUploadAttachment: Opening file picker...");
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint("pickAndUploadAttachment: File picker cancelled or no file selected.");
        return;
      }

      final file = result.files.first;
      final fileBytes = file.bytes;
      if (fileBytes == null) {
        debugPrint("pickAndUploadAttachment: fileBytes is null — cannot read file data.");
        Get.snackbar("Error", "Cannot read selected file data.");
        return;
      }

      final tempId = 'temp_file_${DateTime.now().millisecondsSinceEpoch}';
      final ext = file.name.split('.').last.toLowerCase();
      String fileType = 'document';
      if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
        fileType = 'image';
      } else if (ext == 'pdf') {
        fileType = 'pdf';
      }

      final tempMessage = QuotationMessage(
        id: tempId,
        quotationId: quotationId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        type: fileType,
        content: file.name,
        timestamp: DateTime.now(),
        isReadByAdmin: senderRole == 'admin',
        isReadByClient: senderRole == 'client',
        attachments: const [],
      );

      pendingMessages.add(tempMessage);
      isUploading.value = true;
      _scrollToBottom();

      // 1. Upload file attachment
      debugPrint("pickAndUploadAttachment: Uploading attachment...");
      final attachment = await _collaborationRepo.uploadAttachment(
        quotationId: quotationId,
        messageId: tempId,
        fileName: file.name,
        fileBytes: fileBytes,
        contentType: _getContentType(ext),
        uploadedBy: senderName,
      );
      debugPrint("pickAndUploadAttachment: Attachment uploaded. URL=${attachment.fileUrl}");

      // 2. Send final attachment message
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

      debugPrint("pickAndUploadAttachment: Sending message with attachment...");
      await _collaborationRepo.sendMessage(message);
      debugPrint("pickAndUploadAttachment: Message with attachment sent successfully.");
    } catch (e) {
      debugPrint("pickAndUploadAttachment Exception: $e");
      Get.snackbar("Error", "Failed to upload file: ${e.toString()}");
    } finally {
      debugPrint("pickAndUploadAttachment: finally — setting isUploading=false");
      pendingMessages.clear();
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
