import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  final Future<void> Function()? onLogout;

  const ProfileScreen({
    super.key,
    required this.user,
    this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authRepository = AuthRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _christianNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _phone2Controller;
  bool _isSaving = false;

  bool get _canEdit => widget.user.role.isDeveloper;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user.displayName);
    _christianNameController =
        TextEditingController(text: widget.user.christianName);
    _phoneController =
        TextEditingController(text: widget.user.phone);
    _phone2Controller =
        TextEditingController(text: widget.user.phone2);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _christianNameController.dispose();
    _phoneController.dispose();
    _phone2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.profile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        AppTheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      widget.user.displayName.isNotEmpty
                          ? widget.user.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 32,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user.displayName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (widget.user.christianName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.user.christianName,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textMuted),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.user.role.displayName,
                      style: const TextStyle(
                          color: AppTheme.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Only show edit form for devs (members can't write to users collection)
          if (_canEdit) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'መገለጫ አስተካክል',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: S.fullName,
                          prefixIcon: Icon(Icons.person_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return S.nameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _christianNameController,
                        decoration: InputDecoration(
                          labelText: S.christianName,
                          prefixIcon: Icon(Icons.church_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: S.phone,
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phone2Controller,
                        decoration: InputDecoration(
                          labelText: S.additionalPhone,
                          prefixIcon: Icon(Icons.phone_outlined),
                          hintText: S.optionalField,
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : Text(S.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(S.exitAccount,
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                final navigator = Navigator.of(context);
                if (widget.onLogout != null) {
                  await widget.onLogout!();
                } else {
                  await _authRepository.signOut();
                }
                if (mounted) {
                  navigator.popUntil((route) => route.isFirst);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _authRepository.updateProfile(
        uid: widget.user.uid,
        displayName: _nameController.text.trim(),
        christianName: _christianNameController.text.trim(),
        phone: _phoneController.text.trim(),
        phone2: _phone2Controller.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('መገለጫ ተቀምጧል')),
        );
        Navigator.pop(context);
      }
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
