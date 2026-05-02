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

  const TsiwaMemberTab({
    super.key,
    required this.currentUser,
  });

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
                      child: const Icon(Icons.church,
                          color: AppTheme.primary, size: 24),
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
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _roleDisplay(
                            widget.currentUser.tsiwaRoleFor(tsiwaId)),
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

  Widget _buildRotationCalendar(TsiwaMahber tsiwa, String tsiwaId) {
    return StreamBuilder<List<AppUser>>(
      stream: _authRepository.watchMembersByTsiwa(tsiwaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = snapshot.data ?? [];
        final rotationMembers =
            members.where((m) => m.role != UserRole.developer).toList();

        if (rotationMembers.isEmpty) {
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
        final currentIdx = tsiwa.currentRotationIndex % rotationMembers.length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      S.teregnaCalendar,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${S.monthlyTsiwaDay}: ${S.tsiwaDay(tsiwaDay)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMuted),
                ),
                const Divider(height: 24),

                // Current month
                _buildMonthEntry(
                  ethToday.month,
                  ethToday.year,
                  currentIdx,
                  rotationMembers,
                  isCurrent: true,
                ),

                const SizedBox(height: 8),

                // Next 5 months
                Text(
                  S.nextMonths,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(5, (i) {
                  int month = ethToday.month + i + 1;
                  int year = ethToday.year;
                  if (month > 13) {
                    month -= 13;
                    year++;
                  }
                  final idx =
                      (currentIdx + i + 1) % rotationMembers.length;
                  return _buildMonthEntry(
                    month,
                    year,
                    idx,
                    rotationMembers,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthEntry(
    int month,
    int year,
    int memberIndex,
    List<AppUser> members, {
    bool isCurrent = false,
  }) {
    final member = members[memberIndex];
    final monthName = AppConstants.ethiopianMonthName(month);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppTheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent
            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$monthName $year',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? AppTheme.primary : AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                S.teregna,
                style: const TextStyle(
                    fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: Text(
              member.displayName,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Announcement>>(
          stream: _announcementRepository.watchAnnouncements(AppConstants.defaultAreaId),
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
