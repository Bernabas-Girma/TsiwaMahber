import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/empty_state.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/features/tsiwa/presentation/tsiwa_detail_screen.dart';
import 'package:tsiwa_mahber/features/tsiwa/presentation/tsiwa_form_screen.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class TsiwaListScreen extends StatefulWidget {
  final String areaId;
  final String? areaName;

  const TsiwaListScreen({super.key, required this.areaId, this.areaName});

  @override
  State<TsiwaListScreen> createState() => _TsiwaListScreenState();
}

class _TsiwaListScreenState extends State<TsiwaListScreen> {
  final _tsiwaRepository = TsiwaRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.tsiwaGroups)),
      body: StreamBuilder<List<TsiwaMahber>>(
        stream: _tsiwaRepository.watchTsiwas(widget.areaId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'መረጃውን ማግኘት አልተቻለም',
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingState(message: S.loading);
          }

          final tsiwas = snapshot.data ?? [];

          if (tsiwas.isEmpty) {
            return EmptyState(
              icon: Icons.groups_outlined,
              title: S.noTsiwaYet,
              message: S.addTsiwaHint,
              action: ElevatedButton.icon(
                onPressed: _openCreateForm,
                icon: const Icon(Icons.add),
                label: Text(S.newTsiwa),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: tsiwas.length,
            itemBuilder: (context, index) {
              return _TsiwaCard(
                tsiwa: tsiwas[index],
                onTap: () => _openDetail(tsiwas[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openCreateForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TsiwaFormScreen(areaId: widget.areaId),
      ),
    );
  }

  void _openDetail(TsiwaMahber tsiwa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TsiwaDetailScreen(areaId: widget.areaId, tsiwaId: tsiwa.id),
      ),
    );
  }
}

class _TsiwaCard extends StatelessWidget {
  final TsiwaMahber tsiwa;
  final VoidCallback onTap;

  const _TsiwaCard({required this.tsiwa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tsiwa.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!tsiwa.isActive || tsiwa.isArchived)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tsiwa.isArchived
                            ? Colors.orange.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tsiwa.isArchived ? S.archive : S.stopped,
                        style: TextStyle(
                          fontSize: 11,
                          color: tsiwa.isArchived ? Colors.orange : Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              if (tsiwa.churchName.isNotEmpty ||
                  tsiwa.saintName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  [
                    tsiwa.churchName,
                    tsiwa.saintName,
                  ].where((s) => s.isNotEmpty).join(' - '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
              if (tsiwa.location.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tsiwa.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildDayChip(
                    'ፅዋ ቀን ${tsiwa.monthlyTsiwaDay}',
                    AppTheme.primary,
                  ),
                  ...tsiwa.yearlyZikir.map(
                    (entry) => _buildDayChip(
                      '${AppConstants.ethiopianMonthName(entry.month)} ${entry.day}',
                      AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
