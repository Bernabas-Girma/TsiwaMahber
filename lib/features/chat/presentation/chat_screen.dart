import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/chat/data/chat_repository.dart';
import 'package:tsiwa_mahber/features/chat/domain/chat_message.dart';
import 'package:tsiwa_mahber/features/chat/domain/chat_room.dart';
import 'package:tsiwa_mahber/features/chat/presentation/chat_members_screen.dart';

class ChatScreen extends StatefulWidget {
  final String areaId;
  final String roomId;
  final String roomName;
  final AppUser currentUser;

  const ChatScreen({
    super.key,
    required this.areaId,
    required this.roomId,
    required this.roomName,
    required this.currentUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatRepository = ChatRepository();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  String? _editingMessageId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUser.role.isAdminOrAbove;

    return StreamBuilder<ChatRoom?>(
      stream: _chatRepository.watchRoom(widget.areaId, widget.roomId),
      builder: (context, roomSnap) {
        final room = roomSnap.data;
        final isMuted = room?.isMuted ?? false;
        final isRestricted =
            room?.restrictedMemberIds.contains(widget.currentUser.uid) ??
                false;
        final canSend = isAdmin || (!isMuted && !isRestricted);

        return Scaffold(
          appBar: AppBar(
            title: Text(room?.name ?? widget.roomName),
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.people),
                  tooltip: S.chatMembers,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatMembersScreen(
                          areaId: widget.areaId,
                          roomId: widget.roomId,
                          currentUser: widget.currentUser,
                        ),
                      ),
                    );
                  },
                ),
              if (isAdmin && widget.currentUser.role.isDeveloper)
                IconButton(
                  icon: const Icon(Icons.schedule_send),
                  tooltip: S.scheduleMessage,
                  onPressed: () => _showScheduleDialog(),
                ),
            ],
          ),
          body: Column(
            children: [
              if (isMuted && !isAdmin)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  color: Colors.orange.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_off,
                          size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(S.groupMuted,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.orange)),
                    ],
                  ),
                ),
              if (isRestricted && !isAdmin)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  color: Colors.red.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.block,
                          size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(S.youAreRestricted,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.red)),
                    ],
                  ),
                ),
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _chatRepository.watchMessages(
                      widget.areaId, widget.roomId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!;
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary
                                    .withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text(
                              S.noChatMessages,
                              style: const TextStyle(
                                  color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) =>
                          _buildMessageBubble(messages[index]),
                    );
                  },
                ),
              ),
              if (canSend) _buildMessageInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == widget.currentUser.uid;
    final canModify =
        isMe || widget.currentUser.role.isAdminOrAbove;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: canModify
            ? () => _showMessageActions(message, isMe)
            : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.senderName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white : null,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isEdited)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        S.edited,
                        style: TextStyle(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  if (message.scheduledAt != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.schedule,
                        size: 10,
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppTheme.textMuted,
                      ),
                    ),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageActions(ChatMessage message, bool isMe) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMe)
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(S.editMessage),
                onTap: () {
                  Navigator.pop(ctx);
                  _startEditing(message);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(S.deleteMessage,
                  style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _chatRepository.deleteMessage(
                    widget.areaId, widget.roomId, message.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startEditing(ChatMessage message) {
    setState(() {
      _editingMessageId = message.id;
      _messageController.text = message.text;
    });
  }

  Widget _buildMessageInput() {
    final isEditing = _editingMessageId != null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditing)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit,
                        size: 14, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(S.editingMessage,
                        style: TextStyle(
                            fontSize: 12, color: Theme.of(context).colorScheme.primary)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelEditing,
                      child: const Icon(Icons.close,
                          size: 16, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: S.typeMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          isEditing ? Icons.check : Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed:
                            isEditing ? _saveEdit : _sendMessage,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _cancelEditing() {
    setState(() {
      _editingMessageId = null;
      _messageController.clear();
    });
  }

  Future<void> _saveEdit() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _editingMessageId == null) return;

    setState(() => _isSending = true);
    try {
      await _chatRepository.editMessage(
          widget.areaId, widget.roomId, _editingMessageId!, text);
      _cancelEditing();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.saveFailed}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await _chatRepository.sendMessage(
        widget.areaId,
        widget.roomId,
        ChatMessage(
          roomId: widget.roomId,
          senderId: widget.currentUser.uid,
          senderName: widget.currentUser.displayName,
          text: text,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.saveFailed}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showScheduleDialog() {
    final textCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(S.scheduleMessage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: S.typeMessage,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, size: 20),
                title: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} '
                  '${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now()
                        .add(const Duration(days: 365)),
                  );
                  if (date == null) return;
                  if (!ctx.mounted) return;
                  final time = await showTimePicker(
                    context: ctx,
                    initialTime:
                        TimeOfDay.fromDateTime(selectedDate),
                  );
                  if (time == null) return;
                  setDialogState(() {
                    selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.cancel),
            ),
            TextButton(
              onPressed: () async {
                final text = textCtrl.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(ctx);
                await _chatRepository.sendMessage(
                  widget.areaId,
                  widget.roomId,
                  ChatMessage(
                    roomId: widget.roomId,
                    senderId: widget.currentUser.uid,
                    senderName: widget.currentUser.displayName,
                    text: text,
                    scheduledAt: selectedDate,
                  ),
                );
              },
              child: Text(S.schedule),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 0) {
      return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
