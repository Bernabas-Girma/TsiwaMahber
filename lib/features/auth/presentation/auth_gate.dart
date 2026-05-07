import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/app_popup_menu.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/auth/presentation/login_screen.dart';
import 'package:tsiwa_mahber/features/area/data/area_repository.dart';
import 'package:tsiwa_mahber/features/area/presentation/area_home_screen.dart';
import 'package:tsiwa_mahber/features/developer/data/developer_service.dart';
import 'package:tsiwa_mahber/features/member_home/presentation/member_home_screen.dart';
import 'package:tsiwa_mahber/core/services/notification_listener_service.dart';
import 'package:tsiwa_mahber/core/services/local_notification_service.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/features/announcements/presentation/announcement_detail_screen.dart';
import 'package:tsiwa_mahber/features/chat/presentation/chat_screen.dart';

class AuthGate extends StatefulWidget {
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;

  const AuthGate({
    super.key,
    required this.themeProvider,
    required this.localeProvider,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authRepository = AuthRepository();
  final _areaRepository = AreaRepository();
  final _developerService = DeveloperService();
  bool _defaultsInitialized = false;

  AppUser? _memberUser;
  StreamSubscription<AppUser?>? _memberWatchSub;

  late final Stream<User?> _authStream;

  // Developer's AppUser loaded once per sign-in (not streamed).
  AppUser? _devUser;
  bool _devUserLoading = false;
  String? _loadedDevUid;

  @override
  void initState() {
    super.initState();
    _authStream = _authRepository.authStateChanges;
    _setupNotificationTapHandler();
  }

  void _setupNotificationTapHandler() {
    LocalNotificationService.onNotificationTap = (payload) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final type = data['type'] as String?;
        final ctx = context;
        if (!mounted) return;

        if (type == 'announcement') {
          final announcementId = data['announcementId'] as String?;
          final areaId = data['areaId'] as String?;
          if (announcementId != null && areaId != null) {
            final user = _memberUser ?? _devUser;
            Navigator.of(ctx).push(
              MaterialPageRoute(
                builder: (_) => AnnouncementDetailScreen(
                  areaId: areaId,
                  announcementId: announcementId,
                  currentUser: user,
                ),
              ),
            );
          }
        } else if (type == 'chat') {
          final roomId = data['roomId'] as String?;
          final roomName = data['roomName'] as String? ?? 'Chat';
          final areaId = data['areaId'] as String?;
          final user = _memberUser ?? _devUser;
          if (roomId != null && areaId != null && user != null) {
            Navigator.of(ctx).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  areaId: areaId,
                  roomId: roomId,
                  roomName: roomName,
                  currentUser: user,
                ),
              ),
            );
          }
        }
      } catch (_) {}
    };
  }

  Future<void> _initDefaults() async {
    if (_defaultsInitialized) return;
    _defaultsInitialized = true;
    try {
      await _areaRepository.ensureDefaultArea();
      await _developerService.ensureDefaultDevelopers();
    } catch (_) {
      // Silently ignore; area/dev docs may already exist.
    }
  }

  Future<void> _loadDevUser(String uid) async {
    if (_loadedDevUid == uid) return;
    _loadedDevUid = uid;
    setState(() => _devUserLoading = true);
    try {
      // Ensure default area and developers exist now that we have
      // authenticated dev credentials for Firestore writes.
      await _initDefaults();
      final user = await _authRepository.getAppUser(uid);
      if (mounted) {
        setState(() {
          _devUser = user;
          _devUserLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _devUser = null;
          _devUserLoading = false;
        });
      }
    }
  }

  void _startNotifications(String userId) {
    NotificationListenerService().start(
      userId: userId,
      areaId: AppConstants.defaultAreaId,
    );
  }

  void _onMemberLogin(AppUser user) {
    _startNotifications(user.uid);
    _memberWatchSub?.cancel();
    _memberWatchSub = _authRepository.watchAppUser(user.uid).listen((updated) {
      if (!mounted) return;
      if (updated == null || updated.kickedOut || !updated.isActive) {
        _logoutMember();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.accountKicked)),
          );
        }
        return;
      }
      if (mounted) setState(() => _memberUser = updated);
    });
    setState(() => _memberUser = user);
  }

  Future<void> _logoutMember() async {
    NotificationListenerService().stop();
    _memberWatchSub?.cancel();
    _memberWatchSub = null;
    // Sign out the anonymous Firebase Auth session.
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      await FirebaseAuth.instance.signOut();
    }
    if (mounted) setState(() => _memberUser = null);
  }

  @override
  void dispose() {
    _memberWatchSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: LoadingState(message: S.loading),
          );
        }

        final firebaseUser = snapshot.data;

        // Anonymous Firebase Auth is used by members for Firestore writes.
        // Skip dev-user loading for anonymous sessions.
        if (firebaseUser != null && !firebaseUser.isAnonymous) {
          // Load dev user once (no StreamBuilder, no tree rebuilds).
          if (_loadedDevUid != firebaseUser.uid) {
            // Defer to avoid calling setState during build.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _loadDevUser(firebaseUser.uid);
            });
            return Scaffold(
              body: LoadingState(message: S.loadingUser),
            );
          }

          if (_devUserLoading) {
            return Scaffold(
              body: LoadingState(message: S.loadingUser),
            );
          }

          if (_devUser != null && !_devUser!.isActive) {
            return _buildBlockedScreen();
          }

          if (_devUser != null) {
            _startNotifications(_devUser!.uid);
          }

          return AreaHomeScreen(
            currentUser: _devUser,
            themeProvider: widget.themeProvider,
            localeProvider: widget.localeProvider,
          );
        }

        // Reset dev state when signed out.
        if (_loadedDevUid != null) {
          _loadedDevUid = null;
          _devUser = null;
        }

        if (_memberUser != null) {
          return MemberHomeScreen(
            key: ValueKey('member_${_memberUser!.uid}'),
            currentUser: _memberUser!,
            themeProvider: widget.themeProvider,
            localeProvider: widget.localeProvider,
            onLogout: _logoutMember,
          );
        }

        return LoginScreen(
          key: const ValueKey('login'),
          themeProvider: widget.themeProvider,
          localeProvider: widget.localeProvider,
          onMemberLogin: _onMemberLogin,
        );
      },
    );
  }

  Widget _buildBlockedScreen() {
    return Scaffold(
      appBar: AppBar(
        actions: [
          AppPopupMenu(
            themeProvider: widget.themeProvider,
            localeProvider: widget.localeProvider,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64,
                  color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                S.accountBlocked,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                S.contactAdmin,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _authRepository.signOut(),
                child: Text(S.exitAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
