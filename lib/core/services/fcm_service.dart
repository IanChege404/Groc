import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';

/// Firebase Cloud Messaging service for push notifications
class FcmService {
  static final FcmService _instance = FcmService._internal();

  factory FcmService() => _instance;

  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Request notification permissions from the user
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final granted = settings.authorizationStatus ==
        AuthorizationStatus.authorized;
    Logger.info(
      'FCM permission: ${settings.authorizationStatus}',
      'FcmService',
    );
    return granted;
  }

  /// Get the current FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      Logger.error('Failed to get FCM token: $e', 'FcmService');
      return null;
    }
  }

  /// Save FCM token to Firestore for the given user
  Future<void> saveTokenToFirestore(String userId) async {
    try {
      final token = await getToken();
      if (token == null) return;

      await _firestore.collection('users').doc(userId).set(
        {
          'fcmToken': token,
          'fcmTokenUpdatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );

      Logger.info('FCM token saved for user $userId', 'FcmService');
    } catch (e) {
      Logger.error('Failed to save FCM token: $e', 'FcmService');
    }
  }

  /// Remove FCM token on logout
  Future<void> removeTokenFromFirestore(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set(
        {'fcmToken': FieldValue.delete()},
        SetOptions(merge: true),
      );
      await _messaging.deleteToken();
      Logger.info('FCM token removed for user $userId', 'FcmService');
    } catch (e) {
      Logger.error('Failed to remove FCM token: $e', 'FcmService');
    }
  }

  /// Initialise message handlers and return a Stream of incoming messages
  void initialize({
    required void Function(RemoteMessage) onForegroundMessage,
    required void Function(RemoteMessage) onBackgroundMessageTap,
  }) {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      Logger.info(
        'FCM foreground message: ${message.messageId}',
        'FcmService',
      );
      onForegroundMessage(message);
    });

    // Background message tapped
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Logger.info('FCM notification tapped: ${message.messageId}', 'FcmService');
      onBackgroundMessageTap(message);
    });

    // Handle token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      Logger.info('FCM token refreshed', 'FcmService');
    });
  }

  /// Subscribe to a topic (e.g. 'promotions', 'deals')
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      Logger.info('Subscribed to FCM topic: $topic', 'FcmService');
    } catch (e) {
      Logger.error('Failed to subscribe to topic $topic: $e', 'FcmService');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      Logger.error('Failed to unsubscribe from topic $topic: $e', 'FcmService');
    }
  }
}
