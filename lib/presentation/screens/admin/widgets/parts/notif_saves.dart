part of '../settings_notifications_tab.dart';

extension _NotifSavesExtension on _SettingsNotificationsTabState {
  void _saveGatewaySettings() {
    NotificationGatewayService.to.updateCredentials(
      resendApiKey: resendKeyCtrl.text,
      whatsappToken: whatsappTokenCtrl.text,
      whatsappPhoneId: whatsappPhoneIdCtrl.text,
      whatsappBusinessId: whatsappBusinessIdCtrl.text,
      senderEmail: senderEmailCtrl.text,
    );
    Get.snackbar("Success", "Notification settings saved successfully.");
  }

  Future<void> _retryFailedTasks() async {
    try {
      final snap = await _firestore
          .collection(AppCollections.notificationQueue)
          .where('status', whereIn: ['failed', 'retry'])
          .get();

      if (snap.docs.isEmpty) {
        Get.snackbar("Outbox Empty", "No failed tasks found in the queue.");
        return;
      }

      final batch = _firestore.batch();
      for (var doc in snap.docs) {
        batch.update(doc.reference, {
          'status': 'pending',
          'retryCount': 0,
          'errorMessage': '',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      Get.snackbar("Queued", "Retrying ${snap.docs.length} failed tasks.");
    } catch (e) {
      Get.snackbar("Error", "Retry failed: $e");
    }
  }

  Future<void> _retrySingleTask(String taskId) async {
    try {
      await _firestore
          .collection(AppCollections.notificationQueue)
          .doc(taskId)
          .update({
        'status': 'pending',
        'retryCount': 0,
        'errorMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar("Queued", "Retrying single outbox task.");
    } catch (e) {
      Get.snackbar("Error", "Retry failed: $e");
    }
  }

  Future<void> _retryDlqTask(String dlqId, Map<String, dynamic> payload) async {
    try {
      final batch = _firestore.batch();
      final queueRef =
          _firestore.collection(AppCollections.notificationQueue).doc(dlqId);

      batch.set(queueRef, {
        ...payload,
        'status': 'pending',
        'retryCount': 0,
        'errorMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final dlqRef =
          _firestore.collection(AppCollections.deadLetterNotifications).doc(dlqId);
      batch.delete(dlqRef);

      await batch.commit();
      Get.snackbar("Success", "Task re-queued & removed from DLQ.");
    } catch (e) {
      Get.snackbar("Error", "Retry failed: $e");
    }
  }

  Future<void> _deleteDlqTask(String dlqId) async {
    try {
      await _firestore
          .collection(AppCollections.deadLetterNotifications)
          .doc(dlqId)
          .delete();
      Get.snackbar("Deleted", "Task permanently deleted from DLQ.");
    } catch (e) {
      Get.snackbar("Error", "Deletion failed: $e");
    }
  }

  void _exportDlqTask(Map<String, dynamic> dlqData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("DLQ Raw Payload"),
          content: SingleChildScrollView(
            child: Text(
              const JsonEncoder.withIndent("  ").convert(dlqData),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportDeliveryLogs() async {
    try {
      final snap =
          await _firestore.collection(AppCollections.notificationLogs).get();
      if (snap.docs.isEmpty) {
        Get.snackbar("Empty Logs", "No logs registered to export.");
        return;
      }

      final List<Map<String, dynamic>> logs =
          snap.docs.map((d) => d.data()).toList();
      final jsonStr = const JsonEncoder.withIndent("  ").convert(logs);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Exported Logs (JSON)"),
          content: SizedBox(
            width: 400,
            height: 300,
            child: SingleChildScrollView(
              child: SelectableText(
                jsonStr,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar("Error", "Export failed: $e");
    }
  }
}
