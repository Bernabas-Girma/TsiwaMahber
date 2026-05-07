import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/chat/data/chat_repository.dart';
import 'package:tsiwa_mahber/features/chat/domain/chat_room.dart';

class ChatMembersScreen extends StatefulWidget {
  final String areaId;
  final String roomId;
  final AppUser currentUser;

  const ChatMembersScreen({
    super.key,
    required this.areaId,
    required this.roomId,
    required this.currentUser,
  });

  @override
  State<ChatMembersScreen> createState() => _ChatMembersScreenState();
}

class _ChatMembersScreenState extends State<ChatMembersScreen> {
  final _chatRepository = ChatRepository();
  final _authRepository = AuthRepository();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUser.role.isAdminOrAbove;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.chatMembers),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showAddMemberDialog,
            ),
        ],
      ),
      body: StreamBuilder<ChatRoom?>(
        stream: _chatRepository.watchRoom(widget.areaId, widget.roomId),
        builder: (context, roomSnap) {
          if (!roomSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final room = roomSnap.data!;

          return StreamBuilder<List<AppUser>>(
            stream: _authRepository.watchAllUsers(),
            builder: (context, usersSnap) {
              if (!usersSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allUsers = usersSnap.data!;
              final memberUsers = allUsers
                  .where((u) => room.memberIds.contains(u.uid))
                  .toList();

              if (memberUsers.isEmpty) {
                return Center(
                  child: Text(
                    S.noMembers,
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: memberUsers.length,
                itemBuilder: (context, index) {
                  final user = memberUsers[index];
                  final isRestricted =
                      room.restrictedMemberIds.contains(user.uid);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppTheme.primary.withValues(alpha: 0.15),
                        child: Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: AppTheme.primary),
                        ),
                      ),
                      title: Text(user.displayName),
                      subtitle: Row(
                        children: [
                          Text(user.phone,
                              style: const TextStyle(fontSize: 12)),
                          if (isRestricted) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color:
                                    Colors.red.withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                              child: Text(
                                S.restricted,
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.red),
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: isAdmin
                          ? PopupMenuButton<String>(
                              onSelected: (val) => _handleAction(
                                  val, user.uid, isRestricted),
                              itemBuilder: (ctx) => [
                                PopupMenuItem(
                                  value: isRestricted
                                      ? 'unrestrict'
                                      : 'restrict',
                                  child: Text(isRestricted
                                      ? S.allowSending
                                      : S.restrictSending),
                                ),
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Text(S.removeMember,
                                      style: const TextStyle(
                                          color: Colors.red)),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _handleAction(
      String action, String uid, bool isRestricted) {
    switch (action) {
      case 'restrict':
        _chatRepository.restrictMember(
            widget.areaId, widget.roomId, uid);
      case 'unrestrict':
        _chatRepository.unrestrictMember(
            widget.areaId, widget.roomId, uid);
      case 'remove':
        _chatRepository.removeMembers(
            widget.areaId, widget.roomId, [uid]);
    }
  }

  void _showAddMemberDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (ctx, scrollController) {
          return StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '${S.name} / ${S.phone}...',
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                      ),
                      onChanged: (v) => setSheetState(
                          () => _searchQuery = v.toLowerCase()),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<AppUser>>(
                      stream: _authRepository.watchAllUsers(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        var users = snapshot.data!
                            .where(
                                (u) => u.isActive && !u.kickedOut)
                            .toList();
                        if (_searchQuery.isNotEmpty) {
                          users = users
                              .where((u) =>
                                  u.displayName
                                      .toLowerCase()
                                      .contains(_searchQuery) ||
                                  u.phone.contains(_searchQuery))
                              .toList();
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final u = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primary
                                    .withValues(alpha: 0.15),
                                child: Text(
                                  u.displayName.isNotEmpty
                                      ? u.displayName[0]
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: AppTheme.primary),
                                ),
                              ),
                              title: Text(u.displayName),
                              subtitle: Text(u.phone),
                              onTap: () {
                                _chatRepository.addMembers(
                                    widget.areaId,
                                    widget.roomId,
                                    [u.uid]);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
