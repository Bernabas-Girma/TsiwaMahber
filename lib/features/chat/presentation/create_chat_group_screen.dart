import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/chat/data/chat_repository.dart';
import 'package:tsiwa_mahber/features/chat/domain/chat_room.dart';

class CreateChatGroupScreen extends StatefulWidget {
  final String areaId;
  final AppUser currentUser;

  const CreateChatGroupScreen({
    super.key,
    required this.areaId,
    required this.currentUser,
  });

  @override
  State<CreateChatGroupScreen> createState() =>
      _CreateChatGroupScreenState();
}

class _CreateChatGroupScreenState extends State<CreateChatGroupScreen> {
  final _chatRepository = ChatRepository();
  final _authRepository = AuthRepository();
  final _nameController = TextEditingController();
  final _selectedUids = <String>{};
  String _searchQuery = '';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.createGroup),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _save,
                ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: S.groupName,
                prefixIcon: const Icon(Icons.group),
              ),
            ),
          ),
          if (_selectedUids.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: Text(
                '${S.selectedMembers}: ${_selectedUids.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: '${S.name} / ${S.phone}...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(child: _buildMemberList()),
        ],
      ),
    );
  }

  Widget _buildMemberList() {
    return StreamBuilder<List<AppUser>>(
      stream: _authRepository.watchAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var users = snapshot.data!
            .where((u) => u.isActive && !u.kickedOut)
            .toList();

        if (_searchQuery.isNotEmpty) {
          users = users
              .where((u) =>
                  u.displayName.toLowerCase().contains(_searchQuery) ||
                  u.phone.contains(_searchQuery))
              .toList();
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final u = users[index];
            final selected = _selectedUids.contains(u.uid);
            return CheckboxListTile(
              value: selected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedUids.add(u.uid);
                  } else {
                    _selectedUids.remove(u.uid);
                  }
                });
              },
              title: Text(u.displayName),
              subtitle: Text(u.phone,
                  style: const TextStyle(fontSize: 12)),
              secondary: CircleAvatar(
                backgroundColor:
                    AppTheme.primary.withValues(alpha: 0.15),
                child: Text(
                  u.displayName.isNotEmpty
                      ? u.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: AppTheme.primary),
                ),
              ),
              activeColor: AppTheme.primary,
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.groupNameRequired)),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await _chatRepository.ensureRoom(
        widget.areaId,
        ChatRoom(
          areaId: widget.areaId,
          name: name,
          type: ChatRoomType.custom,
          memberIds: _selectedUids.toList(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.saveFailed}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
