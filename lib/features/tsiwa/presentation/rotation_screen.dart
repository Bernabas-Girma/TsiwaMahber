import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/utils/ethiopian_calendar.dart';
import 'package:tsiwa_mahber/core/widgets/empty_state.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/members/data/member_repository.dart';
import 'package:tsiwa_mahber/features/members/domain/member.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_event_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_event.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class RotationScreen extends StatefulWidget {
  final String areaId;
  final String tsiwaId;
  final String tsiwaName;

  const RotationScreen({
    super.key,
    required this.areaId,
    required this.tsiwaId,
    required this.tsiwaName,
  });

  @override
  State<RotationScreen> createState() => _RotationScreenState();
}

class _RotationScreenState extends State<RotationScreen>
    with SingleTickerProviderStateMixin {
  final _memberRepository = MemberRepository();
  final _eventRepository = TsiwaEventRepository();
  final _tsiwaRepository = TsiwaRepository();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.rotation),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: S.rotationOrderTab),
            Tab(text: S.eventHistory),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRotationOrder(), _buildEventHistory()],
      ),
    );
  }

  Widget _buildRotationOrder() {
    return StreamBuilder<TsiwaMahber?>(
      stream: _tsiwaRepository.watchTsiwa(widget.areaId, widget.tsiwaId),
      builder: (context, tsiwaSnapshot) {
        return StreamBuilder<List<Member>>(
          stream: _memberRepository.watchMembers(widget.areaId, widget.tsiwaId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingState(message: S.loading);
            }

            final members = snapshot.data ?? [];
            final rotationMembers =
                members.where((m) => m.isInRotation && m.isActive).toList()
                  ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

            if (rotationMembers.isEmpty) {
              return EmptyState(
                icon: Icons.rotate_right,
                title: S.noMembersInRotation,
                message: S.membersMustBeInRotation,
              );
            }

            final currentIndex = tsiwaSnapshot.data?.currentRotationIndex ?? 0;
            final safeIndex = currentIndex < rotationMembers.length
                ? currentIndex
                : 0;
            final nextIndex = (safeIndex + 1) % rotationMembers.length;

            return Column(
              children: [
                _buildCurrentNextCard(rotationMembers, safeIndex, nextIndex),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: rotationMembers.length,
                    itemBuilder: (context, index) {
                      final member = rotationMembers[index];
                      final isCurrent = index == safeIndex;
                      final isNext = index == nextIndex;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        color: isCurrent
                            ? AppTheme.primary.withValues(alpha: 0.1)
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCurrent
                                ? AppTheme.primary
                                : isNext
                                ? Colors.teal
                                : AppTheme.surface,
                            child: Text(
                              '${member.orderIndex}',
                              style: TextStyle(
                                color: isCurrent || isNext
                                    ? Colors.white
                                    : AppTheme.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            member.fullName,
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: member.christianName.isNotEmpty
                              ? Text(
                                  member.christianName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                )
                              : null,
                          trailing: isCurrent
                              ? const Chip(
                                  label: Text('አሁን'),
                                  backgroundColor: AppTheme.primary,
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                  ),
                                )
                              : isNext
                              ? Chip(
                                  label: Text(S.next),
                                  backgroundColor: Colors.teal.withValues(
                                    alpha: 0.3,
                                  ),
                                  labelStyle: const TextStyle(
                                    color: Colors.teal,
                                    fontSize: 11,
                                  ),
                                )
                              : null,
                          onTap: () => _setCurrentRotation(index),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCurrentNextCard(
    List<Member> members,
    int currentIdx,
    int nextIdx,
  ) {
    final current = members[currentIdx];
    final next = members[nextIdx];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.person, color: AppTheme.primary, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    S.currentTurn,
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: AppTheme.textMuted),
            Expanded(
              child: Column(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: Colors.teal,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.nextTurn,
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    next.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setCurrentRotation(int index) async {
    try {
      final tsiwaRef = _tsiwaRepository;
      final tsiwaStream = tsiwaRef.watchTsiwa(widget.areaId, widget.tsiwaId);
      final tsiwa = await tsiwaStream.first;
      if (tsiwa != null) {
        await tsiwaRef.updateTsiwa(
          widget.areaId,
          tsiwa.copyWith(currentRotationIndex: index),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.rotationUpdateFailed)));
      }
    }
  }

  Widget _buildEventHistory() {
    return StreamBuilder<List<TsiwaEvent>>(
      stream: _eventRepository.watchRecentEvents(widget.areaId, widget.tsiwaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingState(message: S.loading);
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return EmptyState(
            icon: Icons.history,
            title: S.noEventsYet,
            message: S.addEventHint,
            action: ElevatedButton.icon(
              onPressed: _createEvent,
              icon: const Icon(Icons.add),
              label: Text(S.recordEvent),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _EventCard(
                    event: event,
                    onStatusChange: (status) =>
                        _updateEventStatus(event.id, status),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createEvent() async {
    final members = await _memberRepository
        .watchMembers(widget.areaId, widget.tsiwaId)
        .first;
    final rotationMembers =
        members.where((m) => m.isInRotation && m.isActive).toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    if (!mounted) return;

    final ethToday = EthiopianCalendar.today();

    Member? selectedMember;
    if (rotationMembers.isNotEmpty) {
      final tsiwa = await _tsiwaRepository
          .watchTsiwa(widget.areaId, widget.tsiwaId)
          .first;
      final idx = tsiwa?.currentRotationIndex ?? 0;
      final safeIdx = idx < rotationMembers.length ? idx : 0;
      selectedMember = rotationMembers[safeIdx];
    }

    if (!mounted) return;

    final result = await showDialog<TsiwaEvent>(
      context: context,
      builder: (ctx) => _CreateEventDialog(
        ethToday: ethToday,
        members: rotationMembers,
        selectedMember: selectedMember,
      ),
    );

    if (result != null) {
      try {
        await _eventRepository.createEvent(
          widget.areaId,
          widget.tsiwaId,
          result,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.eventRecordFailed)));
        }
      }
    }
  }

  Future<void> _updateEventStatus(
    String eventId,
    TsiwaEventStatus status,
  ) async {
    try {
      await _eventRepository.updateEventStatus(
        widget.areaId,
        widget.tsiwaId,
        eventId,
        status,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.statusUpdateFailed)));
      }
    }
  }
}

class _EventCard extends StatelessWidget {
  final TsiwaEvent event;
  final ValueChanged<TsiwaEventStatus> onStatusChange;

  const _EventCard({required this.event, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (event.status) {
      case TsiwaEventStatus.completed:
        statusColor = AppTheme.success;
        break;
      case TsiwaEventStatus.cancelled:
        statusColor = Colors.red;
        break;
      case TsiwaEventStatus.planned:
        statusColor = AppTheme.primary;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.type.displayName,
                    style: TextStyle(fontSize: 11, color: statusColor),
                  ),
                ),
                const Spacer(),
                Text(
                  '${AppConstants.ethiopianMonthName(event.ethiopianMonth)} ${event.ethiopianDay}, ${event.ethiopianYear}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            if (event.responsibleMemberNameSnapshot.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    event.responsibleMemberNameSnapshot,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
            if (event.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                event.notes,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.status.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                if (event.status == TsiwaEventStatus.planned) ...[
                  _StatusButton(
                    label: S.completed,
                    color: AppTheme.success,
                    onTap: () => onStatusChange(TsiwaEventStatus.completed),
                  ),
                  const SizedBox(width: 8),
                  _StatusButton(
                    label: S.cancelled,
                    color: Colors.red,
                    onTap: () => onStatusChange(TsiwaEventStatus.cancelled),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: color)),
      ),
    );
  }
}

class _CreateEventDialog extends StatefulWidget {
  final EthiopianDate ethToday;
  final List<Member> members;
  final Member? selectedMember;

  const _CreateEventDialog({
    required this.ethToday,
    required this.members,
    this.selectedMember,
  });

  @override
  State<_CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<_CreateEventDialog> {
  late TsiwaEventType _type;
  late Member? _selectedMember;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = TsiwaEventType.monthlyTsiwa;
    _selectedMember = widget.selectedMember;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.recordEvent),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.type,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [TsiwaEventType.monthlyTsiwa, TsiwaEventType.yearlyZikir].map(
                    (type) {
                      final isSelected = _type == type;
                      return ChoiceChip(
                        label: Text(type.displayName),
                        selected: isSelected,
                        onSelected: (s) {
                          if (s) setState(() => _type = type);
                        },
                        selectedColor: AppTheme.primary.withValues(alpha: 0.3),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textMuted,
                        ),
                      );
                    },
                  ).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'ቀን: ${widget.ethToday.formatted}',
              style: const TextStyle(fontSize: 13),
            ),
            if (widget.members.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                S.responsibleMember,
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Member>(
                initialValue: _selectedMember,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: widget.members
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          '${m.orderIndex}. ${m.fullName}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (m) => setState(() => _selectedMember = m),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: S.note),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final event = TsiwaEvent(
              type: _type,
              ethiopianYear: widget.ethToday.year,
              ethiopianMonth: widget.ethToday.month,
              ethiopianDay: widget.ethToday.day,
              responsibleMemberId: _selectedMember?.id ?? '',
              responsibleMemberNameSnapshot: _selectedMember?.fullName ?? '',
              status: TsiwaEventStatus.planned,
              notes: _notesController.text.trim(),
            );
            Navigator.pop(context, event);
          },
          child: Text(S.record),
        ),
      ],
    );
  }
}
