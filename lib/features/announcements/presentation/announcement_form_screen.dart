import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/features/announcements/data/announcement_repository.dart';
import 'package:tsiwa_mahber/features/announcements/domain/announcement.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/notifications/data/notification_repository.dart';
import 'package:tsiwa_mahber/features/notifications/data/telegram_service.dart';
import 'package:tsiwa_mahber/features/notifications/domain/app_notification.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class AnnouncementFormScreen extends StatefulWidget {
  final String areaId;
  final Announcement? announcement;
  final AppUser? currentUser;

  const AnnouncementFormScreen({
    super.key,
    required this.areaId,
    this.announcement,
    this.currentUser,
  });

  @override
  State<AnnouncementFormScreen> createState() =>
      _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState
    extends State<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AnnouncementRepository();
  final _notificationRepository = NotificationRepository();
  final _telegramService = TelegramService();
  final _tsiwaRepository = TsiwaRepository();

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late AnnouncementPriority _priority;
  AnnouncementTarget _targetType = AnnouncementTarget.all;
  String _selectedTsiwaId = '';
  String _selectedTsiwaName = '';
  bool _isSaving = false;
  List<TsiwaMahber> _tsiwas = [];

  bool get _isEditing => widget.announcement != null;

  bool get _isAmerar {
    final role = widget.currentUser?.role;
    return role == UserRole.developer ||
        role == UserRole.admin ||
        role == UserRole.leader;
  }

  bool get _isMuse {
    final user = widget.currentUser;
    if (user == null) return false;
    return user.tsiwaRoles.values.any((r) => r == 'muse');
  }

  List<String> get _museTsiwaIds {
    final user = widget.currentUser;
    if (user == null) return [];
    return user.tsiwaRoles.entries
        .where((e) => e.value == 'muse')
        .map((e) => e.key)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
        text: widget.announcement?.title ?? '');
    _bodyController = TextEditingController(
        text: widget.announcement?.body ?? '');
    _priority = widget.announcement?.priority ??
        AnnouncementPriority.normal;
    if (widget.announcement != null) {
      _targetType = widget.announcement!.targetType;
      _selectedTsiwaId = widget.announcement!.targetId;
      _selectedTsiwaName = widget.announcement!.targetName;
    }

    if (!_isAmerar && _isMuse) {
      _targetType = AnnouncementTarget.tsiwa;
      if (_museTsiwaIds.length == 1) {
        _selectedTsiwaId = _museTsiwaIds.first;
      }
    }

    _loadTsiwas();
  }

  Future<void> _loadTsiwas() async {
    final stream =
        _tsiwaRepository.watchTsiwas(widget.areaId);
    stream.first.then((list) {
      if (mounted) setState(() => _tsiwas = list);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? S.editAnnouncement
            : S.newAnnouncement),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'ርዕስ *',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.titleRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: S.detail,
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.detailRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AnnouncementPriority>(
              initialValue: _priority,
              decoration: InputDecoration(
                labelText: S.level,
              ),
              items: AnnouncementPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 16),
              _buildTargetSelector(),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? S.save : S.create),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelector() {
    final canPostAll = _isAmerar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.postTo,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        RadioGroup<AnnouncementTarget>(
          groupValue: _targetType,
          onChanged: (v) {
            if (v != null) setState(() => _targetType = v);
          },
          child: Column(
            children: [
              if (canPostAll)
                RadioListTile<AnnouncementTarget>(
                  title: Text(S.allMembers),
                  value: AnnouncementTarget.all,
                  dense: true,
                ),
              RadioListTile<AnnouncementTarget>(
                title: Text(S.specificTsiwa),
                value: AnnouncementTarget.tsiwa,
                dense: true,
              ),
            ],
          ),
        ),
        if (_targetType == AnnouncementTarget.tsiwa) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedTsiwaId.isEmpty
                ? null
                : _selectedTsiwaId,
            decoration: InputDecoration(
              labelText: S.selectTsiwa,
            ),
            items: _availableTsiwas().map((t) {
              return DropdownMenuItem(
                value: t.id,
                child: Text(t.name),
              );
            }).toList(),
            validator: (v) {
              if (_targetType == AnnouncementTarget.tsiwa &&
                  (v == null || v.isEmpty)) {
                return S.selectTsiwa;
              }
              return null;
            },
            onChanged: (v) {
              if (v != null) {
                final tsiwa = _tsiwas
                    .where((t) => t.id == v)
                    .firstOrNull;
                setState(() {
                  _selectedTsiwaId = v;
                  _selectedTsiwaName = tsiwa?.name ?? '';
                });
              }
            },
          ),
        ],
      ],
    );
  }

  List<TsiwaMahber> _availableTsiwas() {
    if (_isAmerar) return _tsiwas;
    final museIds = _museTsiwaIds;
    return _tsiwas.where((t) => museIds.contains(t.id)).toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final announcement = Announcement(
        id: widget.announcement?.id ?? '',
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        priority: _priority,
        authorId: widget.currentUser?.uid ?? '',
        authorName: widget.currentUser?.displayName ?? '',
        targetType: _targetType,
        targetId: _targetType == AnnouncementTarget.tsiwa
            ? _selectedTsiwaId
            : '',
        targetName: _targetType == AnnouncementTarget.tsiwa
            ? _selectedTsiwaName
            : '',
        isActive: widget.announcement?.isActive ?? true,
      );

      if (_isEditing) {
        await _repository.updateAnnouncement(
            widget.areaId, announcement);
      } else {
        await _repository.createAnnouncement(
            widget.areaId, announcement);

        final notification = AppNotification(
          title: 'አዲስ ማሳሰቢያ / መልእክት: ${announcement.title}',
          body: announcement.body.length > 100
              ? '${announcement.body.substring(0, 100)}...'
              : announcement.body,
          type: NotificationType.announcement,
          senderId: widget.currentUser?.uid,
          senderName: widget.currentUser?.displayName,
        );

        if (_targetType == AnnouncementTarget.tsiwa &&
            _selectedTsiwaId.isNotEmpty) {
          _notificationRepository.sendNotificationToTsiwaMembers(
            tsiwaId: _selectedTsiwaId,
            notification: notification,
          );
        } else {
          _notificationRepository.sendNotificationToAll(
            areaId: widget.areaId,
            notification: notification,
          );
        }

        _telegramService.sendAnnouncement(
          areaId: widget.areaId,
          title: announcement.title,
          body: announcement.body,
          priority: announcement.priority.firestoreValue,
          authorName: widget.currentUser?.displayName ??
              AppConstants.defaultAreaShortName,
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ስህተት: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
