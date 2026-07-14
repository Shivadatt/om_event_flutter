import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/domain/entities/quotation.dart';
import 'package:om_event/presentation/controllers/quotation_collaboration_controller.dart';
import 'quotes_chat_bubble.dart';

/// Renders the collaboration and discussions chat feed between customer and coordinators.
class QuotesChatSection extends StatelessWidget {
  final Quotation activeQuote;

  const QuotesChatSection({super.key, required this.activeQuote});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put(
      QuotationCollaborationController(
        quotationId: activeQuote.id,
        senderId: activeQuote.customerId.isNotEmpty ? activeQuote.customerId : 'client_user',
        senderName: activeQuote.customerName.isNotEmpty ? activeQuote.customerName : 'Client',
        senderRole: 'client',
      ),
      tag: activeQuote.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          "COLLABORATION & DISCUSSIONS",
          style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  final messages = chatController.combinedMessages;
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white24, size: 36),
                          const SizedBox(height: 12),
                          Text(
                            "Start a discussion with our design coordinators.",
                            style: AppTheme.sansBody(fontSize: 11, color: Colors.white30),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: chatController.scrollController,
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, idx) {
                      final msg = messages[idx];
                      final isMe = msg.senderRole == 'client';
                      return QuotesChatBubble(msg: msg, isMe: isMe);
                    },
                  );
                }),
              ),
              Obx(() {
                if (chatController.isUploading.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.black26,
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFD4AF37)),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Uploading attachment...",
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file_rounded, color: Color(0xFFD4AF37), size: 20),
                      onPressed: () => chatController.pickAndUploadAttachment(),
                      tooltip: "Upload Attachment",
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: chatController.textController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Ask a question, request modifications...",
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                          filled: true,
                          fillColor: Colors.black12,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => chatController.sendTextMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFFD4AF37), size: 20),
                      onPressed: () => chatController.sendTextMessage(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
