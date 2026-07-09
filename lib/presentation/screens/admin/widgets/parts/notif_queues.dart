part of '../settings_notifications_tab.dart';

extension _NotifQueuesExtension on _SettingsNotificationsTabState {
  Widget _buildScheduledCronReminders() {
    return _buildCard(
      title: "SCHEDULED CRON REMINDERS QUEUE",
      children: [
        const Text(
          "Reminders automatically processed by Cloud Scheduler cron triggers.",
          style: TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection(AppCollections.scheduledNotifications)
                .orderBy('triggerAt', descending: false)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No scheduled reminders pending.",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                );
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final rem = docs[index].data();
                  final isSent = rem['status'] == 'sent';
                  final channel = (rem['channel'] ?? 'email')
                      .toString()
                      .toUpperCase();

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "${rem['title'] ?? 'Reminder'} [$channel]",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      "Trigger Date: ${rem['triggerAt'] != null ? (rem['triggerAt'] as Timestamp).toDate().toString().split('.')[0] : 'Pending'}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSent
                            ? Colors.green.withAlpha(26)
                            : Colors.orange.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSent
                              ? Colors.green.withAlpha(102)
                              : Colors.orange.withAlpha(102),
                        ),
                      ),
                      child: Text(
                        isSent ? "SENT" : "PENDING",
                        style: TextStyle(
                          color: isSent ? Colors.green : Colors.orange,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOutboxDeliveryQueue() {
    return _buildCard(
      title: "OUTBOX DELIVERY QUEUE",
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Asynchronous Queue Tasks",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry All Failed"),
              onPressed: _retryFailedTasks,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection(AppCollections.notificationQueue)
                .orderBy('updatedAt', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No tasks in outbox queue.",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final task = docs[index].data();
                  final taskId = docs[index].id;
                  final status = task['status'] ?? 'pending';
                  final channel = (task['channel'] ?? 'push')
                      .toString()
                      .toUpperCase();
                  final recipient = task['recipient'] ?? '';

                  Color statusColor = Colors.grey;
                  if (status == 'sent') statusColor = Colors.green;
                  if (status == 'processing') statusColor = Colors.blue;
                  if (status == 'failed' || status == 'retry') {
                    statusColor = Colors.red;
                  }

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "${task['title'] ?? 'Task'} [$channel]",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recipient: $recipient | Retries: ${task['retryCount'] ?? 0}",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        if (task['errorMessage'] != null &&
                            task['errorMessage'].toString().isNotEmpty)
                          Text(
                            "Error: ${task['errorMessage']}",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withAlpha(102),
                            ),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (status == 'failed' || status == 'retry') ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.replay,
                              color: Colors.orange,
                              size: 18,
                            ),
                            onPressed: () => _retrySingleTask(taskId),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeadLetterQueue() {
    return _buildCard(
      title: "DEAD LETTER QUEUE (DLQ)",
      children: [
        TextField(
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: const InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xFFC9A77E),
              size: 16,
            ),
            hintText: "Search dead letter logs...",
            hintStyle: TextStyle(color: Colors.white30),
            fillColor: Colors.black12,
            filled: true,
          ),
          onChanged: (val) {
            updateState(() => dlqSearchQuery = val.toLowerCase());
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection(AppCollections.deadLetterNotifications)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs.where((d) {
                final reason = (d['reason'] ?? '').toString().toLowerCase();
                return reason.contains(dlqSearchQuery);
              }).toList();

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "Dead letter queue is empty.",
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                );
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final dlq = doc.data();
                  final dlqId = doc.id;
                  final payload = Map<String, dynamic>.from(
                    dlq['payload'] ?? {},
                  );

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Reason: ${dlq['reason'] ?? 'Execution Error'} [${dlq['channel'] ?? 'PUSH'}]",
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      "Retries: ${dlq['retryCount'] ?? 5} | Timestamp: ${dlq['timestamp'] ?? 'Now'}",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.green,
                            size: 20,
                          ),
                          tooltip: "Retry & Delete from DLQ",
                          onPressed: () => _retryDlqTask(dlqId, payload),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          tooltip: "Inspect Raw Payload",
                          onPressed: () => _exportDlqTask(dlq),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          tooltip: "Delete Permanently",
                          onPressed: () => _deleteDlqTask(dlqId),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSystemAuditLogs() {
    return _buildCard(
      title: "NOTIFICATION SYSTEM AUDIT LOGS",
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFFC9A77E),
                    size: 16,
                  ),
                  hintText: "Search audit logs...",
                  hintStyle: TextStyle(color: Colors.white30),
                  fillColor: Colors.black12,
                  filled: true,
                ),
                onChanged: (val) {
                  updateState(() => logSearchQuery = val.toLowerCase());
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A77E),
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.download, size: 16),
              label: const Text("Export Logs"),
              onPressed: _exportDeliveryLogs,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection(AppCollections.notificationLogs)
                .orderBy('sentAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs.where((d) {
                final title = (d['title'] ?? '').toString().toLowerCase();
                final body = (d['body'] ?? '').toString().toLowerCase();
                final recipient =
                    (d['recipientId'] ?? '').toString().toLowerCase();
                return title.contains(logSearchQuery) ||
                    body.contains(logSearchQuery) ||
                    recipient.contains(logSearchQuery);
              }).toList();

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No notification logs registered.",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              return ListView.builder(
                itemCount: docs.length > 20 ? 20 : docs.length,
                itemBuilder: (context, index) {
                  final log = docs[index].data();
                  final status = log['status'] ?? 'sent';
                  final channels =
                      (log['channelsUsed'] as List? ?? []).join(', ').toUpperCase();
                  final variant = log['variant'] ?? 'Variant A';

                  Color statusColor = Colors.grey;
                  if (status == 'sent') statusColor = Colors.green;
                  if (status == 'delivered') statusColor = Colors.teal;
                  if (status == 'opened' || status == 'read') {
                    statusColor = Colors.blue;
                  }
                  if (status == 'clicked') statusColor = Colors.purple;
                  if (status == 'failed') statusColor = Colors.red;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "${log['title'] ?? 'Notification Log'} [$variant]",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      "Recipient: ${log['recipientId']} | Channels: $channels",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withAlpha(102),
                            ),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log['sentAt'] != null
                              ? (log['sentAt'] as Timestamp)
                                  .toDate()
                                  .toString()
                                  .split('.')[0]
                              : 'Now',
                          style: const TextStyle(
                            color: Colors.white24,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
