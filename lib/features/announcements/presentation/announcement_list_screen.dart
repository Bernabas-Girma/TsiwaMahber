import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/confirm_dialog.dart';
import 'package:tsiwa_mahber/core/widgets/empty_state.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/announcements/data/announcement_repository.dart';
import 'package:tsiwa_mahber/features/announcements/domain/announcement.dart';
import 'package:tsiwa_mahber/features/announcements/presentation/announcement_detail_screen.dart';
import 'package:tsiwa_mahber/features/announcements/presentation/announcement_form_screen.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/features/notifications/data/notification_repository.dart';
import 'package:tsiwa_mahber/features/notifications/domain/app_notification.dart';

class AnnouncementListScreen extends StatefulWidget {
  final String areaId;
  final AppUser? currentUser;

  const AnnouncementListScreen({
    super.key,
    required this.areaId,
    this.currentUser,
  });

  @override
  State<AnnouncementListScreen> createState() =>
      _AnnouncementListScreenState();
}

class _AnnouncementListScreenState
    extends State<AnnouncementListScreen> {
  final _repository = AnnouncementRepository();
  final _notificationRepository = NotificationRepository();

  bool get _canCreate {
    final role = widget.currentUser?.role;
    if (role == null) return false;
    if (role.canEdit) return true;
    final user = widget.currentUser!;
    return user.tsiwaRoles.values.any((r) => r == 'muse');
  }

  bool _canSeeAnnouncement(Announcement a) {
    final user = widget.currentUser;
    if (user == null) return true;
    if (user.role.canEdit) return true;

    if (a.targetType == AnnouncementTarget.all) return true;
    if (a.targetType == AnnouncementTarget.tsiwa) {
      return user.assignedTsiwaIds.contains(a.targetId);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ማሳሰቢያዎች / መልእክቶች'),
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: _repository.watchAnnouncements(widget.areaId),
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

          final all = snapshot.data ?? [];
          final announcements =
              all.where(_canSeeAnnouncement).toList();

          if (announcements.isEmpty) {
            return EmptyState(
              icon: Icons.campaign,
              title: S.noAnnouncementsYet,
              message: _canCreate
                  ? S.addAnnouncementHint
                  : '',
              action: _canCreate
                  ? ElevatedButton.icon(
                      onPressed: _openCreateForm,
                      icon: const Icon(Icons.add),
                      label: Text(S.newAnnouncement),
                    )
                  : null,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: announcements.length,
            itemBuilder: (context, index) =>
                _buildAnnouncementCard(announcements[index]),
          );
        },
      ),
      floatingActionButton: _canCreate
          ? FloatingActionButton(
              onPressed: _openCreateForm,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    final priorityColor = switch (announcement.priority) {
      AnnouncementPriority.urgent => Colors.red,
      AnnouncementPriority.important => Colors.orange,
      AnnouncementPriority.normal => AppTheme.primary,
    };

    final priorityIcon = switch (announcement.priority) {
      AnnouncementPriority.urgent => Icons.warning,
      AnnouncementPriority.important => Icons.priority_high,
      AnnouncementPriority.normal => Icons.campaign,
    };

    final userId = widget.currentUser?.uid ?? '';
    final isAdmin = widget.currentUser?.role.canEdit == true;
    final isDev = widget.currentUser?.role.isDeveloper == true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailScreen(
                areaId: widget.areaId,
                announcementId: announcement.id,
                currentUser: widget.currentUser,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(priorityIcon, color: priorityColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (announcement.priority !=
                            AnnouncementPriority.normal)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              announcement.priority.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                color: priorityColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (announcement.targetType ==
                            AnnouncementTarget.tsiwa &&
                        announcement.targetName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          announcement.targetName,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.deepPurple.shade300,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      announcement.body.length > 80
                          ? '${announcement.body.substring(0, 80)}...'
                          : announcement.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          announcement.authorName,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted),
                        ),
                        const Spacer(),
                        StreamBuilder<bool>(
                          stream: userId.isNotEmpty
                              ? _repository.watchHasUserRead(
                                  widget.areaId,
                                  announcement.id,
                                  userId)
                              : Stream.value(false),
                          builder: (context, readSnapshot) {
                            final hasRead =
                                readSnapshot.data ?? false;
                            return Row(
                              children: [
                                Icon(
                                  hasRead
                                      ? Icons.done_all
                                      : Icons.done,
                                  size: 14,
                                  color: hasRead
                                      ? Colors.blue
                                      : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${announcement.readCount} አንብበዋል',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openEditForm(announcement);
                    } else if (value == 'delete') {
                      _confirmDelete(announcement);
                    } else if (value == 'resend') {
                      _resendNotification(announcement);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(S.edit),
                    ),
                    PopupMenuItem(
                      value: 'resend',
                      child: Text(S.resendNotification),
                    ),
                    if (widget.currentUser?.role.canDelete == true)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(S.delete,
                            style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                )
              else if (isDev)
                IconButton(
                  icon: const Icon(Icons.replay, size: 20),
                  tooltip: S.resendNotification,
                  onPressed: () => _resendNotification(announcement),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCreateForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementFormScreen(
          areaId: widget.areaId,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  void _openEditForm(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementFormScreen(
          areaId: widget.areaId,
          announcement: announcement,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  Future<void> _resendNotification(Announcement announcement) async {
    final notification = AppNotification(
      title: 'ማሳሰቢያ / መልእክት: ${announcement.title}',
      body: announcement.body.length > 100
          ? '${announcement.body.substring(0, 100)}...'
          : announcement.body,
      type: NotificationType.announcement,
      senderId: widget.currentUser?.uid,
      senderName: widget.currentUser?.displayName,
    );

    if (announcement.targetType == AnnouncementTarget.tsiwa &&
        announcement.targetId.isNotEmpty) {
      await _notificationRepository.sendNotificationToTsiwaMembers(
        tsiwaId: announcement.targetId,
        notification: notification,
      );
    } else {
      await _notificationRepository.sendNotificationToAll(
        areaId: widget.areaId,
        notification: notification,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.notificationResent)),
      );
    }
  }

  Future<void> _confirmDelete(Announcement announcement) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: S.deleteAnnouncement,
      message:
          '"${announcement.title}" ለመሰረዝ እርግጠኛ ነዎት?',
      confirmText: S.delete,
    );

    if (confirmed == true) {
      try {
        await _repository.deleteAnnouncement(
            widget.areaId, announcement.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.announcementDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ስህተት: $e')),
          );
        }
      }
    }
  }
}
