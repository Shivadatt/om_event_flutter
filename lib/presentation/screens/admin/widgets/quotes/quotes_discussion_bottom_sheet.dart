import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../domain/entities/quotation.dart';
import '../../../../../domain/entities/quotation_message.dart';
import '../../../../controllers/quotation_collaboration_controller.dart';

class QuotesDiscussionBottomSheet extends StatelessWidget {
  final Quotation quote;

  const QuotesDiscussionBottomSheet({
    super.key,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final Color paperColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;

    final chatController = Get.put(
      QuotationCollaborationController(
        quotationId: quote.id,
        senderId: 'admin_user',
        senderName: 'Admin Coordinators',
        senderRole: 'admin',
      ),
      tag: quote.id,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: isDark ? AppColors.darkLine : AppColors.lightLine, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PROPOSAL DISCUSSIONS",
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAccent,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Client Portal Chat",
                    style: AppTheme.serifHeader(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Quotation ID: ${quote.publicId.toUpperCase()} (Client: ${quote.customerName})",
            style: AppTheme.sansBody(fontSize: 12, color: subtitleColor),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkLine : AppColors.lightLine),
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
                              Icon(Icons.chat_bubble_outline_rounded, color: subtitleColor.withValues(alpha: 0.5), size: 36),
                              const SizedBox(height: 12),
                              Text(
                                "No messages yet. Send a message to coordinate with the customer.",
                                style: AppTheme.sansBody(fontSize: 11, color: subtitleColor),
                                textAlign: TextAlign.center,
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
                          final isMe = msg.senderRole == 'admin';
                          return _buildAdminMessageBubble(msg, isMe, isDark, textColor, subtitleColor);
                        },
                      );
                    }),
                  ),
                  Obx(() {
                    if (chatController.isUploading.value) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: isDark ? Colors.black26 : Colors.grey.shade200,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primaryAccent),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Uploading attachment...",
                              style: TextStyle(color: subtitleColor, fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey.shade100,
                      border: Border(top: BorderSide(color: isDark ? AppColors.darkLine : AppColors.lightLine)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.attach_file_rounded, color: AppColors.primaryAccent, size: 20),
                          onPressed: () => chatController.pickAndUploadAttachment(),
                          tooltip: "Upload Attachment",
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: chatController.textController,
                            style: TextStyle(color: textColor, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "Send a message to the customer...",
                              hintStyle: TextStyle(color: subtitleColor, fontSize: 13),
                              filled: true,
                              fillColor: isDark ? Colors.black12 : Colors.white,
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
                          icon: Icon(Icons.send_rounded, color: AppColors.primaryAccent, size: 20),
                          onPressed: () => chatController.sendTextMessage(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMessageBubble(
    QuotationMessage msg,
    bool isMe,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    if (msg.type == 'system' || msg.type == 'priceChange' || msg.type == 'revision') {
      Color bannerColor = AppColors.primaryAccent.withValues(alpha: 0.1);
      Color labelColor = AppColors.primaryAccent;
      IconData icon = Icons.info_outline_rounded;

      if (msg.type == 'priceChange') {
        bannerColor = AppColors.success.withValues(alpha: 0.1);
        labelColor = AppColors.success;
        icon = Icons.monetization_on_outlined;
      } else if (msg.type == 'revision') {
        bannerColor = AppColors.error.withValues(alpha: 0.1);
        labelColor = AppColors.error;
        icon = Icons.published_with_changes_rounded;
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bannerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: labelColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: labelColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg.content,
                style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    final aligns = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe 
        ? AppColors.primaryAccent.withValues(alpha: 0.15) 
        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200);
    final borderColor = isMe 
        ? AppColors.primaryAccent.withValues(alpha: 0.3) 
        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: aligns,
        children: [
          GestureDetector(
            onTap: (msg.type == 'image' || msg.type == 'pdf' || msg.type == 'document')
                ? () async {
                    try {
                      final uri = Uri.parse(msg.content);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    } catch (_) {}
                  }
                : null,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      msg.senderName.toUpperCase(),
                      style: TextStyle(color: AppColors.primaryAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  if (!isMe) const SizedBox(height: 4),
                  if (msg.type == 'text')
                    Text(msg.content, style: TextStyle(color: textColor, fontSize: 12.5)),
                  if (msg.type == 'image')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(msg.content, fit: BoxFit.cover),
                    ),
                  if (msg.type == 'pdf' || msg.type == 'document')
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          msg.type == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
                          color: AppColors.primaryAccent,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            msg.attachments.isNotEmpty ? msg.attachments.first.fileName : "View Attachment",
                            style: TextStyle(color: textColor, fontSize: 12, decoration: TextDecoration.underline),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Text(
            "${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
            style: TextStyle(color: subtitleColor, fontSize: 9),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
