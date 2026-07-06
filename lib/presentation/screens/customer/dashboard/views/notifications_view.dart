import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  String activeCategory = 'All'; // 'All' | 'Alert' | 'Booking' | 'Payment' | 'Announcement' | 'Archived'
  final searchController = TextEditingController();
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> _archiveNotification(String docId, bool archive) async {
    try {
      await _client
          .from('customer_notifications')
          .update({'is_archived': archive})
          .eq('id', docId);
      Get.snackbar("Success", archive ? "Notification archived." : "Notification restored.");
    } catch (e) {
      Get.snackbar("Error", "Action failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Notifications Inbox", style: AppTheme.serifHeader(fontSize: 24)),
              TextButton.icon(
                icon: const Icon(Icons.done_all, color: Color(0xFFC9A77E), size: 18),
                label: const Text("Mark All Read", style: TextStyle(color: Color(0xFFC9A77E), fontSize: 13)),
                onPressed: () {
                  for (var notif in widget.controller.rxNotifications) {
                    widget.controller.markNotificationRead(notif.id);
                  }
                  Get.snackbar("Success", "All notifications marked as read.");
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          
          // Search Input
          TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Color(0xFFC9A77E)),
              hintText: "Search alerts by title or content...",
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.black26,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFC9A77E)),
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
                'Booking',
                'Payment',
                'Announcement',
                'Archived',
              ].map((category) {
                final isSelected = activeCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.white70)),
                    selected: isSelected,
                    selectedColor: const Color(0xFFC9A77E),
                    backgroundColor: const Color(0xFF12271F),
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
                // Parse optional archived flag from raw document or default false
                final isArchived = n.isArchived;
                
                final matchQuery = n.title.toLowerCase().contains(notificationQuery) || n.body.toLowerCase().contains(notificationQuery);
                
                bool matchCategory = false;
                if (activeCategory == 'All') {
                  matchCategory = !isArchived; // Don't show archived in general list
                } else if (activeCategory == 'Archived') {
                  matchCategory = isArchived;
                } else {
                  matchCategory = !isArchived && n.type == activeCategory;
                }

                return matchQuery && matchCategory;
              }).toList();

              if (list.isEmpty) {
                return const Center(child: Text("No notifications matching current filters."));
              }

              return ListView.builder(
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
                        return const SizedBox.shrink(); // Hide expired notification
                      }
                    } catch (_) {}
                  }

                  Color priorityColor = Colors.grey;
                  if (priority == 'high') priorityColor = Colors.redAccent;
                  if (priority == 'low') priorityColor = Colors.green;

                  return Card(
                    color: notif.isRead ? const Color(0xFF12271F).withAlpha(128) : const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      leading: Icon(
                        notif.isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                        color: const Color(0xFFC9A77E),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(notif.title, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)),
                          ),
                          if (priority == 'high')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: priorityColor.withAlpha(51),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text("HIGH PRIORITY", style: TextStyle(color: priorityColor, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notif.body, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          if (expiresAtStr != null) ...[
                            const SizedBox(height: 4),
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
                        onPressed: () => _archiveNotification(notif.id, activeCategory != 'Archived'),
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
