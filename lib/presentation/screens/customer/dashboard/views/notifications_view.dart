import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  String notificationFilter = 'All';
  final searchController = TextEditingController();

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
              Text("Notifications Center", style: AppTheme.serifHeader(fontSize: 24)),
              TextButton(
                onPressed: () {
                  for (var notif in widget.controller.rxNotifications) {
                    widget.controller.markNotificationRead(notif.id);
                  }
                  Get.snackbar("Success", "All notifications marked as read.");
                },
                child: const Text("Mark All Read", style: TextStyle(color: Color(0xFFC9A77E))),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Color(0xFFC9A77E)),
                    hintText: "Search alerts...",
                    hintStyle: TextStyle(color: Colors.white30),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.black12,
                  ),
                  onChanged: (val) {
                    setState(() => notificationQuery = val.toLowerCase());
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: notificationFilter,
                dropdownColor: const Color(0xFF12271F),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text("All Categories", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Booking', child: Text("Booking Status", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Payment', child: Text("Payments", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Reminder', child: Text("Reminders", style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => notificationFilter = val);
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Obx(() {
              var list = widget.controller.rxNotifications.where((n) {
                final matchQuery = n.title.toLowerCase().contains(notificationQuery) || n.body.toLowerCase().contains(notificationQuery);
                final matchFilter = notificationFilter == 'All' || n.type == notificationFilter;
                return matchQuery && matchFilter;
              }).toList();

              if (list.isEmpty) {
                return const Center(child: Text("No alerts matched your search filters."));
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final notif = list[index];
                  return Card(
                    color: notif.isRead ? const Color(0xFF12271F).withValues(alpha: 0.5) : const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        notif.isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                        color: const Color(0xFFC9A77E),
                      ),
                      title: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(notif.body),
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
