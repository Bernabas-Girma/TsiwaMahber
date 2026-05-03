import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/reports/data/report_service.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class TsiwaReportScreen extends StatefulWidget {
  final String areaId;

  const TsiwaReportScreen({super.key, required this.areaId});

  @override
  State<TsiwaReportScreen> createState() => _TsiwaReportScreenState();
}

class _TsiwaReportScreenState extends State<TsiwaReportScreen> {
  final _reportService = ReportService();
  bool _isLoading = true;
  List<TsiwaStats> _stats = [];
  Map<String, int> _leaderDist = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _reportService.getTsiwaStats(widget.areaId);
      final leaderDist =
          await _reportService.getLeaderRoleDistribution(widget.areaId);
      if (mounted) {
        setState(() {
          _stats = stats;
          _leaderDist = leaderDist;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.tsiwaReport)),
      body: _isLoading
          ? LoadingState(message: S.loading)
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: Text(S.retry),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_stats.isEmpty) {
      return Center(
        child: Text(
          S.noTsiwaRegistered,
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMemberCountChart(),
          const SizedBox(height: 24),
          _buildRoleDistribution(),
          const SizedBox(height: 24),
          if (_leaderDist.isNotEmpty) _buildLeaderDistribution(),
          if (_leaderDist.isNotEmpty) const SizedBox(height: 24),
          _buildTsiwaDetailCards(),
        ],
      ),
    );
  }

  Widget _buildMemberCountChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.membersByTsiwa,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: _stats.length * 48.0 + 16,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (_stats.isEmpty
                          ? 10
                          : _stats
                              .map((s) => s.totalMembers.toDouble())
                              .reduce((a, b) => a > b ? a : b))
                      .toDouble() *
                      1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final stat = _stats[group.x];
                        return BarTooltipItem(
                          '${stat.tsiwa.name}\n${stat.totalMembers} ማህበርተኞች',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= _stats.length) {
                            return const SizedBox.shrink();
                          }
                          final name = _stats[idx].tsiwa.name;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              name.length > 8
                                  ? '${name.substring(0, 8)}…'
                                  : name,
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.textMuted),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          if (value == value.roundToDouble()) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.textMuted),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade800,
                      strokeWidth: 0.5,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _stats.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.totalMembers.toDouble(),
                          color: AppTheme.primary,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDistribution() {
    final allRoles = <String, int>{};
    for (final stat in _stats) {
      for (final entry in stat.roleCounts.entries) {
        allRoles[entry.key] = (allRoles[entry.key] ?? 0) + entry.value;
      }
    }

    if (allRoles.isEmpty) return const SizedBox.shrink();

    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      Colors.blue,
      Colors.green,
      Colors.orange,
    ];

    final total = allRoles.values.fold<int>(0, (sum, v) => sum + v);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.roleDistribution,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: allRoles.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          final colorIdx = entry.key % colors.length;
                          final pct =
                              (entry.value.value / total * 100).toStringAsFixed(0);
                          return PieChartSectionData(
                            color: colors[colorIdx],
                            value: entry.value.value.toDouble(),
                            title: '$pct%',
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            radius: 50,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: allRoles.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final colorIdx = entry.key % colors.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[colorIdx],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${entry.value.key} (${entry.value.value})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderDistribution() {
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];
    final total = _leaderDist.values.fold<int>(0, (sum, v) => sum + v);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.leadersByRole,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: _leaderDist.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          final colorIdx = entry.key % colors.length;
                          final pct =
                              (entry.value.value / total * 100).toStringAsFixed(0);
                          return PieChartSectionData(
                            color: colors[colorIdx],
                            value: entry.value.value.toDouble(),
                            title: '$pct%',
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            radius: 50,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _leaderDist.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final colorIdx = entry.key % colors.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[colorIdx],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${entry.value.key} (${entry.value.value})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTsiwaDetailCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            S.byTsiwaGroup,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        ..._stats.map((stat) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.tsiwa.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _DetailChip(
                          label: S.total,
                          value: stat.totalMembers.toString(),
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        _DetailChip(
                          label: S.active,
                          value: stat.activeMembers.toString(),
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _DetailChip(
                          label: S.inRotation,
                          value: stat.inRotation.toString(),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    if (stat.roleCounts.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: stat.roleCounts.entries.map((e) {
                          return Chip(
                            label: Text(
                              '${e.key}: ${e.value}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                    ],
                    if (stat.totalMembers > 0) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: stat.activeMembers / stat.totalMembers,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.green),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(stat.activeMembers / stat.totalMembers * 100).toStringAsFixed(0)}% ንቁ',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
