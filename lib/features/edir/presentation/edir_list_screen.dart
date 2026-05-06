import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/confirm_dialog.dart';
import 'package:tsiwa_mahber/core/widgets/empty_state.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/features/edir/presentation/edir_detail_screen.dart';
import 'package:tsiwa_mahber/features/edir/presentation/edir_form_screen.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';

class EdirListScreen extends StatefulWidget {
  final String areaId;
  final AppUser? currentUser;

  const EdirListScreen({
    super.key,
    required this.areaId,
    this.currentUser,
  });

  @override
  State<EdirListScreen> createState() => _EdirListScreenState();
}

class _EdirListScreenState extends State<EdirListScreen> {
  final _repository = EdirRepository();
  late final Stream<List<Edir>> _edirStream;

  @override
  void initState() {
    super.initState();
    _edirStream = _repository.watchEdirs(widget.areaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.edir),
      ),
      body: StreamBuilder<List<Edir>>(
        stream: _edirStream,
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
          final isAdmin =
              widget.currentUser?.role.canEdit == true;
          final edirs = isAdmin
              ? all
              : all.where((e) => !e.isHidden).toList();

          if (edirs.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet,
              title: S.noEdirYet,
              message: S.addEdirHint,
              action: ElevatedButton.icon(
                onPressed: _openCreateForm,
                icon: const Icon(Icons.add),
                label: Text(S.newEdir),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: edirs.length,
            itemBuilder: (context, index) =>
                _buildEdirCard(edirs[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEdirCard(Edir edir) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EdirDetailScreen(
                areaId: widget.areaId,
                edirId: edir.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: edir.isHidden
                      ? AppTheme.textMuted
                      : AppTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            edir.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (edir.isHidden)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              S.hidden,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.orange),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'አባላት: ${edir.memberCount} · '
                      'ወርሃዊ: ${edir.monthlyContribution.toStringAsFixed(0)} ብር',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    if (edir.treasury > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'ግምጃ ቤት: ${edir.treasury.toStringAsFixed(0)} ብር',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _openEditForm(edir);
                  } else if (value == 'toggleHidden') {
                    _toggleHidden(edir);
                  } else if (value == 'delete') {
                    _confirmDelete(edir);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text(S.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggleHidden',
                    child: Row(
                      children: [
                        Icon(
                          edir.isHidden
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(edir.isHidden ? S.showEdir : S.hideEdir),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text(S.delete, style: TextStyle(color: Colors.red)),
                      ],
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

  void _openCreateForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EdirFormScreen(areaId: widget.areaId),
      ),
    );
  }

  void _openEditForm(Edir edir) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EdirFormScreen(areaId: widget.areaId, edir: edir),
      ),
    );
  }

  Future<void> _toggleHidden(Edir edir) async {
    try {
      await _repository.toggleEdirHidden(
          widget.areaId, edir.id, !edir.isHidden);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                edir.isHidden ? S.edirVisible : S.edirHidden),
          ),
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

  Future<void> _confirmDelete(Edir edir) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: S.deleteEdir,
      message: '"${edir.name}" እድርን ለመሰረዝ እርግጠኛ ነዎት?',
      confirmText: S.delete,
    );

    if (confirmed == true) {
      await _repository.deleteEdir(widget.areaId, edir.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${edir.name}" ተሰርዟል')),
        );
      }
    }
  }
}
