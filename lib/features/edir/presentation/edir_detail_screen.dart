import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/confirm_dialog.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/features/edir/presentation/edir_form_screen.dart';
import 'package:tsiwa_mahber/features/edir/presentation/edir_member_list_screen.dart';
import 'package:tsiwa_mahber/features/edir/presentation/edir_payment_list_screen.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class EdirDetailScreen extends StatefulWidget {
  final String areaId;
  final String edirId;

  const EdirDetailScreen({
    super.key,
    required this.areaId,
    required this.edirId,
  });

  @override
  State<EdirDetailScreen> createState() => _EdirDetailScreenState();
}

class _EdirDetailScreenState extends State<EdirDetailScreen> {
  final _repository = EdirRepository();
  late final Stream<Edir?> _edirStream;

  @override
  void initState() {
    super.initState();
    _edirStream = _repository.watchEdir(widget.areaId, widget.edirId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Edir?>(
      stream: _edirStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(S.edir)),
            body: Center(
              child: Text(
                S.dataLoadFailed,
                style: TextStyle(color: Colors.red.shade300),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(S.edir)),
            body: LoadingState(message: S.loading),
          );
        }

        final edir = snapshot.data;
        if (edir == null) {
          return Scaffold(
            appBar: AppBar(title: Text(S.edir)),
            body: Center(child: Text(S.edirNotFound)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(edir.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _openEditForm(edir),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(edir),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(edir),
                const SizedBox(height: 12),
                _buildStatsRow(edir),
                const SizedBox(height: 12),
                _buildMenuCard(
                  icon: Icons.people,
                  title: S.members,
                  subtitle: '${edir.memberCount} አባላት',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EdirMemberListScreen(
                          areaId: widget.areaId,
                          edirId: widget.edirId,
                          edirName: edir.name,
                          monthlyContribution: edir.monthlyContribution,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMenuCard(
                  icon: Icons.payment,
                  title: S.payments,
                  subtitle: S.paymentReport,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EdirPaymentListScreen(
                          areaId: widget.areaId,
                          edirId: widget.edirId,
                          edirName: edir.name,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(Edir edir) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    Icons.account_balance_wallet,
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
                        edir.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (edir.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          edir.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(S.monthlyDue,
                '${edir.monthlyContribution.toStringAsFixed(0)} ብር'),
            if (edir.penaltyAmount > 0)
              _buildDetailRow(S.penalty,
                  '${edir.penaltyAmount.toStringAsFixed(0)} ብር'),
            _buildDetailRow('የክፍያ ቀን', 'በወር ${edir.paymentDay}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Edir edir) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.people, color: AppTheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    '${edir.memberCount}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary),
                  ),
                  Text(S.members,
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.savings,
                      color: AppTheme.secondary),
                  const SizedBox(height: 8),
                  Text(
                    edir.treasury.toStringAsFixed(0),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary),
                  ),
                  Text(S.treasuryBirrLabel,
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
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
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textMuted)),
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

  void _openEditForm(Edir edir) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EdirFormScreen(areaId: widget.areaId, edir: edir),
      ),
    );
  }

  Future<void> _confirmDelete(Edir edir) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: S.deleteEdir,
      message: '"${edir.name}" እድርን ለመሰረዝ እርግጠኛ ነዎት?',
      confirmText: S.delete,
    );

    if (confirmed == true && mounted) {
      await _repository.deleteEdir(widget.areaId, edir.id);
      if (mounted) Navigator.pop(context);
    }
  }
}
