import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/utils/ethiopian_calendar.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/features/announcements/data/announcement_repository.dart';
import 'package:tsiwa_mahber/features/announcements/domain/announcement.dart';
import 'package:tsiwa_mahber/features/announcements/presentation/announcement_detail_screen.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/utils/image_url_helper.dart';

class TsiwaMemberTab extends StatefulWidget {
  final AppUser currentUser;

  const TsiwaMemberTab({super.key, required this.currentUser});

  @override
  State<TsiwaMemberTab> createState() => _TsiwaMemberTabState();
}

class _TsiwaMemberTabState extends State<TsiwaMemberTab> {
  final _tsiwaRepository = TsiwaRepository();
  final _authRepository = AuthRepository();
  final _announcementRepository = AnnouncementRepository();
  late final Stream<List<Announcement>> _announcementStream;

  /// Cached tsiwa data — updated by stream subscriptions
  final Map<String, TsiwaMahber?> _tsiwaCache = {};
  final Map<String, List<AppUser>> _memberCache = {};
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _initialLoading = true;
  int _streamsReady = 0;

  /// Which tsiwa is currently selected (null = show list)
  String? _selectedTsiwaId;

  /// Year selector per tsiwa
  final Map<String, int> _selectedYears = {};

  @override
  void initState() {
    super.initState();
    _announcementStream = _announcementRepository.watchAnnouncements(
      AppConstants.defaultAreaId,
    );
    final ethYear = EthiopianCalendar.today().year;
    final ids = widget.currentUser.assignedTsiwaIds;
    final totalStreams = ids.length * 2; // tsiwa + members per id

    for (final id in ids) {
      _selectedYears[id] = ethYear;

      _subscriptions.add(
        _tsiwaRepository
            .watchTsiwa(AppConstants.defaultAreaId, id)
            .listen((tsiwa) {
          if (!mounted) return;
          final isFirst = !_tsiwaCache.containsKey(id);
          setState(() {
            _tsiwaCache[id] = tsiwa;
            if (isFirst) _onStreamReady(totalStreams);
          });
        }),
      );

      _subscriptions.add(
        _authRepository.watchMembersByTsiwa(id).listen((members) {
          if (!mounted) return;
          final isFirst = !_memberCache.containsKey(id);
          setState(() {
            _memberCache[id] = members;
            if (isFirst) _onStreamReady(totalStreams);
          });
        }),
      );
    }

    // If only one tsiwa, auto-select it
    if (ids.length == 1) {
      _selectedTsiwaId = ids.first;
    }
  }

  void _onStreamReady(int total) {
    _streamsReady++;
    if (_streamsReady >= total) {
      _initialLoading = false;
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedTsiwaId != null) {
      return _buildTsiwaDetail(_selectedTsiwaId!);
    }
    return _buildTsiwaList();
  }

  // ── Tsiwa list (multi-tsiwa users) ──

  Widget _buildTsiwaList() {
    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final tsiwaIds = widget.currentUser.assignedTsiwaIds;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...tsiwaIds.map((id) => _buildTsiwaListCard(id)),
          const SizedBox(height: 24),
          _buildAnnouncementsSection(),
        ],
      ),
    );
  }

  Widget _buildTsiwaListCard(String tsiwaId) {
    final tsiwa = _tsiwaCache[tsiwaId];
    if (tsiwa == null) return const SizedBox.shrink();

    final role = widget.currentUser.tsiwaRoleFor(tsiwaId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedTsiwaId = tsiwaId),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  image: tsiwa.profileImageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                              ImageUrlHelper.toDirectUrl(tsiwa.profileImageUrl)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: tsiwa.profileImageUrl.isEmpty
                    ? const Icon(Icons.church,
                        color: AppTheme.primary, size: 24)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tsiwa.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tsiwa.churchName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tsiwa.churchName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      S.tapToViewDetails,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _roleDisplay(role),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: AppTheme.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tsiwa detail view ──

  Widget _buildTsiwaDetail(String tsiwaId) {
    final hasMultipleTsiwas =
        widget.currentUser.assignedTsiwaIds.length > 1;

    final tsiwa = _tsiwaCache[tsiwaId];
    if (tsiwa == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasMultipleTsiwas)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton.icon(
                onPressed: () =>
                    setState(() => _selectedTsiwaId = null),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(S.backToList),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),

          _buildTsiwaHeader(tsiwa, tsiwaId),
          const SizedBox(height: 12),

          _buildRotationCalendar(tsiwa, tsiwaId),
          const SizedBox(height: 24),

          _buildAnnouncementsSection(),
        ],
      ),
    );
  }

  Widget _buildTsiwaHeader(TsiwaMahber tsiwa, String tsiwaId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                image: tsiwa.profileImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(
                            ImageUrlHelper.toDirectUrl(tsiwa.profileImageUrl)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: tsiwa.profileImageUrl.isEmpty
                  ? const Icon(Icons.church,
                      color: AppTheme.primary, size: 24)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tsiwa.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (tsiwa.churchName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      tsiwa.churchName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _roleDisplay(widget.currentUser.tsiwaRoleFor(tsiwaId)),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Resolve the order map for a given year, handling legacy year-0 data.
  Map<int, String> _orderForYear(TsiwaMahber tsiwa, int year) {
    if (tsiwa.monthlyOrder.containsKey(year)) {
      return tsiwa.monthlyOrder[year]!;
    }
    if (tsiwa.monthlyOrder.containsKey(0)) {
      return tsiwa.monthlyOrder[0]!;
    }
    return {};
  }

  Widget _buildRotationCalendar(TsiwaMahber tsiwa, String tsiwaId) {
        final members = _memberCache[tsiwaId] ?? [];
        if (members.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                S.noMembersInRotation,
                style: const TextStyle(color: AppTheme.textMuted),
              ),
            ),
          );
        }

        final ethToday = EthiopianCalendar.today();
        final tsiwaDay = tsiwa.monthlyTsiwaDay;
        final selectedYear = _selectedYears[tsiwaId] ?? ethToday.year;
        final order = _orderForYear(tsiwa, selectedYear);

        // Build member lookup map
        final memberMap = <String, AppUser>{};
        for (final m in members) {
          memberMap[m.uid] = m;
        }

        // Find this user's order month in selected year
        int? myMonth;
        for (final entry in order.entries) {
          if (entry.value == widget.currentUser.uid) {
            myMonth = entry.key;
            break;
          }
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with year switcher
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        S.teregnaCalendar,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Year switcher
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: () => setState(() {
                        _selectedYears[tsiwaId] = selectedYear - 1;
                      }),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        S.yearLabel(selectedYear),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: () => setState(() {
                        _selectedYears[tsiwaId] = selectedYear + 1;
                      }),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${S.monthlyTsiwaDay}: ${S.tsiwaDay(tsiwaDay)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                const Divider(height: 24),

                // My next order month + countdown
                if (myMonth != null &&
                    selectedYear == ethToday.year) ...[
                  _buildMyOrderCard(myMonth, ethToday, tsiwaDay),
                  const SizedBox(height: 12),
                ],

                // Current month order (only for current year)
                if (selectedYear == ethToday.year) ...[
                  _buildCurrentMonthCard(
                    ethToday.month,
                    order,
                    memberMap,
                  ),
                  const SizedBox(height: 12),
                ],

                // Yearly Zikir dates
                if (tsiwa.yearlyZikir.isNotEmpty) ...[
                  ...tsiwa.yearlyZikir.map((entry) {
                    final monthName = AppConstants.ethiopianMonthName(
                      entry.month,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppTheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${S.yearlyZikirTitle}: $monthName ${entry.day}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],

                // Upcoming orders (next 6 months for current year)
                if (selectedYear == ethToday.year) ...[
                  Text(
                    S.upcomingOrders,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(6, (i) {
                    int month = ethToday.month + i + 1;
                    if (month > AppConstants.tsiwaMonthCount) {
                      month -= AppConstants.tsiwaMonthCount;
                    }
                    return _buildMonthOrderEntry(
                      month,
                      order,
                      memberMap,
                      isMyMonth: month == myMonth,
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Full 12-month table (expandable)
                _buildFullOrderTable(order, memberMap, ethToday, myMonth,
                    selectedYear == ethToday.year),
              ],
            ),
          ),
        );
  }

  Widget _buildMyOrderCard(int myMonth, EthiopianDate today, int tsiwaDay) {
    final monthName = AppConstants.ethiopianMonthName(myMonth);
    final daysUntil = EthiopianCalendar.daysUntilDate(myMonth, tsiwaDay);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withValues(alpha: 0.15),
            AppTheme.primary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, color: Colors.deepPurple, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.yourNextOrder,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  '$monthName $tsiwaDay',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: daysUntil <= 7
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.deepPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              S.daysRemaining(daysUntil),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: daysUntil <= 7 ? Colors.red : Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMonthCard(
    int currentMonth,
    Map<int, String> order,
    Map<String, AppUser> memberMap,
  ) {
    final memberId = order[currentMonth];
    final member = memberId != null ? memberMap[memberId] : null;
    final monthName = AppConstants.ethiopianMonthName(currentMonth);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${S.currentOrder} - $monthName',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member?.displayName ?? S.unassigned,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              S.teregna,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthOrderEntry(
    int month,
    Map<int, String> order,
    Map<String, AppUser> memberMap, {
    bool isMyMonth = false,
  }) {
    final memberId = order[month];
    final member = memberId != null ? memberMap[memberId] : null;
    final monthName = AppConstants.ethiopianMonthName(month);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMyMonth
            ? Colors.deepPurple.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isMyMonth
            ? Border.all(
                color: Colors.deepPurple.withValues(alpha: 0.2),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              monthName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isMyMonth ? FontWeight.bold : FontWeight.normal,
                color: isMyMonth ? Colors.deepPurple : AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              member?.displayName ?? S.unassigned,
              style: TextStyle(
                fontWeight: isMyMonth ? FontWeight.w600 : FontWeight.normal,
                color: member == null ? AppTheme.textMuted : null,
              ),
            ),
          ),
          if (isMyMonth)
            const Icon(Icons.star, size: 16, color: Colors.deepPurple),
        ],
      ),
    );
  }

  Widget _buildFullOrderTable(
    Map<int, String> order,
    Map<String, AppUser> memberMap,
    EthiopianDate today,
    int? myMonth,
    bool isCurrentYear,
  ) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        S.allOrders,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: const Icon(Icons.table_chart, size: 20),
      children: [
        for (int m = 1; m <= AppConstants.tsiwaMonthCount; m++)
          _buildFullTableRow(m, order, memberMap, today, myMonth,
              isCurrentYear),
      ],
    );
  }

  Widget _buildFullTableRow(
    int month,
    Map<int, String> order,
    Map<String, AppUser> memberMap,
    EthiopianDate today,
    int? myMonth,
    bool isCurrentYear,
  ) {
    final memberId = order[month];
    final member = memberId != null ? memberMap[memberId] : null;
    final monthName = AppConstants.ethiopianMonthName(month);
    final isCurrent = isCurrentYear && today.month == month;
    final isMyMonth = month == myMonth;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppTheme.primary.withValues(alpha: 0.08)
            : isMyMonth
                ? Colors.deepPurple.withValues(alpha: 0.06)
                : null,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.textMuted.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              monthName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: (isCurrent || isMyMonth)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              member?.displayName ?? S.unassigned,
              style: TextStyle(
                fontSize: 13,
                color: member == null ? AppTheme.textMuted : null,
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
                borderRadius: BorderRadius.circular(6),
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
          if (isMyMonth && !isCurrent)
            const Icon(Icons.star, size: 14, color: Colors.deepPurple),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.campaign, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              S.announcements,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Announcement>>(
          stream: _announcementStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }

            final announcements = snapshot.data ?? [];
            if (announcements.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    S.noAnnouncementsYet,
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              );
            }

            // Show the latest 5
            final recent = announcements.take(5).toList();
            return Column(
              children: recent.map((a) => _buildAnnouncementCard(a)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.campaign,
          color: _priorityColor(announcement.priority),
        ),
        title: Text(
          announcement.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          announcement.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailScreen(
                areaId: AppConstants.defaultAreaId,
                announcementId: announcement.id,
                currentUser: widget.currentUser,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _priorityColor(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return Colors.red;
      case AnnouncementPriority.important:
        return Colors.orange;
      case AnnouncementPriority.normal:
        return Colors.blue;
    }
  }

  String _roleDisplay(String role) {
    switch (role) {
      case 'muse':
        return S.roleMuse;
      case 'assistant_muse':
        return S.roleAssistantMuse;
      case 'observer':
        return S.roleObserver;
      default:
        return S.roleMemberTsiwa;
    }
  }
}
