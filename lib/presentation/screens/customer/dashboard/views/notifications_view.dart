import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Notifications center panel rendering for customers.
class NotificationsView extends StatefulWidget {
  final CustomerDashboardController controller;

  const NotificationsView({
    super.key,
    required this.controller,
  });

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  String notificationQuery = '';
  String activeCategory = 'All'; // 'All' | 'Alert' | 'Announcement' | 'Archived'
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
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
                    "CONCIERGE MESSAGES",
                    style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Inbox & Activity Center",
                    style: GoogleFonts.italiana(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.done_all, color: Color(0xFFD4AF37), size: 16),
                label: const Text("MARK ALL READ", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () {
                  for (var notif in widget.controller.rxNotifications) {
                    widget.controller.markNotificationRead(notif.id);
                  }
                  Get.snackbar(
                    "Inbox Updated",
                    "All notifications marked as read successfully.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF171411),
                    colorText: const Color(0xFFD4AF37),
                  );
                },
              )
            ],
          ),
          const SizedBox(height: 24),

          // Search Input
          TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37), size: 20),
              hintText: "Search alerts by title or content...",
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
              filled: true,
              fillColor: Colors.black26,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD4AF37)),
              ),
            ),
            onChanged: (val) {
              setState(() => notificationQuery = val.toLowerCase());
            },
          ),
          const SizedBox(height: 16),

          // Category Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                'Alert',
                'Announcement',
                'Archived',
              ].map((category) {
                final isSelected = activeCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF091210) : const Color(0xFFD4AF37),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFD4AF37),
                    backgroundColor: const Color(0xFF171411),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: isSelected ? 1 : 0.3)),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => activeCategory = category);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Notification List
          Expanded(
            child: Obx(() {
              var list = widget.controller.rxNotifications.where((n) {
                final isArchived = n.isArchived;
                final matchQuery = n.title.toLowerCase().contains(notificationQuery) || n.body.toLowerCase().contains(notificationQuery);

                bool matchCategory = false;
                if (activeCategory == 'All') {
                  matchCategory = !isArchived;
                } else if (activeCategory == 'Archived') {
                  matchCategory = isArchived;
                } else {
                  matchCategory = !isArchived && n.type == activeCategory;
                }

                return matchQuery && matchCategory;
              }).toList();

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_outlined, color: Colors.white24, size: 48),
                      const SizedBox(height: 16),
                      Text("No messages in this folder.", style: AppTheme.sansBody(fontSize: 13, color: Colors.white54)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final notif = list[index];
                  final priority = notif.priority;
                  final expiresAtStr = notif.expiresAt;

                  // Check expiry
                  if (expiresAtStr != null) {
                    try {
                      final expiry = DateTime.parse(expiresAtStr);
                      if (expiry.isBefore(DateTime.now())) {
                        return const SizedBox.shrink();
                      }
                    } catch (_) {}
                  }

                  Color priorityColor = const Color(0xFFE6C98D);
                  if (priority == 'high') priorityColor = const Color(0xFFC95C5C);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: notif.isRead ? const Color(0x99171411) : const Color(0xFF171411),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: notif.isRead ? const Color(0x0AD4AF37) : const Color(0x33D4AF37),
                        width: 1.2,
                      ),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: notif.isRead ? Colors.transparent : const Color(0x1AD4AF37),
                        ),
                        child: Icon(
                          notif.isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                          color: const Color(0xFFD4AF37),
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (priority == 'high')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: priorityColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                "HIGH PRIORITY",
                                style: TextStyle(color: priorityColor, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            notif.body,
                            style: TextStyle(
                              color: notif.isRead ? Colors.white54 : Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          if (expiresAtStr != null) ...[
                            const SizedBox(height: 6),
                            Text("Expires: $expiresAtStr", style: const TextStyle(color: Colors.white24, fontSize: 9)),
                          ]
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          activeCategory == 'Archived' ? Icons.unarchive_outlined : Icons.archive_outlined,
                          color: Colors.white38,
                          size: 20,
                        ),
                        onPressed: () => widget.controller.archiveNotification(notif.id, activeCategory != 'Archived'),
                      ),
                      onTap: () => widget.controller.markNotificationRead(notif.id),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
