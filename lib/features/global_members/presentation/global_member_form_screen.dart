import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';

class GlobalMemberFormScreen extends StatefulWidget {
  final AppUser? existingMember;

  const GlobalMemberFormScreen({
    super.key,
    this.existingMember,
  });

  @override
  State<GlobalMemberFormScreen> createState() => _GlobalMemberFormScreenState();
}

class _GlobalMemberFormScreenState extends State<GlobalMemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authRepository = AuthRepository();
  final _tsiwaRepository = TsiwaRepository();
  final _edirRepository = EdirRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _codeController;

  bool _isLoading = false;
  bool _isAdmin = false;
  bool _isEdirAmerar = false;

  List<TsiwaMahber> _availableTsiwas = [];
  List<Edir> _availableEdirs = [];

  final Set<String> _selectedTsiwaIds = {};
  final Set<String> _selectedEdirIds = {};
  final Map<String, String> _tsiwaRoles = {};

  bool get _isEditing => widget.existingMember != null;

  @override
  void initState() {
    super.initState();
    final m = widget.existingMember;
    _nameController = TextEditingController(text: m?.displayName ?? '');
    _phoneController = TextEditingController(text: m?.phone ?? '');
    _codeController = TextEditingController(text: m?.passwordCode ?? '');

    if (m != null) {
      _isAdmin = m.role == UserRole.admin;
      _isEdirAmerar = m.isEdirAmerar;
      _selectedTsiwaIds.addAll(m.assignedTsiwaIds);
      _selectedEdirIds.addAll(m.assignedEdirIds);
      _tsiwaRoles.addAll(m.tsiwaRoles);
    }

    _loadData();
  }

  Future<void> _loadData() async {
    _tsiwaRepository.watchTsiwas(AppConstants.defaultAreaId).first.then((tsiwas) {
      if (mounted) setState(() => _availableTsiwas = tsiwas);
    });
    _edirRepository.watchEdirs(AppConstants.defaultAreaId).first.then((edirs) {
      if (mounted) setState(() => _availableEdirs = edirs);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? S.editGlobalMember : S.newGlobalMember),
      ),
      body: _isLoading
          ? LoadingState(message: S.loading)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(S.personalInfo),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: S.fullName,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? S.nameRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: S.phoneNumber,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        hintText: '09xxxxxxxx',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? S.phoneRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: S.accessCode,
                        prefixIcon: const Icon(Icons.lock_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? S.codeRequired : null,
                    ),
                    const SizedBox(height: 24),

                    // ── Role ──
                    _sectionTitle(S.role),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(S.makeAdmin),
                      subtitle: Text(S.roleAdmin),
                      value: _isAdmin,
                      onChanged: (v) => setState(() => _isAdmin = v),
                    ),
                    SwitchListTile(
                      title: Text(S.isEdirAmerar),
                      subtitle: Text(S.edirAmerarDesc),
                      value: _isEdirAmerar,
                      onChanged: (v) => setState(() => _isEdirAmerar = v),
                    ),

                    const SizedBox(height: 24),

                    // ── Tsiwa Assignments ──
                    _sectionTitle(S.tsiwaAssignments),
                    const SizedBox(height: 8),
                    if (_availableTsiwas.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(S.noTsiwaRegistered,
                            style: const TextStyle(color: AppTheme.textMuted)),
                      )
                    else
                      ..._availableTsiwas.map(_buildTsiwaCheckbox),

                    const SizedBox(height: 24),

                    // ── Edir Assignments ──
                    _sectionTitle(S.edirAssignments),
                    const SizedBox(height: 8),
                    if (_availableEdirs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(S.noEdirRegistered,
                            style: const TextStyle(color: AppTheme.textMuted)),
                      )
                    else
                      ..._availableEdirs.map(_buildEdirCheckbox),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save),
                        label: Text(S.save),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildTsiwaCheckbox(TsiwaMahber tsiwa) {
    final isSelected = _selectedTsiwaIds.contains(tsiwa.id);
    final currentRole = _tsiwaRoles[tsiwa.id] ?? 'member';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(tsiwa.name),
            subtitle: Text(tsiwa.churchName),
            value: isSelected,
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  _selectedTsiwaIds.add(tsiwa.id);
                  _tsiwaRoles[tsiwa.id] = 'member';
                } else {
                  _selectedTsiwaIds.remove(tsiwa.id);
                  _tsiwaRoles.remove(tsiwa.id);
                }
              });
            },
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: DropdownButtonFormField<String>(
                initialValue: currentRole,
                decoration: InputDecoration(
                  labelText: S.tsiwaRole,
                  isDense: true,
                ),
                items: [
                  DropdownMenuItem(value: 'muse', child: Text(S.roleMuse)),
                  DropdownMenuItem(
                      value: 'assistant_muse',
                      child: Text(S.roleAssistantMuse)),
                  DropdownMenuItem(
                      value: 'member', child: Text(S.roleMemberTsiwa)),
                  DropdownMenuItem(
                      value: 'observer', child: Text(S.roleObserver)),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _tsiwaRoles[tsiwa.id] = v);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEdirCheckbox(Edir edir) {
    final isSelected = _selectedEdirIds.contains(edir.id);

    return CheckboxListTile(
      title: Text(edir.name),
      subtitle: Text(edir.description),
      value: isSelected,
      onChanged: (v) {
        setState(() {
          if (v == true) {
            _selectedEdirIds.add(edir.id);
          } else {
            _selectedEdirIds.remove(edir.id);
          }
        });
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final role = _isAdmin ? UserRole.admin : UserRole.member;

      if (_isEditing) {
        final updated = widget.existingMember!.copyWith(
          displayName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          passwordCode: _codeController.text,
          role: role,
          assignedTsiwaIds: _selectedTsiwaIds.toList(),
          assignedEdirIds: _selectedEdirIds.toList(),
          tsiwaRoles: Map<String, String>.from(_tsiwaRoles),
          isEdirAmerar: _isEdirAmerar,
        );

        final error = await _authRepository.updateMemberFull(
          uid: widget.existingMember!.uid,
          updatedUser: updated,
        );

        if (error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
            setState(() => _isLoading = false);
          }
          return;
        }
      } else {
        final error = await _authRepository.createMemberAccount(
          displayName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          passwordCode: _codeController.text,
          areaId: AppConstants.defaultAreaId,
          role: role,
          assignedTsiwaIds: _selectedTsiwaIds.toList(),
          assignedEdirIds: _selectedEdirIds.toList(),
          tsiwaRoles: Map<String, String>.from(_tsiwaRoles),
          isEdirAmerar: _isEdirAmerar,
        );

        if (error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
            setState(() => _isLoading = false);
          }
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.globalMemberSaved)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.saveFailed)),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}
