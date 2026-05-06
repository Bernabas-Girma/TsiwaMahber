import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/empty_state.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/notifications/data/notification_repository.dart';
import 'package:tsiwa_mahber/features/notifications/domain/app_notification.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class NotificationListScreen extends StatefulWidget {
  final String userId;

  const NotificationListScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationListScreen> createState() =>
      _NotificationListScreenState();
}

class _NotificationListScreenState
    extends State<NotificationListScreen> {
  final _repository = NotificationRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.notifications),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'read_all') {
                _repository.markAllAsRead(widget.userId);
              } else if (value == 'clear_all') {
                _confirmClearAll();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'read_all',
                child: Text(S.markAllRead),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Text(S.clearAll,
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _repository.watchNotifications(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                S.dataLoadFailed,
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingState(message: S.loading);
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_none,
              title: S.noNotifications,
              message: '',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: notifications.length,
            itemBuilder: (context, index) =>
                _buildNotificationTile(notifications[index]),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(AppNotification notification) {
    final typeIcon = switch (notification.type) {
      NotificationType.announcement => Icons.campaign,
      NotificationType.event => Icons.event,
      NotificationType.payment => Icons.payment,
      NotificationType.turnReminder => Icons.alarm,
      NotificationType.turnAlert => Icons.notifications_active,
      NotificationType.system => Icons.info,
    };

    final typeColor = switch (notification.type) {
      NotificationType.announcement => AppTheme.primary,
      NotificationType.event => Colors.blue,
      NotificationType.payment => Colors.green,
      NotificationType.turnReminder => Colors.orange,
      NotificationType.turnAlert => Colors.red,
      NotificationType.system => Colors.grey,
    };

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        _repository.deleteNotification(
            widget.userId, notification.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        color: notification.isRead
            ? null
            : AppTheme.primary.withValues(alpha: 0.05),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!notification.isRead) {
              _repository.markAsRead(
                  widget.userId, notification.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                      if (notification.body.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          notification.body.length > 60
                              ? '${notification.body.substring(0, 60)}...'
                              : notification.body,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            notification.type.displayName,
                            style: TextStyle(
                                fontSize: 11, color: typeColor),
                          ),
                          const Spacer(),
                          if (notification.createdAt != null)
                            Text(
                              _formatTime(notification.createdAt!),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'አሁን';
    if (diff.inMinutes < 60) return '${diff.inMinutes} ደቂቃ';
    if (diff.inHours < 24) return '${diff.inHours} ሰአት';
    if (diff.inDays < 7) return '${diff.inDays} ቀን';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.clearAllConfirm),
        content:
            Text(S.clearAllConfirmMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ተው'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.clear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.clearAll(widget.userId);
    }
  }
}
