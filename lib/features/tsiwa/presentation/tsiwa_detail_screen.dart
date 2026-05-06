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
  late int _selectedYear;
  late final Stream<TsiwaMahber?> _tsiwaStream;
  late final Stream<List<AppUser>> _membersStream;

  @override
  void initState() {
    super.initState();
    _selectedYear = EthiopianCalendar.today().year;
    _tsiwaStream = _tsiwaRepository.watchTsiwa(widget.areaId, widget.tsiwaId);
    _membersStream = _authRepository.watchMembersByTsiwa(widget.tsiwaId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TsiwaMahber?>(
      stream: _tsiwaStream,
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
      stream: _membersStream,
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
          trailing: IconButton(
            icon: const Icon(Icons.person_add, color: AppTheme.primary),
            tooltip: S.addMembersFromGlobal,
            onPressed: () => _showBulkAddMembersDialog(members),
          ),
          children: [
            _InfoRow(
              label: S.total,
              value: '${members.length} ማህበርተኞች · $museCount ሙሴ',
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

  Future<void> _showBulkAddMembersDialog(List<AppUser> currentMembers) async {
    final currentIds = currentMembers.map((m) => m.uid).toSet();

    // Fetch all users in this area
    final allUsersSnap = await _authRepository
        .watchUsersByArea(widget.areaId)
        .first;

    // Filter out users already assigned to this tsiwa
    final available = allUsersSnap
        .where((u) => !currentIds.contains(u.uid))
        .toList();

    if (!mounted) return;

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.noUnassignedMembers)),
      );
      return;
    }

    final selected = <String>{};
    String searchQuery = '';

    final result = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = searchQuery.isEmpty
                ? available
                : available.where((u) {
                    final q = searchQuery.toLowerCase();
                    return u.displayName.toLowerCase().contains(q) ||
                        u.christianName.toLowerCase().contains(q) ||
                        u.phone.contains(q);
                  }).toList();

            return AlertDialog(
              title: Text(S.addMembersFromGlobal),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: S.searchMembers,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12,
                        ),
                      ),
                      onChanged: (v) =>
                          setDialogState(() => searchQuery = v),
                    ),
                    const SizedBox(height: 8),
                    if (selected.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          S.selected(selected.length),
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                S.noUnassignedMembers,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final user = filtered[i];
                                final isSelected =
                                    selected.contains(user.uid);
                                return CheckboxListTile(
                                  dense: true,
                                  value: isSelected,
                                  onChanged: (v) {
                                    setDialogState(() {
                                      if (v == true) {
                                        selected.add(user.uid);
                                      } else {
                                        selected.remove(user.uid);
                                      }
                                    });
                                  },
                                  title: Text(
                                    user.displayName,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: user.christianName.isNotEmpty
                                      ? Text(
                                          user.christianName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        )
                                      : null,
                                  secondary: CircleAvatar(
                                    backgroundColor: AppTheme.primary
                                        .withValues(alpha: 0.15),
                                    radius: 16,
                                    child: Text(
                                      user.displayName.isNotEmpty
                                          ? user.displayName[0]
                                          : '?',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(S.cancel),
                ),
                ElevatedButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.pop(ctx, selected),
                  child: Text(
                    '${S.add} (${selected.length})',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result.isEmpty || !mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.addingMembers)),
      );
      final count = await _authRepository.batchAddUsersToTsiwa(
        userIds: result.toList(),
        tsiwaId: widget.tsiwaId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.membersAdded(count))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.failedToAddMembers)),
        );
      }
    }
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

  /// Resolve the order map for a given year, handling legacy year-0 data.
  Map<int, String> _orderForYear(TsiwaMahber tsiwa, int year) {
    if (tsiwa.monthlyOrder.containsKey(year)) {
      return tsiwa.monthlyOrder[year]!;
    }
    // Legacy flat data stored under year 0
    if (tsiwa.monthlyOrder.containsKey(0)) {
      return tsiwa.monthlyOrder[0]!;
    }
    return {};
  }

  Widget _buildMonthlyOrderSection(TsiwaMahber tsiwa) {
    return StreamBuilder<List<AppUser>>(
      stream: _membersStream,
      builder: (context, snap) {
        final members = snap.data ?? [];
        final ethToday = EthiopianCalendar.today();
        final order = _orderForYear(tsiwa, _selectedYear);

        return _SectionCard(
          title: S.monthlyOrderTable,
          icon: Icons.table_chart_outlined,
          iconColor: Colors.deepPurple,
          trailing: _buildYearSwitcher(ethToday.year),
          children: [
            for (int m = 1; m <= AppConstants.tsiwaMonthCount; m++)
              _buildMonthOrderRow(tsiwa, m, members, order, ethToday),
          ],
        );
      },
    );
  }

  Widget _buildYearSwitcher(int currentEthYear) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() => _selectedYear--),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.chevron_left, size: 20, color: AppTheme.primary),
          ),
        ),
        Text(
          S.yearLabel(_selectedYear),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        InkWell(
          onTap: () => setState(() => _selectedYear++),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.chevron_right, size: 20, color: AppTheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthOrderRow(
    TsiwaMahber tsiwa,
    int month,
    List<AppUser> members,
    Map<int, String> yearOrder,
    EthiopianDate ethToday,
  ) {
    final memberId = yearOrder[month];
    final assigned = memberId != null
        ? members.where((m) => m.uid == memberId).firstOrNull
        : null;
    final monthName = AppConstants.ethiopianMonthName(month);
    final isCurrent = ethToday.month == month && ethToday.year == _selectedYear;

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
            if (memberId != null) ...[
              const SizedBox(width: 2),
              InkWell(
                onTap: () => _showSwapDialog(tsiwa, month, yearOrder, members),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.swap_vert, size: 16, color: Colors.deepPurple),
                ),
              ),
            ],
            const SizedBox(width: 2),
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
    final yearOrder = _orderForYear(tsiwa, _selectedYear);
    final currentId = yearOrder[month];

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
      // Build updated order map preserving all years
      final newAllOrders = Map<int, Map<int, String>>.from(
        tsiwa.monthlyOrder.map((k, v) => MapEntry(k, Map<int, String>.from(v))),
      );

      // Resolve legacy year-0 to current year
      final targetYear = _selectedYear;
      if (newAllOrders.containsKey(0) && targetYear != 0) {
        newAllOrders[targetYear] = Map<int, String>.from(newAllOrders[0]!);
        newAllOrders.remove(0);
      }

      final yearMap = newAllOrders[targetYear] ?? <int, String>{};
      if (selected == '__clear__') {
        yearMap.remove(month);
      } else {
        yearMap[month] = selected;
      }
      newAllOrders[targetYear] = yearMap;

      await _tsiwaRepository.updateTsiwa(
        widget.areaId,
        tsiwa.copyWith(monthlyOrder: newAllOrders),
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

  Future<void> _showSwapDialog(
    TsiwaMahber tsiwa,
    int fromMonth,
    Map<int, String> yearOrder,
    List<AppUser> members,
  ) async {
    final fromName = AppConstants.ethiopianMonthName(fromMonth);
    final fromUid = yearOrder[fromMonth];

    // Build list of other months that have assignments
    final otherMonths = <int>[];
    for (int m = 1; m <= AppConstants.tsiwaMonthCount; m++) {
      if (m != fromMonth) otherMonths.add(m);
    }

    final targetMonth = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$fromName — ${S.swapOrder}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: otherMonths.map((m) {
              final uid = yearOrder[m];
              final user = uid != null
                  ? members.where((u) => u.uid == uid).firstOrNull
                  : null;
              final mName = AppConstants.ethiopianMonthName(m);
              return ListTile(
                dense: true,
                title: Text(mName),
                subtitle: Text(
                  user?.displayName ?? S.unassigned,
                  style: TextStyle(
                    fontSize: 12,
                    color: user != null ? null : AppTheme.textMuted,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, m),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (targetMonth == null || !mounted) return;

    try {
      final newAllOrders = Map<int, Map<int, String>>.from(
        tsiwa.monthlyOrder.map((k, v) => MapEntry(k, Map<int, String>.from(v))),
      );
      final targetYear = _selectedYear;
      if (newAllOrders.containsKey(0) && targetYear != 0) {
        newAllOrders[targetYear] = Map<int, String>.from(newAllOrders[0]!);
        newAllOrders.remove(0);
      }
      final yearMap = newAllOrders[targetYear] ?? <int, String>{};

      // Swap the two months
      final toUid = yearMap[targetMonth];
      if (fromUid != null) {
        yearMap[targetMonth] = fromUid;
      } else {
        yearMap.remove(targetMonth);
      }
      if (toUid != null) {
        yearMap[fromMonth] = toUid;
      } else {
        yearMap.remove(fromMonth);
      }
      newAllOrders[targetYear] = yearMap;

      await _tsiwaRepository.updateTsiwa(
        widget.areaId,
        tsiwa.copyWith(monthlyOrder: newAllOrders),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.orderSwapped)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.swapFailed)),
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
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.iconColor,
    this.trailing,
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ?trailing,
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
