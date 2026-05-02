import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/app_popup_menu.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/auth/presentation/profile_screen.dart';
import 'package:tsiwa_mahber/features/member_home/presentation/tsiwa_member_tab.dart';
import 'package:tsiwa_mahber/features/member_home/presentation/edir_member_tab.dart';
import 'package:tsiwa_mahber/features/announcements/presentation/announcement_list_screen.dart';

class MemberHomeScreen extends StatefulWidget {
  final AppUser currentUser;
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;
  final Future<void> Function() onLogout;

  const MemberHomeScreen({
    super.key,
    required this.currentUser,
    required this.themeProvider,
    required this.localeProvider,
    required this.onLogout,
  });

  @override
  State<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;
    final hasTsiwa = user.hasTsiwaAssignment;
    final hasEdir = user.hasEdirAssignment;

    // Build navigation items and pages based on assignments
    final navItems = <BottomNavigationBarItem>[];
    final pages = <Widget>[];

    // Home / welcome tab is always first
    navItems.add(BottomNavigationBarItem(
      icon: const Icon(Icons.home),
      label: S.home,
    ));
    pages.add(_buildHomePage(user));

    if (hasTsiwa) {
      navItems.add(BottomNavigationBarItem(
        icon: const Icon(Icons.groups),
        label: S.myTsiwa,
      ));
      pages.add(TsiwaMemberTab(
        currentUser: user,
      ));
    }

    if (hasEdir) {
      navItems.add(BottomNavigationBarItem(
        icon: const Icon(Icons.account_balance_wallet),
        label: S.myEdir,
      ));
      pages.add(EdirMemberTab(
        currentUser: user,
      ));
    }

    // Clamp index
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: S.profile,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    user: user,
                    onLogout: widget.onLogout,
                  ),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: navItems.length > 1
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              selectedItemColor: AppTheme.primary,
              items: navItems,
            )
          : null,
    );
  }

  Widget _buildHomePage(AppUser user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${S.welcome}, ${user.displayName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.role.displayName,
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
            ),
          ),

          if (!user.hasTsiwaAssignment && !user.hasEdirAssignment) ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(Icons.info_outline,
                      size: 48, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    S.noAssignments,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.contactAdminForAssignment,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],

          // Quick access cards
          if (user.hasTsiwaAssignment) ...[
            const SizedBox(height: 16),
            _buildQuickCard(
              icon: Icons.groups,
              title: S.myTsiwa,
              subtitle: '${user.assignedTsiwaIds.length} ${S.tsiwaGroups}',
              color: Colors.amber,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
          ],

          if (user.hasEdirAssignment) ...[
            const SizedBox(height: 8),
            _buildQuickCard(
              icon: Icons.account_balance_wallet,
              title: S.myEdir,
              subtitle: '${user.assignedEdirIds.length} ${S.edir}',
              color: Colors.green,
              onTap: () {
                final idx = user.hasTsiwaAssignment ? 2 : 1;
                setState(() => _selectedIndex = idx);
              },
            ),
          ],

          const SizedBox(height: 8),
          _buildQuickCard(
            icon: Icons.campaign,
            title: S.announcements,
            subtitle: S.viewAnnouncements,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnnouncementListScreen(
                    areaId: user.areaId,
                    currentUser: user,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
