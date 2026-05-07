import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/announcements/data/announcement_repository.dart';
import 'package:tsiwa_mahber/features/announcements/domain/announcement.dart';
import 'package:tsiwa_mahber/features/announcements/domain/read_receipt.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;

class AnnouncementDetailScreen extends StatefulWidget {
  final String areaId;
  final String announcementId;
  final AppUser? currentUser;

  const AnnouncementDetailScreen({
    super.key,
    required this.areaId,
    required this.announcementId,
    this.currentUser,
  });

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState
    extends State<AnnouncementDetailScreen> {
  final _repository = AnnouncementRepository();
  bool _hasAutoMarked = false;

  bool get _isDev =>
      widget.currentUser?.role == UserRole.developer;
  bool get _isAdmin =>
      widget.currentUser?.role.canEdit ?? false;

  bool get _canSeeReadReceipts {
    final role = widget.currentUser?.role;
    if (role == null) return false;
    return role.canEdit || role.isDeveloper;
  }

  void _autoMarkAsRead() {
    if (_hasAutoMarked) return;
    final userId = widget.currentUser?.uid ?? '';
    if (userId.isEmpty) return;
    _hasAutoMarked = true;
    _repository.markAsRead(
      areaId: widget.areaId,
      announcementId: widget.announcementId,
      userId: userId,
      userName: widget.currentUser?.displayName ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Announcement?>(
      stream: _repository.watchAnnouncement(
          widget.areaId, widget.announcementId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(S.announcement)),
            body: Center(
              child: Text(
                S.dataLoadFailed,
                style: TextStyle(color: Colors.red.shade300),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(S.announcement)),
            body: LoadingState(message: S.loading),
          );
        }

        final announcement = snapshot.data;
        if (announcement == null) {
          return Scaffold(
            appBar: AppBar(title: Text(S.announcement)),
            body: Center(child: Text(S.announcementNotFound)),
          );
        }

        _autoMarkAsRead();

        return Scaffold(
          appBar: AppBar(
            title: Text(S.announcement),
            actions: [
              if (_isDev || _isAdmin)
                IconButton(
                  icon: const Icon(Icons.notifications_active,
                      color: Colors.orange),
                  tooltip: S.ringBell,
                  onPressed: () =>
                      _ringBell(announcement),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(announcement),
                const SizedBox(height: 16),
                _buildBody(announcement),
                const SizedBox(height: 24),
                if (_canSeeReadReceipts)
                  _buildReadReceipts(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Announcement announcement) {
    final priorityColor = switch (announcement.priority) {
      AnnouncementPriority.urgent => Colors.red,
      AnnouncementPriority.important => Colors.orange,
      AnnouncementPriority.normal => AppTheme.primary,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (announcement.priority !=
                    AnnouncementPriority.normal)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color:
                          priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      announcement.priority.displayName,
                      style: TextStyle(
                          fontSize: 12, color: priorityColor),
                    ),
                  ),
                Expanded(
                  child: Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 14,
                    color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  announcement.authorName,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(width: 16),
                if (announcement.createdAt != null) ...[
                  const Icon(Icons.access_time, size: 14,
                      color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(announcement.createdAt!),
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textMuted),
                  ),
                ],
              ],
            ),
            if (_canSeeReadReceipts) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.visibility, size: 14,
                      color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${announcement.readCount} ሰው አንብበዋል',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Announcement announcement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            announcement.body,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
      ),
    );
  }

  Widget _buildReadReceipts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.readBy,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<ReadReceipt>>(
          stream: _repository.watchReadReceipts(
              widget.areaId, widget.announcementId),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                    child: CircularProgressIndicator()),
              );
            }

            final receipts = snapshot.data ?? [];

            if (receipts.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  S.noOneReadYet,
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              );
            }

            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: receipts.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1),
                itemBuilder: (context, index) {
                  final receipt = receipts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primary
                          .withValues(alpha: 0.15),
                      child: Text(
                        receipt.userName.isNotEmpty
                            ? receipt.userName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12),
                      ),
                    ),
                    title: Text(receipt.userName,
                        style: const TextStyle(fontSize: 14)),
                    trailing: receipt.readAt != null
                        ? Text(
                            DateFormat('dd/MM HH:mm')
                                .format(receipt.readAt!),
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted),
                          )
                        : null,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _ringBell(Announcement announcement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.ringBell),
        content: Text(S.ringBellConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.ringBell),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await fs.FirebaseFirestore.instance
        .collection('areas/${widget.areaId}/ringBell')
        .add({
      'title': announcement.title,
      'body': announcement.body.length > 100
          ? '${announcement.body.substring(0, 100)}...'
          : announcement.body,
      'announcementId': widget.announcementId,
      'triggeredBy': widget.currentUser?.displayName ?? '',
      'createdAt': fs.FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.ringBellSent)),
      );
    }
  }
}
