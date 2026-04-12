import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

/// Notifier for managing notification state
class NotificationNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationService _service = NotificationService();
  final Ref _ref;
  StreamSubscription<List<NotificationModel>>? _subscription;

  NotificationNotifier(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen<AsyncValue<String?>>(authProvider, (_, next) {
      next.whenData((uid) {
        if (uid == null || uid.isEmpty) {
          state = const AsyncValue.data([]);
          return;
        }
        _loadNotifications(uid);
      });
    });

    _ref.read(authProvider).whenData((uid) {
      if (uid != null && uid.isNotEmpty) {
        _loadNotifications(uid);
      }
    });
  }

  /// Load notifications from service
  Future<void> _loadNotifications(String userId) async {
    try {
      state = const AsyncValue.loading();
      _subscription?.cancel();
      _subscription = _service
          .getNotificationsStream(userId)
          .listen(
            (notifications) {
              state = AsyncValue.data(notifications);
            },
            onError: (error, stackTrace) {
              state = AsyncValue.error(error, stackTrace);
            },
          );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _service.markAsRead(userId, notificationId);
      final current = state.whenData((list) => list);
      current.whenData((list) {
        final updated = list
            .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
            .toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _service.deleteNotification(userId, notificationId);
      final current = state.whenData((list) => list);
      current.whenData((list) {
        final updated = list.where((n) => n.id != notificationId).toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final current = state.whenData((list) => list);
      current.whenData((list) {
        final updated = list.map((n) => n.copyWith(isRead: true)).toList();
        state = AsyncValue.data(updated);
      });
      await _service.markAllAsRead(
        userId,
        current.whenData((list) => list).value ?? [],
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Refresh notifications
  Future<void> refresh(String userId) async {
    await _loadNotifications(userId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Notifications provider using StateNotifierProvider
final notificationsProvider =
    StateNotifierProvider<
      NotificationNotifier,
      AsyncValue<List<NotificationModel>>
    >((ref) {
      return NotificationNotifier(ref);
    });

/// Real-time notifications stream provider
final notificationsStreamProvider = StreamProvider.autoDispose
    .family<List<NotificationModel>, String>((ref, userId) {
      return NotificationService().getNotificationsStream(userId);
    });

/// Unread notifications count provider
final unreadNotificationsCountProvider = FutureProvider.autoDispose
    .family<int, String>((ref, userId) async {
      return NotificationService().getUnreadCount(userId);
    });
