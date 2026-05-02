import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir_member.dart';
import 'package:tsiwa_mahber/features/edir/presentation/record_payment_screen.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';

class EdirMemberTab extends StatefulWidget {
  final AppUser currentUser;

  const EdirMemberTab({
    super.key,
    required this.currentUser,
  });

  @override
  State<EdirMemberTab> createState() => _EdirMemberTabState();
}

class _EdirMemberTabState extends State<EdirMemberTab> {
  final _edirRepository = EdirRepository();

  @override
  Widget build(BuildContext context) {
    final edirIds = widget.currentUser.assignedEdirIds;
    final canManagePayments =
        widget.currentUser.isEdirAmerar ||
        widget.currentUser.role == UserRole.admin ||
        widget.currentUser.role == UserRole.developer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: edirIds
            .map((edirId) =>
                _buildEdirSection(edirId, canManagePayments))
            .toList(),
      ),
    );
  }

  Widget _buildEdirSection(String edirId, bool canManagePayments) {
    return StreamBuilder<Edir?>(
      stream: _edirRepository.watchEdir(AppConstants.defaultAreaId, edirId),
      builder: (context, edirSnap) {
        if (edirSnap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final edir = edirSnap.data;
        if (edir == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Edir header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.green,
                              size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                edir.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${S.monthlyContribution}: ${edir.monthlyContribution.toStringAsFixed(0)} $_birr',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        _statChip(
                          S.members,
                          '${edir.memberCount}',
                          Icons.people,
                          Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _statChip(
                          S.treasury,
                          '${edir.treasury.toStringAsFixed(0)} $_birr',
                          Icons.savings,
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Members and payment status
            Text(
              S.monthlyPayments,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            _buildMemberPaymentList(edir, canManagePayments),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildMemberPaymentList(Edir edir, bool canManagePayments) {
    return StreamBuilder<List<EdirMember>>(
      stream: _edirRepository.watchEdirMembers(AppConstants.defaultAreaId, edir.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingState(message: S.loading);
        }

        final members = snapshot.data ?? [];
        if (members.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                S.noMembersYet,
                style: const TextStyle(color: AppTheme.textMuted),
              ),
            ),
          );
        }

        return Column(
          children: members
              .map((m) => _buildMemberPaymentCard(
                  m, edir, canManagePayments))
              .toList(),
        );
      },
    );
  }

  Widget _buildMemberPaymentCard(
    EdirMember member,
    Edir edir,
    bool canManagePayments,
  ) {
    final isPaidUp = member.balance <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPaidUp
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.red.withValues(alpha: 0.15),
          child: Icon(
            isPaidUp ? Icons.check_circle : Icons.warning,
            color: isPaidUp ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(member.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _paymentChip(
                  S.paidBirr(member.totalPaid.toStringAsFixed(0)),
                  Colors.green,
                ),
                const SizedBox(width: 6),
                if (member.balance > 0)
                  _paymentChip(
                    S.owedBirr(member.balance.toStringAsFixed(0)),
                    Colors.red,
                  ),
              ],
            ),
          ],
        ),
        trailing: canManagePayments
            ? IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppTheme.primary),
                tooltip: S.recordPayment,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordPaymentScreen(
                        areaId: AppConstants.defaultAreaId,
                        edirId: edir.id,
                        member: member,
                        monthlyContribution: edir.monthlyContribution,
                      ),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }

  Widget _statChip(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 10, color: color)),
                Text(value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String get _birr => 'ብር';
}
