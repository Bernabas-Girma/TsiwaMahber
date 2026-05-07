import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/developer/data/developer_service.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/features/settings/presentation/about_screen.dart';

class AppPopupMenu extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;
  final Future<void> Function()? onMemberLogout;

  const AppPopupMenu({
    super.key,
    required this.themeProvider,
    required this.localeProvider,
    this.onMemberLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isFirebaseSignedIn = FirebaseAuth.instance.currentUser != null;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _handleSelection(context, value),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'language',
          child: ListTile(
            leading: const Icon(Icons.language, size: 20),
            title: Text(
              localeProvider.isAmharic ? 'English' : 'አማርኛ',
            ),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        PopupMenuItem<String>(
          value: 'theme',
          child: ListTile(
            leading: const Icon(Icons.palette, size: 20),
            title: Text(S.chooseTheme),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'dev_login',
          child: ListTile(
            leading: const Icon(Icons.code, size: 20),
            title: Text(S.devSignIn),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        if (isFirebaseSignedIn || onMemberLogout != null)
          PopupMenuItem<String>(
            value: 'sign_out',
            child: ListTile(
              leading: const Icon(Icons.logout, size: 20,
                  color: Colors.orange),
              title: Text(S.signOut,
                  style: const TextStyle(color: Colors.orange)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        PopupMenuItem<String>(
          value: 'about',
          child: ListTile(
            leading: const Icon(Icons.info_outline, size: 20),
            title: Text(S.about),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'exit',
          child: ListTile(
            leading: const Icon(Icons.exit_to_app, size: 20,
                color: Colors.red),
            title: Text(S.exitApp,
                style: const TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSelection(BuildContext context, String value) async {
    switch (value) {
      case 'language':
        localeProvider.toggleLanguage();
        final label = localeProvider.isAmharic ? 'አማርኛ' : 'English';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Language: $label')),
          );
        }
        break;
      case 'theme':
        if (context.mounted) _showThemeChooser(context);
        break;
      case 'dev_login':
        _handleDevLogin(context);
        break;
      case 'sign_out':
        if (onMemberLogout != null) {
          await onMemberLogout!();
        } else {
          await GoogleSignIn().signOut();
          await FirebaseAuth.instance.signOut();
        }
        break;
      case 'about':
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AboutScreen()),
          );
        }
        break;
      case 'exit':
        exit(0);
    }
  }

  void _showThemeChooser(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final allModes = AppThemeMode.values;
        return SimpleDialog(
          title: Text(S.chooseTheme),
          children: allModes.map((mode) {
            final isSelected = themeProvider.mode == mode;
            String label;
            Color swatch;
            switch (mode) {
              case AppThemeMode.dark:
                label = S.darkTheme;
                swatch = AppTheme.primary;
              case AppThemeMode.light:
                label = S.lightTheme;
                swatch = AppTheme.primary;
              default:
                final config = AppTheme.premiumThemes[mode];
                if (config == null) return const SizedBox.shrink();
                label = LocaleProvider.instance.isAmharic
                    ? config.nameAm
                    : config.name;
                swatch = config.primary;
            }
            return SimpleDialogOption(
              onPressed: () {
                themeProvider.setTheme(mode);
                Navigator.pop(ctx);
              },
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: swatch,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, size: 18),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _handleDevLogin(BuildContext context) async {
    final devService = DeveloperService();
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Google Sign-In...'),
          ],
        ),
      ),
    );

    final error = await devService.signInWithGoogle();

    try {
      rootNavigator.pop();
    } catch (_) {
      // Dialog already dismissed by auth-state navigation
    }

    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}
