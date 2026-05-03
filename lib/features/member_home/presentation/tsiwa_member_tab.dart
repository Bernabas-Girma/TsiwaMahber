import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/utils/ethiopian_calendar.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/features/announcements/data/announcement_repository.dart';
import 'package:tsiwa_mahber/features/announcements/domain/announcement.dart';
import 'package:tsiwa_mahber/features/announcements/presentation/announcement_detail_screen.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';

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

  @override
  Widget build(BuildContext context) {
    final tsiwaIds = widget.currentUser.assignedTsiwaIds;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...tsiwaIds.map((tsiwaId) => _buildTsiwaSection(tsiwaId)),
          const SizedBox(height: 24),
          _buildAnnouncementsSection(),
        ],
      ),
    );
  }

  Widget _buildTsiwaSection(String tsiwaId) {
    return StreamBuilder<TsiwaMahber?>(
      stream: _tsiwaRepository.watchTsiwa(AppConstants.defaultAreaId, tsiwaId),
      builder: (context, tsiwaSnap) {
        if (tsiwaSnap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final tsiwa = tsiwaSnap.data;
        if (tsiwa == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tsiwa name header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.church,
                        color: AppTheme.primary,
                        size: 24,
                      ),
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
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
            ),

            const SizedBox(height: 12),

            // ተረኛ Calendar
            _buildRotationCalendar(tsiwa, tsiwaId),

            const SizedBox(height: 16),
          ],
        );
      },
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
    return StreamBuilder<List<AppUser>>(
      stream: _authRepository.watchMembersByTsiwa(tsiwaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = snapshot.data ?? [];
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
        final order = _orderForYear(tsiwa, ethToday.year);

        // Build member lookup map
        final memberMap = <String, AppUser>{};
        for (final m in members) {
          memberMap[m.uid] = m;
        }

        // Find this user's order month in current year
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
                // Header
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
                    Text(
                      S.yearLabel(ethToday.year),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
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
                if (myMonth != null) ...[
                  _buildMyOrderCard(myMonth, ethToday, tsiwaDay),
                  const SizedBox(height: 12),
                ],

                // Current month order
                _buildCurrentMonthCard(
                  ethToday.month,
                  order,
                  memberMap,
                ),
                const SizedBox(height: 12),

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

                // Next 6 months
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

                // Full 12-month table (expandable)
                _buildFullOrderTable(order, memberMap, ethToday, myMonth),
              ],
            ),
          ),
        );
      },
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
          _buildFullTableRow(m, order, memberMap, today, myMonth),
      ],
    );
  }

  Widget _buildFullTableRow(
    int month,
    Map<int, String> order,
    Map<String, AppUser> memberMap,
    EthiopianDate today,
    int? myMonth,
  ) {
    final memberId = order[month];
    final member = memberId != null ? memberMap[memberId] : null;
    final monthName = AppConstants.ethiopianMonthName(month);
    final isCurrent = today.month == month;
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
                fontWeight:
                    (isCurrent || isMyMonth) ? FontWeight.bold : FontWeight.normal,
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
          stream: _announcementRepository.watchAnnouncements(
            AppConstants.defaultAreaId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingState(message: S.loading);
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
