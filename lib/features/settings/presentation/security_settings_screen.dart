import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart' show AppTheme, LocaleProvider;
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';

class SecuritySettingsScreen extends StatefulWidget {
  final String areaId;

  const SecuritySettingsScreen({super.key, required this.areaId});

  @override
  State<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _authRepository = AuthRepository();

  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      _firestore.collection('areas').doc(widget.areaId).collection('settings').doc('security');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.passwordChangeSettings),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _settingsDoc.snapshots(),
        builder: (context, settingsSnap) {
          final settingsData = settingsSnap.data?.data() ?? {};
          final globalEnabled =
              settingsData['passwordChangeEnabled'] as bool? ?? true;
          final disabledUsers = List<String>.from(
              settingsData['passwordChangeDisabledUsers'] as List? ?? []);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile(
                  title: Text(S.enablePasswordChange),
                  subtitle: Text(S.enablePasswordChangeGlobal),
                  value: globalEnabled,
                  activeTrackColor: AppTheme.primary,
                  secondary:
                      const Icon(Icons.lock_open, color: AppTheme.primary),
                  onChanged: (val) {
                    _settingsDoc.set(
                      {'passwordChangeEnabled': val},
                      SetOptions(merge: true),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val
                            ? S.passwordChangeEnabled
                            : S.passwordChangeDisabled),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _amOrEn('የተወሰኑ አባላት', 'Individual Members'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildMemberList(globalEnabled, disabledUsers),
            ],
          );
        },
      ),
    );
  }

  String _amOrEn(String am, String en) =>
      LocaleProvider.instance.isAmharic ? am : en;

  Widget _buildMemberList(bool globalEnabled, List<String> disabledUsers) {
    return StreamBuilder<List<AppUser>>(
      stream: _authRepository.watchUsersByArea(AppConstants.defaultAreaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = snapshot.data!
            .where((u) => u.role == UserRole.member || u.role == UserRole.viewer)
            .toList();

        if (members.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  _amOrEn('ምንም አባል የለም', 'No members'),
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ),
            ),
          );
        }

        return Card(
          child: Column(
            children: members.map((member) {
              final isDisabled = disabledUsers.contains(member.uid);
              final effectiveEnabled = globalEnabled && !isDisabled;

              return SwitchListTile(
                title: Text(member.displayName),
                subtitle: Text(member.phone),
                value: effectiveEnabled,
                activeTrackColor: AppTheme.primary,
                onChanged: globalEnabled
                    ? (val) {
                        if (val) {
                          _settingsDoc.set(
                            {
                              'passwordChangeDisabledUsers':
                                  FieldValue.arrayRemove([member.uid])
                            },
                            SetOptions(merge: true),
                          );
                        } else {
                          _settingsDoc.set(
                            {
                              'passwordChangeDisabledUsers':
                                  FieldValue.arrayUnion([member.uid])
                            },
                            SetOptions(merge: true),
                          );
                        }
                      }
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
