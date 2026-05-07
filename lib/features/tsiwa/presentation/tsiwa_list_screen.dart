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
  late final Stream<List<TsiwaMahber>> _tsiwaStream;
  bool _reorderMode = false;

  @override
  void initState() {
    super.initState();
    _tsiwaStream = _tsiwaRepository.watchTsiwas(widget.areaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.tsiwaGroups),
        actions: [
          IconButton(
            icon: Icon(_reorderMode ? Icons.check : Icons.swap_vert),
            tooltip: S.reorderTsiwas,
            onPressed: () => setState(() => _reorderMode = !_reorderMode),
          ),
        ],
      ),
      body: StreamBuilder<List<TsiwaMahber>>(
        stream: _tsiwaStream,
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
                showReorder: _reorderMode,
                canMoveUp: _reorderMode && index > 0,
                canMoveDown: _reorderMode && index < tsiwas.length - 1,
                onMoveUp: () => _swapOrder(tsiwas, index, index - 1),
                onMoveDown: () => _swapOrder(tsiwas, index, index + 1),
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

  Future<void> _swapOrder(List<TsiwaMahber> tsiwas, int from, int to) async {
    final reordered = List<TsiwaMahber>.from(tsiwas);
    final item = reordered.removeAt(from);
    reordered.insert(to, item);
    try {
      await _tsiwaRepository.reorderTsiwas(widget.areaId, reordered);
    } catch (_) {}
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
  final bool showReorder;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _TsiwaCard({
    required this.tsiwa,
    required this.onTap,
    this.showReorder = false,
    this.canMoveUp = false,
    this.canMoveDown = false,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: showReorder ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (showReorder) ...[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_upward,
                        size: 18,
                        color: canMoveUp ? AppTheme.primary : AppTheme.textMuted,
                      ),
                      onPressed: canMoveUp ? onMoveUp : null,
                      constraints: const BoxConstraints(minHeight: 28, minWidth: 28),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_downward,
                        size: 18,
                        color: canMoveDown ? AppTheme.primary : AppTheme.textMuted,
                      ),
                      onPressed: canMoveDown ? onMoveDown : null,
                      constraints: const BoxConstraints(minHeight: 28, minWidth: 28),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
              if (tsiwa.profileImageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      tsiwa.profileImageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.church,
                            color: AppTheme.primary, size: 24),
                      ),
                    ),
                  ),
                ),
              Expanded(
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
                                color: tsiwa.isArchived
                                    ? Colors.orange
                                    : Colors.red,
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
