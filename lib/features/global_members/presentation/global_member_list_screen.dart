import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/confirm_dialog.dart';
import 'package:tsiwa_mahber/core/widgets/empty_state.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/global_members/presentation/global_member_form_screen.dart';
import 'package:tsiwa_mahber/features/global_members/presentation/global_member_csv_import_screen.dart';

class GlobalMemberListScreen extends StatefulWidget {
  const GlobalMemberListScreen({super.key});

  @override
  State<GlobalMemberListScreen> createState() =>
      _GlobalMemberListScreenState();
}

class _GlobalMemberListScreenState extends State<GlobalMemberListScreen> {
  final _authRepository = AuthRepository();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.globalMembers),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: S.csvImportMembers,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GlobalMemberCsvImportScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: '${S.name} / ${S.phone}...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(null),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildList() {
    return StreamBuilder<List<AppUser>>(
      stream: _authRepository.watchAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(S.dataLoadFailed,
                style: TextStyle(color: Colors.red.shade300)),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingState(message: S.loading);
        }

        final allUsers = snapshot.data ?? [];
        // Filter out developers — show only non-dev members
        final members =
            allUsers.where((u) => u.role != UserRole.developer).toList();

        final filtered = _searchQuery.isEmpty
            ? members
            : members
                .where((m) =>
                    m.displayName.toLowerCase().contains(_searchQuery) ||
                    m.phone.contains(_searchQuery))
                .toList();

        if (filtered.isEmpty) {
          return EmptyState(
            icon: Icons.people_outline,
            title: S.noGlobalMembersYet,
            message: S.addGlobalMemberHint,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: filtered.length,
          itemBuilder: (context, index) =>
              _buildMemberTile(filtered[index]),
        );
      },
    );
  }

  Widget _buildMemberTile(AppUser member) {
    final chips = <Widget>[];

    if (member.assignedTsiwaIds.isNotEmpty) {
      chips.add(_chip('ፅዋ ${member.assignedTsiwaIds.length}', Colors.amber));
    }
    if (member.assignedEdirIds.isNotEmpty) {
      chips.add(_chip('እድር ${member.assignedEdirIds.length}', Colors.green));
    }
    if (member.role == UserRole.admin) {
      chips.add(_chip(S.roleAdmin, Colors.blue));
    }
    if (member.isEdirAmerar) {
      chips.add(_chip(S.isEdirAmerar, Colors.purple));
    }
    for (final entry in member.tsiwaRoles.entries) {
      if (entry.value == 'muse') {
        chips.add(_chip(S.roleMuse, Colors.orange));
        break;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
          child: Text(
            member.displayName.isNotEmpty
                ? member.displayName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(member.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.phone,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(spacing: 4, runSpacing: 2, children: chips),
            ],
          ],
        ),
        isThreeLine: chips.isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _openForm(member);
            if (value == 'delete') _deleteMember(member);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text(S.edit),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(S.delete,
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
        onTap: () => _openForm(member),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _openForm(AppUser? member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GlobalMemberFormScreen(
          existingMember: member,
        ),
      ),
    );
  }

  Future<void> _deleteMember(AppUser member) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: S.deleteGlobalMember,
      message: S.deleteGlobalMemberConfirm,
    );
    if (confirmed != true) return;

    try {
      await _authRepository.deleteUser(member.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.globalMemberDeleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.deleteFailed)),
        );
      }
    }
  }
}
