import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/network_image.dart';
import '../../core/components/retryable_error_view.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/models/notification_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/notification_provider.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final userUid = ref.watch(authProvider);
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Notification'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: userUid.when(
              data: (uid) => uid != null
                  ? TextButton(
                      onPressed: () {
                        ref
                            .read(notificationsProvider.notifier)
                            .markAllAsRead(uid);
                      },
                      child: const Text('Mark All Read'),
                    )
                  : const SizedBox(),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final uid = userUid.whenData((uid) => uid);
              uid.whenData((uid) {
                if (uid != null) {
                  ref.read(notificationsProvider.notifier).refresh(uid);
                }
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: AppDefaults.padding),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () {
                    userUid.whenData((uid) {
                      if (uid != null) {
                        ref
                            .read(notificationsProvider.notifier)
                            .markAsRead(uid, notification.id);
                      }
                    });
                  },
                  onDelete: () {
                    userUid.whenData((uid) {
                      if (uid != null) {
                        ref
                            .read(notificationsProvider.notifier)
                            .deleteNotification(uid, notification.id);
                      }
                    });
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => RetryableErrorView(
          title: 'Error loading notifications',
          message: 'Please try again in a moment.',
          onRetry: () {
            final uid = userUid.value;
            if (uid != null && uid.isNotEmpty) {
              ref.read(notificationsProvider.notifier).refresh(uid);
            } else {
              ref.invalidate(notificationsProvider);
            }
          },
        ),
      ),
    );
  }
}

/// Notification Tile Component
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  /// Format timestamp to relative time
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  notification.imageUrl != null &&
                      notification.imageUrl!.isNotEmpty
                  ? Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1 / 1,
                          child: NetworkImageWithLoader(notification.imageUrl!),
                        ),
                        if (!notification.isRead)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
              title: Text(
                notification.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: notification.isRead
                      ? FontWeight.normal
                      : FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (String result) {
                  if (result == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 86),
              child: Divider(thickness: 0.1),
            ),
          ],
        ),
      ),
    );
  }
}
