import '../../domain/entities/customer_notification.dart';

abstract class NotificationRepository {
  Future<Map<String, dynamic>?> getPreferences(String customerId);
  Future<void> savePreferences(String customerId, Map<String, dynamic> preferences);
  Stream<List<CustomerNotification>> getNotifications(String customerId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String customerId);
  Future<void> archiveNotification(String notificationId, bool isArchived);
}
