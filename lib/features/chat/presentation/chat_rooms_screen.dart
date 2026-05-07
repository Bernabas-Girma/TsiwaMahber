import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/chat/data/chat_repository.dart';
import 'package:tsiwa_mahber/features/chat/domain/chat_room.dart';
import 'package:tsiwa_mahber/features/chat/presentation/chat_screen.dart';
import 'package:tsiwa_mahber/features/chat/presentation/create_chat_group_screen.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';

class ChatRoomsScreen extends StatefulWidget {
  final String areaId;
  final AppUser currentUser;

  const ChatRoomsScreen({
    super.key,
    required this.areaId,
    required this.currentUser,
  });

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  final _chatRepository = ChatRepository();
  final _tsiwaRepository = TsiwaRepository();
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _initRooms();
  }

  Future<void> _initRooms() async {
    try {
      final tsiwas = await _tsiwaRepository
          .watchTsiwas(widget.areaId)
          .first;
      final tsiwaList = tsiwas
          .map((t) => (tsiwaId: t.id, tsiwaName: t.name))
          .toList();
      await _chatRepository.initDefaultRooms(widget.areaId, tsiwaList);
    } catch (_) {}
    if (mounted) setState(() => _initializing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUser.role.isAdminOrAbove;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.chatGroups),
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<ChatRoom>>(
              stream: _chatRepository.watchRooms(widget.areaId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allRooms = snapshot.data!;
                final rooms = _filterRooms(allRooms);

                if (rooms.isEmpty) {
                  return Center(
                    child: Text(
                      S.noChatRooms,
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) =>
                      _buildRoomCard(rooms[index], isAdmin),
                );
              },
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _createGroup,
              child: const Icon(Icons.group_add),
            )
          : null,
    );
  }

  List<ChatRoom> _filterRooms(List<ChatRoom> rooms) {
    final user = widget.currentUser;
    final isAdmin = user.role.isAdminOrAbove;
    final isLeader = user.role.canEdit;

    return rooms.where((room) {
      if (!room.isEnabled && !isAdmin) return false;

      switch (room.type) {
        case ChatRoomType.global:
          return true;
        case ChatRoomType.amerars:
          return isLeader || isAdmin;
        case ChatRoomType.tsiwa:
          return isAdmin ||
              user.assignedTsiwaIds.contains(room.tsiwaId);
        case ChatRoomType.custom:
          return isAdmin ||
              room.memberIds.contains(user.uid);
      }
    }).toList();
  }

  Widget _buildRoomCard(ChatRoom room, bool isAdmin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _roomColor(room.type).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _roomIcon(room.type),
            color: _roomColor(room.type),
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                room.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (room.isMuted)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.volume_off,
                    size: 16, color: Colors.orange.shade700),
              ),
            if (!room.notificationsEnabled)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.notifications_off,
                    size: 16, color: Colors.grey),
              ),
          ],
        ),
        subtitle: room.lastMessage.isNotEmpty
            ? Text(
                room.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMuted),
              )
            : Text(
                _roomTypeLabel(room.type),
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMuted),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!room.isEnabled)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  S.disabled,
                  style: const TextStyle(
                      fontSize: 10, color: Colors.red),
                ),
              ),
            if (isAdmin)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (val) =>
                    _handleRoomAction(val, room),
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 18),
                        const SizedBox(width: 8),
                        Text(S.rename),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: room.isEnabled ? 'disable' : 'enable',
                    child: Row(
                      children: [
                        Icon(room.isEnabled
                            ? Icons.block
                            : Icons.check_circle,
                            size: 18),
                        const SizedBox(width: 8),
                        Text(room.isEnabled
                            ? S.disableGroup
                            : S.enableGroup),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: room.isMuted ? 'unmute' : 'mute',
                    child: Row(
                      children: [
                        Icon(room.isMuted
                            ? Icons.volume_up
                            : Icons.volume_off,
                            size: 18),
                        const SizedBox(width: 8),
                        Text(room.isMuted
                            ? S.unmuteGroup
                            : S.muteGroup),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: room.notificationsEnabled
                        ? 'disable_notif'
                        : 'enable_notif',
                    child: Row(
                      children: [
                        Icon(
                          room.notificationsEnabled
                              ? Icons.notifications_off
                              : Icons.notifications_active,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(room.notificationsEnabled
                            ? S.disableNotifications
                            : S.enableNotifications),
                      ],
                    ),
                  ),
                  if (room.type == ChatRoomType.custom)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18,
                              color: Colors.red),
                          const SizedBox(width: 8),
                          Text(S.delete,
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              ),
            if (!isAdmin)
              const Icon(Icons.chevron_right,
                  color: AppTheme.textMuted, size: 20),
          ],
        ),
        onTap: room.isEnabled || isAdmin
            ? () => _openChat(room)
            : null,
      ),
    );
  }

  void _handleRoomAction(String action, ChatRoom room) {
    switch (action) {
      case 'rename':
        _showRenameDialog(room);
      case 'enable':
        _chatRepository.toggleRoom(widget.areaId, room.id, true);
      case 'disable':
        _chatRepository.toggleRoom(widget.areaId, room.id, false);
      case 'mute':
        _showMuteDialog(room);
      case 'unmute':
        _chatRepository.unmuteRoom(widget.areaId, room.id);
      case 'delete':
        _showDeleteDialog(room);
      case 'enable_notif':
        _chatRepository.toggleNotifications(
            widget.areaId, room.id, true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.notificationsEnabled)),
          );
        }
      case 'disable_notif':
        _chatRepository.toggleNotifications(
            widget.areaId, room.id, false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.notificationsDisabled)),
          );
        }
    }
  }

  void _showRenameDialog(ChatRoom room) {
    final controller = TextEditingController(text: room.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.rename),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: S.groupName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.cancel),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _chatRepository.renameRoom(
                    widget.areaId, room.id, name);
              }
              Navigator.pop(ctx);
            },
            child: Text(S.save),
          ),
        ],
      ),
    );
  }

  void _showMuteDialog(ChatRoom room) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(S.muteGroup),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _chatRepository.muteRoom(widget.areaId, room.id,
                  DateTime.now().add(const Duration(hours: 24)));
            },
            child: Text(S.mute24h),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _chatRepository.muteRoom(widget.areaId, room.id,
                  DateTime.now().add(const Duration(days: 7)));
            },
            child: Text(S.mute1week),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _chatRepository.muteRoom(widget.areaId, room.id,
                  DateTime(2099));
            },
            child: Text(S.muteUntilEnabled),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ChatRoom room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.delete),
        content: Text(S.deleteGroupConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _chatRepository.deleteRoom(widget.areaId, room.id);
            },
            child: Text(S.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _createGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateChatGroupScreen(
          areaId: widget.areaId,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  void _openChat(ChatRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          areaId: widget.areaId,
          roomId: room.id,
          roomName: room.name,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  IconData _roomIcon(ChatRoomType type) {
    switch (type) {
      case ChatRoomType.global:
        return Icons.public;
      case ChatRoomType.amerars:
        return Icons.admin_panel_settings;
      case ChatRoomType.tsiwa:
        return Icons.groups;
      case ChatRoomType.custom:
        return Icons.group;
    }
  }

  Color _roomColor(ChatRoomType type) {
    switch (type) {
      case ChatRoomType.global:
        return Colors.blue;
      case ChatRoomType.amerars:
        return Colors.deepPurple;
      case ChatRoomType.tsiwa:
        return AppTheme.primary;
      case ChatRoomType.custom:
        return Colors.teal;
    }
  }

  String _roomTypeLabel(ChatRoomType type) {
    switch (type) {
      case ChatRoomType.global:
        return S.globalChat;
      case ChatRoomType.amerars:
        return S.amerarsChat;
      case ChatRoomType.tsiwa:
        return S.tsiwaChat;
      case ChatRoomType.custom:
        return S.customGroup;
    }
  }
}
