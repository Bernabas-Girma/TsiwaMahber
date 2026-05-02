import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/app_popup_menu.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/area/data/area_repository.dart';
import 'package:tsiwa_mahber/features/area/domain/area.dart';
import 'package:tsiwa_mahber/features/area/presentation/area_home_screen.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/developer/data/developer_service.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class AreaSelectionScreen extends StatefulWidget {
  final AppUser? currentUser;
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;

  const AreaSelectionScreen({
    super.key,
    this.currentUser,
    required this.themeProvider,
    required this.localeProvider,
  });

  @override
  State<AreaSelectionScreen> createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  final _areaRepository = AreaRepository();
  final _developerService = DeveloperService();

  @override
  void initState() {
    super.initState();
    _initDefaults();
  }

  Future<void> _initDefaults() async {
    try {
      await _areaRepository.ensureDefaultArea();
      await _developerService.ensureDefaultDevelopers();
    } catch (_) {
      // Ignore permission errors on first load; defaults will be
      // created once a developer signs in.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDev = widget.currentUser?.role.isDeveloper == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.appName),
        actions: [
          AppPopupMenu(
            themeProvider: widget.themeProvider,
            localeProvider: widget.localeProvider,
          ),
        ],
      ),
      body: StreamBuilder<List<Area>>(
        stream: _areaRepository.watchAllAreas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingState(message: S.loading);
          }

          final areas = snapshot.data ?? [];

          if (areas.isEmpty) {
            return Center(
              child: LoadingState(message: S.preparingData),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4, bottom: 16),
                child: Text(
                  S.selectArea,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...areas.map((area) => _AreaCard(
                    area: area,
                    onTap: () => _openArea(area),
                  )),
            ],
          );
        },
      ),
      floatingActionButton: isDev
          ? FloatingActionButton(
              onPressed: _showCreateAreaDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _openArea(Area area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AreaHomeScreen(
          currentUser: widget.currentUser,
          themeProvider: widget.themeProvider,
          localeProvider: widget.localeProvider,
        ),
      ),
    );
  }

  Future<void> _showCreateAreaDialog() async {
    final nameController = TextEditingController();
    final shortNameController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.newArea),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ስም *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: shortNameController,
                decoration:
                    const InputDecoration(labelText: 'አጭር ስም *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration:
                    InputDecoration(labelText: S.address),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration:
                    InputDecoration(labelText: S.description),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.create),
          ),
        ],
      ),
    );

    if (result == true) {
      final name = nameController.text.trim();
      final shortName = shortNameController.text.trim();

      if (name.isEmpty || shortName.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.nameAndShortRequired)),
          );
        }
        return;
      }

      try {
        final area = Area(
          id: '',
          name: name,
          shortName: shortName,
          location: locationController.text.trim(),
          description: descriptionController.text.trim(),
        );
        await _areaRepository.createArea(area);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.saveFailed)),
          );
        }
      }
    }

    nameController.dispose();
    shortNameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
  }
}

class _AreaCard extends StatelessWidget {
  final Area area;
  final VoidCallback onTap;

  const _AreaCard({required this.area, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
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
                  size: 28,
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
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (area.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        area.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
