import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/app_card.dart';
import 'package:tsiwa_mahber/core/widgets/app_popup_menu.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/area/data/area_repository.dart';
import 'package:tsiwa_mahber/features/area/domain/area.dart';
import 'package:tsiwa_mahber/features/leadership/data/leader_repository.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';
import 'package:tsiwa_mahber/features/leadership/presentation/leader_list_screen.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/features/edir/presentation/edir_list_screen.dart';
import 'package:tsiwa_mahber/features/announcements/data/announcement_repository.dart';
import 'package:tsiwa_mahber/features/announcements/domain/announcement.dart';
import 'package:tsiwa_mahber/features/announcements/presentation/announcement_list_screen.dart';
import 'package:tsiwa_mahber/features/notifications/data/notification_repository.dart';
import 'package:tsiwa_mahber/features/notifications/presentation/notification_list_screen.dart';
import 'package:tsiwa_mahber/features/notifications/presentation/telegram_settings_screen.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/auth/presentation/profile_screen.dart';
import 'package:tsiwa_mahber/features/auth/presentation/user_management_screen.dart';
import 'package:tsiwa_mahber/features/csv_io/presentation/csv_export_screen.dart';
import 'package:tsiwa_mahber/features/csv_io/presentation/csv_import_screen.dart';
import 'package:tsiwa_mahber/features/reports/presentation/report_home_screen.dart';
import 'package:tsiwa_mahber/features/tsiwa/presentation/tsiwa_list_screen.dart';
import 'package:tsiwa_mahber/features/developer/presentation/developer_management_screen.dart';
import 'package:tsiwa_mahber/features/global_members/presentation/global_member_list_screen.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';

class AreaHomeScreen extends StatefulWidget {
  final AppUser? currentUser;
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;
  final Future<void> Function()? onLogout;

  const AreaHomeScreen({
    super.key,
    this.currentUser,
    required this.themeProvider,
    required this.localeProvider,
    this.onLogout,
  });

  String get areaId => AppConstants.defaultAreaId;
  String get areaName => AppConstants.defaultAreaName;

  @override
  State<AreaHomeScreen> createState() => _AreaHomeScreenState();
}

class _AreaHomeScreenState extends State<AreaHomeScreen> {
  final _areaRepository = AreaRepository();
  final _tsiwaRepository = TsiwaRepository();
  final _leaderRepository = LeaderRepository();
  final _edirRepository = EdirRepository();
  final _announcementRepository = AnnouncementRepository();
  final _notificationRepository = NotificationRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.areaName),
        actions: [
          if (widget.currentUser != null)
            StreamBuilder<int>(
              stream: _notificationRepository.watchUnreadCount(
                  widget.currentUser!.uid),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return IconButton(
                  icon: Badge(
                    isLabelVisible: count > 0,
                    label: Text(count.toString()),
                    child: const Icon(Icons.notifications),
                  ),
                  tooltip: S.notifications,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NotificationListScreen(
                          userId: widget.currentUser!.uid,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          if (widget.currentUser?.role.canManageUsers == true)
            IconButton(
              icon: const Icon(Icons.people),
              tooltip: S.users,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserManagementScreen(areaId: widget.areaId),
                  ),
                );
              },
            ),
          if (widget.currentUser != null)
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: S.profile,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(user: widget.currentUser!),
                  ),
                );
              },
            ),
          AppPopupMenu(
            themeProvider: widget.themeProvider,
            localeProvider: widget.localeProvider,
            onMemberLogout: widget.onLogout,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<Area?>(
      stream: _areaRepository.watchArea(widget.areaId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  S.dataLoadFailed,
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingState(message: S.loading);
        }

        final area = snapshot.data;
        if (area == null) {
          return Center(
            child: LoadingState(message: S.preparingData),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(area),
              const SizedBox(height: 16),
              _buildDashboardStats(),
              const SizedBox(height: 16),
              _buildMenuSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Area area) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.church,
                      color: AppTheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          area.location,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (area.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  area.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
              if (widget.currentUser != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.currentUser!.role.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    final role = widget.currentUser?.role;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            S.services,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AppInfoCard(
          icon: Icons.people,
          title: S.globalMembers,
          subtitle: S.manageGlobalMembers,
          iconColor: Colors.teal,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GlobalMemberListScreen(),
              ),
            );
          },
        ),
        AppInfoCard(
          icon: Icons.groups,
          title: S.tsiwaGroups,
          subtitle: S.manageTsiwaGroups,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TsiwaListScreen(
                  areaId: widget.areaId,
                  areaName: widget.areaName,
                ),
              ),
            );
          },
        ),
        AppInfoCard(
          icon: Icons.admin_panel_settings,
          title: S.leaders,
          subtitle: S.manageLeaders,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeaderListScreen(
                  areaId: widget.areaId,
                ),
              ),
            );
          },
        ),
        AppInfoCard(
          icon: Icons.account_balance_wallet,
          title: S.edir,
          subtitle: S.manageEdir,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EdirListScreen(
                  areaId: widget.areaId,
                ),
              ),
            );
          },
        ),
        AppInfoCard(
          icon: Icons.campaign,
          title: 'ማስታወቂያዎች',
          subtitle: S.viewAnnouncements,
          trailing: _buildUnreadBadge(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnnouncementListScreen(
                  areaId: widget.areaId,
                  currentUser: widget.currentUser,
                ),
              ),
            );
          },
        ),
        if (role?.isAdminOrAbove == true)
          AppInfoCard(
            icon: Icons.telegram,
            title: S.telegram,
            subtitle: S.telegramBot,
            iconColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelegramSettingsScreen(
                    areaId: widget.areaId,
                  ),
                ),
              );
            },
          ),
        if (role?.canEdit == true)
          AppInfoCard(
            icon: Icons.file_upload_outlined,
            title: S.csvExportMenu,
            subtitle: S.csvExportSub,
            iconColor: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CsvExportScreen(
                    areaId: widget.areaId,
                  ),
                ),
              );
            },
          ),
        if (role?.canEdit == true)
          AppInfoCard(
            icon: Icons.file_download_outlined,
            title: S.csvImportMenu,
            subtitle: 'CSV ፋይል መረጃ አስገባ',
            iconColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CsvImportScreen(
                    areaId: widget.areaId,
                  ),
                ),
              );
            },
          ),
        AppInfoCard(
          icon: Icons.bar_chart,
          title: S.reports,
          subtitle: S.reportsAndAnalytics,
          iconColor: Colors.indigo,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportHomeScreen(
                  areaId: widget.areaId,
                ),
              ),
            );
          },
        ),
        if (role?.isDeveloper == true)
          AppInfoCard(
            icon: Icons.code,
            title: S.developers,
            subtitle: S.developerManagement,
            iconColor: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const DeveloperManagementScreen(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildUnreadBadge() {
    final userId = widget.currentUser?.uid ?? '';
    if (userId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: _announcementRepository.watchUnreadCount(
          widget.areaId, userId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        if (count == 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
                color: Colors.white, fontSize: 12),
          ),
        );
      },
    );
  }

  Widget _buildDashboardStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: StreamBuilder<List<TsiwaMahber>>(
              stream: _tsiwaRepository.watchTsiwas(widget.areaId),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return _StatCard(
                  label: S.tsiwaGroups,
                  value: count.toString(),
                  icon: Icons.groups,
                  color: AppTheme.primary,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StreamBuilder<List<Leader>>(
              stream: _leaderRepository.watchLeaders(widget.areaId),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return _StatCard(
                  label: S.leaders,
                  value: count.toString(),
                  icon: Icons.admin_panel_settings,
                  color: AppTheme.secondary,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StreamBuilder<List<Edir>>(
              stream: _edirRepository.watchEdirs(widget.areaId),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return _StatCard(
                  label: S.edir,
                  value: count.toString(),
                  icon: Icons.account_balance_wallet,
                  color: Colors.purple,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StreamBuilder<List<Announcement>>(
              stream: _announcementRepository.watchAnnouncements(
                  widget.areaId),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return _StatCard(
                  label: S.announcement,
                  value: count.toString(),
                  icon: Icons.campaign,
                  color: Colors.teal,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
