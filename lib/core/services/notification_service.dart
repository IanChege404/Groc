import '../models/notification_model.dart';
import '../utils/logger.dart';
import 'firestore_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FirestoreService _firestoreService;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _firestoreService = FirestoreService();
  }

  /// Get real-time stream of notifications
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestoreService.getNotificationsStream(userId);
  }

  /// Get one-time fetch of notifications
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      return await _firestoreService.getNotifications(userId);
    } catch (e) {
      Logger.error(
        'Error getting notifications: $e',
        'NotificationService.getNotifications',
      );
      return [];
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(userId, notificationId);
      Logger.info(
        'Notification marked as read',
        'NotificationService.markAsRead',
      );
    } catch (e) {
      Logger.error(
        'Error marking notification as read: $e',
        'NotificationService.markAsRead',
      );
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _firestoreService.deleteNotification(userId, notificationId);
      Logger.info(
        'Notification deleted',
        'NotificationService.deleteNotification',
      );
    } catch (e) {
      Logger.error(
        'Error deleting notification: $e',
        'NotificationService.deleteNotification',
      );
      rethrow;
    }
  }

  /// Add a new notification
  Future<void> addNotification(
    String userId,
    NotificationModel notification,
  ) async {
    try {
      await _firestoreService.addNotification(userId, notification);
      Logger.info('Notification added', 'NotificationService.addNotification');
    } catch (e) {
      Logger.error(
        'Error adding notification: $e',
        'NotificationService.addNotification',
      );
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(
    String userId,
    List<NotificationModel> notifications,
  ) async {
    try {
      for (final notification in notifications.where((n) => !n.isRead)) {
        await markAsRead(userId, notification.id);
      }
      Logger.info(
        'All notifications marked as read',
        'NotificationService.markAllAsRead',
      );
    } catch (e) {
      Logger.error(
        'Error marking all notifications as read: $e',
        'NotificationService.markAllAsRead',
      );
      rethrow;
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount(String userId) async {
    try {
      final notifications = await getNotifications(userId);
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      Logger.error(
        'Error getting unread count: $e',
        'NotificationService.getUnreadCount',
      );
      return 0;
    }
  }
}
