import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/utils/ethiopian_calendar.dart';
import 'package:tsiwa_mahber/core/widgets/confirm_dialog.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/features/tsiwa/presentation/rotation_screen.dart';
import 'package:tsiwa_mahber/features/tsiwa/presentation/tsiwa_form_screen.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class TsiwaDetailScreen extends StatefulWidget {
  final String areaId;
  final String tsiwaId;

  const TsiwaDetailScreen({
    super.key,
    required this.areaId,
    required this.tsiwaId,
  });

  @override
  State<TsiwaDetailScreen> createState() => _TsiwaDetailScreenState();
}

class _TsiwaDetailScreenState extends State<TsiwaDetailScreen> {
  final _tsiwaRepository = TsiwaRepository();
  final _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TsiwaMahber?>(
      stream: _tsiwaRepository.watchTsiwa(widget.areaId, widget.tsiwaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(S.tsiwaDetail)),
            body: LoadingState(message: S.loading),
          );
        }

        final tsiwa = snapshot.data;
        if (tsiwa == null) {
          return Scaffold(
            appBar: AppBar(title: Text(S.tsiwaDetail)),
            body: Center(child: Text(S.tsiwaNotFound)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(tsiwa.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _edit(tsiwa),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _delete(tsiwa),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfoSection(tsiwa),
                const SizedBox(height: 16),
                _buildMonthlyTsiwaSection(tsiwa),
                const SizedBox(height: 16),
                _buildYearlyZikirSection(tsiwa),
                const SizedBox(height: 16),
                _buildStatusSection(tsiwa),
                const SizedBox(height: 16),
                _buildScheduleSection(tsiwa),
                const SizedBox(height: 16),
                _buildMembersSection(tsiwa),
                const SizedBox(height: 16),
                _buildRotationSection(tsiwa),
                const SizedBox(height: 16),
                _buildMonthlyOrderSection(tsiwa),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoSection(TsiwaMahber tsiwa) {
    return _SectionCard(
      title: S.basicInfo,
      icon: Icons.info_outline,
      children: [
        _InfoRow(label: S.name, value: tsiwa.name),
        if (tsiwa.churchName.isNotEmpty)
          _InfoRow(label: 'ቤተ ክርስቲያን', value: tsiwa.churchName),
        if (tsiwa.saintName.isNotEmpty)
          _InfoRow(label: 'ቅዱስ/ቅድስት', value: tsiwa.saintName),
        if (tsiwa.location.isNotEmpty)
          _InfoRow(label: S.location, value: tsiwa.location),
        if (tsiwa.description.isNotEmpty)
          _InfoRow(label: S.description, value: tsiwa.description),
      ],
    );
  }

  Widget _buildMonthlyTsiwaSection(TsiwaMahber tsiwa) {
    return _SectionCard(
      title: S.monthlyTsiwaDay,
      icon: Icons.calendar_today,
      iconColor: AppTheme.primary,
      children: [
        _InfoRow(label: S.day, value: 'በየወሩ ${tsiwa.monthlyTsiwaDay}'),
        if (tsiwa.monthlyTsiwaDayNote.isNotEmpty)
          _InfoRow(label: S.note, value: tsiwa.monthlyTsiwaDayNote),
      ],
    );
  }

  Widget _buildYearlyZikirSection(TsiwaMahber tsiwa) {
    if (tsiwa.yearlyZikir.isEmpty) {
      return _SectionCard(
        title: S.yearlyZikirTitle,
        icon: Icons.auto_awesome,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              S.noYearlyZikirYet,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ),
        ],
      );
    }

    return _SectionCard(
      title: S.yearlyZikirTitle,
      icon: Icons.auto_awesome,
      iconColor: AppTheme.secondary,
      children: [
        ...tsiwa.yearlyZikir.map((entry) {
          final monthName = AppConstants.ethiopianMonthName(entry.month);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.event, size: 16, color: AppTheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$monthName ${entry.day}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (entry.note.isNotEmpty)
                        Text(
                          entry.note,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatusSection(TsiwaMahber tsiwa) {
    return _SectionCard(
      title: S.status,
      icon: Icons.toggle_on,
      children: [
        _InfoRow(
          label: S.active,
          value: tsiwa.isActive ? 'አዎ' : 'አይ',
          valueColor: tsiwa.isActive ? AppTheme.success : Colors.red,
        ),
        _InfoRow(label: S.archive, value: tsiwa.isArchived ? 'አዎ' : 'አይ'),
      ],
    );
  }

  Widget _buildMembersSection(TsiwaMahber tsiwa) {
    return StreamBuilder<List<AppUser>>(
      stream: _authRepository.watchMembersByTsiwa(widget.tsiwaId),
      builder: (context, snapshot) {
        final members = snapshot.data ?? [];
        final museCount = members
            .where(
              (m) =>
                  m.tsiwaRoles[widget.tsiwaId] == 'muse' ||
                  m.tsiwaRoles[widget.tsiwaId] == 'assistant_muse',
            )
            .length;

        return _SectionCard(
          title: S.members,
          icon: Icons.people,
          iconColor: AppTheme.primary,
          children: [
            _InfoRow(
              label: S.total,
              value: '${members.length} አባላት · $museCount ሙሴ',
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  S.noMembersYet,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              )
            else
              ...members.map((member) => _buildMemberTile(member)),
          ],
        );
      },
    );
  }

  Widget _buildMemberTile(AppUser member) {
    final role = member.tsiwaRoles[widget.tsiwaId] ?? 'member';
    String roleLabel;
    IconData roleIcon;
    switch (role) {
      case 'muse':
        roleLabel = 'ሙሴ';
        roleIcon = Icons.star;
      case 'assistant_muse':
        roleLabel = 'ረዳት ሙሴ';
        roleIcon = Icons.star_half;
      default:
        roleLabel = S.roleMember;
        roleIcon = Icons.person;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(roleIcon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              member.displayName,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              roleLabel,
              style: const TextStyle(fontSize: 11, color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(TsiwaMahber tsiwa) {
    final ethToday = EthiopianCalendar.today();
    final tswaDays = EthiopianCalendar.daysUntilMonthlyDay(
      tsiwa.monthlyTsiwaDay,
    );

    return _SectionCard(
      title: S.calendar,
      icon: Icons.schedule,
      iconColor: Colors.teal,
      children: [
        _InfoRow(label: 'ዛሬ', value: ethToday.formatted),
        const SizedBox(height: 8),
        _buildCountdownChip(
          'ፅዋ ቀን ${tsiwa.monthlyTsiwaDay}',
          tswaDays,
          AppTheme.primary,
        ),
        ...tsiwa.yearlyZikir.map((entry) {
          final monthName = AppConstants.ethiopianMonthName(entry.month);
          return _buildCountdownChip(
            '${S.yearlyZikirTitle} ($monthName ${entry.day})',
            EthiopianCalendar.daysUntilDate(entry.month, entry.day),
            AppTheme.secondary,
          );
        }),
      ],
    );
  }

  Widget _buildCountdownChip(String label, int days, Color color) {
    final text = EthiopianCalendar.daysUntilText(days);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: days == 0
                  ? color.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: days == 0 ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotationSection(TsiwaMahber tsiwa) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RotationScreen(
                areaId: widget.areaId,
                tsiwaId: widget.tsiwaId,
                tsiwaName: tsiwa.name,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.rotate_right,
                  color: Colors.teal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.rotationAndHistory,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      S.rotationOrder,
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyOrderSection(TsiwaMahber tsiwa) {
    return StreamBuilder<List<AppUser>>(
      stream: _authRepository.watchMembersByTsiwa(widget.tsiwaId),
      builder: (context, snap) {
        final members = snap.data ?? [];

        return _SectionCard(
          title: S.monthlyOrderTable,
          icon: Icons.table_chart_outlined,
          iconColor: Colors.deepPurple,
          children: [
            for (int m = 1; m <= AppConstants.tsiwaMonthCount; m++)
              _buildMonthOrderRow(tsiwa, m, members),
          ],
        );
      },
    );
  }

  Widget _buildMonthOrderRow(
    TsiwaMahber tsiwa,
    int month,
    List<AppUser> members,
  ) {
    final memberId = tsiwa.monthlyOrder[month];
    final assigned = memberId != null
        ? members.where((m) => m.uid == memberId).firstOrNull
        : null;
    final monthName = AppConstants.ethiopianMonthName(month);
    final ethToday = EthiopianCalendar.today();
    final isCurrent = ethToday.month == month;

    return InkWell(
      onTap: () => _showAssignDialog(tsiwa, month, members),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isCurrent ? AppTheme.primary.withValues(alpha: 0.08) : null,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.textMuted.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                monthName,
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(
                assigned?.displayName ?? S.unassigned,
                style: TextStyle(
                  fontSize: 13,
                  color: assigned != null ? null : AppTheme.textMuted,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isCurrent)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  S.now,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.edit_outlined, size: 16, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _showAssignDialog(
    TsiwaMahber tsiwa,
    int month,
    List<AppUser> members,
  ) async {
    final monthName = AppConstants.ethiopianMonthName(month);
    final currentId = tsiwa.monthlyOrder[month];

    final selected = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$monthName - ${S.assignOrder}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.clear, color: Colors.red),
                title: Text(S.unassigned),
                selected: currentId == null,
                onTap: () => Navigator.pop(ctx, '__clear__'),
              ),
              ...members.map((m) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.primary.withValues(alpha: 0.15),
                      radius: 16,
                      child: Text(
                        m.displayName.isNotEmpty
                            ? m.displayName[0]
                            : '?',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    title: Text(m.displayName),
                    subtitle: m.christianName.isNotEmpty
                        ? Text(m.christianName,
                            style: const TextStyle(fontSize: 12))
                        : null,
                    selected: m.uid == currentId,
                    onTap: () => Navigator.pop(ctx, m.uid),
                  )),
            ],
          ),
        ),
      ),
    );

    if (selected == null || !mounted) return;

    try {
      final newOrder = Map<int, String>.from(tsiwa.monthlyOrder);
      if (selected == '__clear__') {
        newOrder.remove(month);
      } else {
        newOrder[month] = selected;
      }
      await _tsiwaRepository.updateTsiwa(
        widget.areaId,
        tsiwa.copyWith(monthlyOrder: newOrder),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.orderSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.orderSaveFailed)),
        );
      }
    }
  }

  void _edit(TsiwaMahber tsiwa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TsiwaFormScreen(areaId: widget.areaId, existingTsiwa: tsiwa),
      ),
    );
  }

  Future<void> _delete(TsiwaMahber tsiwa) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: S.deleteTsiwa,
      message: '"${tsiwa.name}" ፅዋ ማህበሩን ለመሰረዝ እርግጠኛ ነዎት?',
      confirmText: S.delete,
      cancelText: S.cancel,
    );

    if (confirmed == true && mounted) {
      try {
        await _tsiwaRepository.deleteTsiwa(widget.areaId, tsiwa.id);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.dataDeleteFailed)));
        }
      }
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor ?? AppTheme.textMuted),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
