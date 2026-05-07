import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/chat/data/chat_repository.dart';
import 'package:tsiwa_mahber/features/chat/domain/chat_room.dart';
import 'package:tsiwa_mahber/features/chat/presentation/chat_screen.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';

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
        title: Text(
          room.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
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
              Switch(
                value: room.isEnabled,
                onChanged: (val) => _chatRepository.toggleRoom(
                    widget.areaId, room.id, val),
                activeColor: AppTheme.primary,
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
    }
  }
}
