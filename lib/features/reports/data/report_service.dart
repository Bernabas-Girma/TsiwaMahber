import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir_member.dart';
import 'package:tsiwa_mahber/features/edir/domain/payment.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';

class OverviewStats {
  final int totalTsiwas;
  final int totalMembers;
  final int totalLeaders;
  final int totalEdirs;
  final double totalTreasury;
  final int activeTsiwas;
  final int archivedTsiwas;

  const OverviewStats({
    this.totalTsiwas = 0,
    this.totalMembers = 0,
    this.totalLeaders = 0,
    this.totalEdirs = 0,
    this.totalTreasury = 0,
    this.activeTsiwas = 0,
    this.archivedTsiwas = 0,
  });
}

class TsiwaStats {
  final TsiwaMahber tsiwa;
  final int totalMembers;
  final int activeMembers;
  final int inRotation;
  final Map<String, int> roleCounts;

  const TsiwaStats({
    required this.tsiwa,
    this.totalMembers = 0,
    this.activeMembers = 0,
    this.inRotation = 0,
    this.roleCounts = const {},
  });
}

class EdirStats {
  final Edir edir;
  final List<EdirMember> members;
  final List<Payment> payments;
  final double totalCollected;
  final double totalOutstanding;
  final Map<String, double> paymentsByType;
  final Map<String, int> membersByStatus;

  const EdirStats({
    required this.edir,
    this.members = const [],
    this.payments = const [],
    this.totalCollected = 0,
    this.totalOutstanding = 0,
    this.paymentsByType = const {},
    this.membersByStatus = const {},
  });
}

class ReportService {
  final FirebaseFirestore _firestore;

  ReportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<OverviewStats> getOverviewStats(String areaId) async {
    final tsiwaSnap = await _firestore
        .collection(FirestorePaths.tsiwaMahbers(areaId))
        .get();
    final leaderSnap = await _firestore
        .collection(FirestorePaths.leaders(areaId))
        .get();
    final edirSnap = await _firestore
        .collection(FirestorePaths.edirs(areaId))
        .get();

    // Count actual members from users collection (not stale memberCount)
    final usersSnap = await _firestore
        .collection('users')
        .where('areaId', isEqualTo: areaId)
        .get();

    // Count unique members who are assigned to at least one tsiwa
    int totalMembers = 0;
    for (final doc in usersSnap.docs) {
      final data = doc.data();
      final tsiwaIds = data['assignedTsiwaIds'] as List<dynamic>?;
      if (tsiwaIds != null && tsiwaIds.isNotEmpty) {
        totalMembers++;
      }
    }

    final tsiwas = tsiwaSnap.docs
        .map((d) => TsiwaMahber.fromDoc(d, areaId))
        .toList();

    int activeTsiwas = 0;
    int archivedTsiwas = 0;
    for (final t in tsiwas) {
      if (t.isArchived) {
        archivedTsiwas++;
      } else if (t.isActive) {
        activeTsiwas++;
      }
    }

    double totalTreasury = 0;
    for (final doc in edirSnap.docs) {
      final edir = Edir.fromDoc(doc);
      totalTreasury += edir.treasury;
    }

    return OverviewStats(
      totalTsiwas: tsiwas.length,
      totalMembers: totalMembers,
      totalLeaders: leaderSnap.docs.length,
      totalEdirs: edirSnap.docs.length,
      totalTreasury: totalTreasury,
      activeTsiwas: activeTsiwas,
      archivedTsiwas: archivedTsiwas,
    );
  }

  Future<List<TsiwaStats>> getTsiwaStats(String areaId) async {
    final tsiwaSnap = await _firestore
        .collection(FirestorePaths.tsiwaMahbers(areaId))
        .get();

    // Fetch all users in this area once
    final usersSnap = await _firestore
        .collection('users')
        .where('areaId', isEqualTo: areaId)
        .get();

    final allUsers = usersSnap.docs.map((d) {
      final data = d.data();
      return (
        uid: d.id,
        displayName: data['displayName'] as String? ?? '',
        assignedTsiwaIds: List<String>.from(
            data['assignedTsiwaIds'] as List<dynamic>? ?? []),
        tsiwaRoles: Map<String, String>.from(
            data['tsiwaRoles'] as Map<dynamic, dynamic>? ?? {}),
        isActive: data['isActive'] as bool? ?? true,
        kickedOut: data['kickedOut'] as bool? ?? false,
      );
    }).toList();

    final stats = <TsiwaStats>[];

    for (final doc in tsiwaSnap.docs) {
      final tsiwa = TsiwaMahber.fromDoc(doc, areaId);
      final tsiwaId = doc.id;

      // Members assigned to this tsiwa from the users collection
      final tsiwaMembers = allUsers
          .where((u) => u.assignedTsiwaIds.contains(tsiwaId))
          .toList();

      int active = 0;
      final roleCounts = <String, int>{};

      for (final m in tsiwaMembers) {
        if (m.isActive && !m.kickedOut) active++;
        final role = m.tsiwaRoles[tsiwaId] ?? 'member';
        final roleLabel = _tsiwaRoleLabel(role);
        roleCounts[roleLabel] = (roleCounts[roleLabel] ?? 0) + 1;
      }

      stats.add(TsiwaStats(
        tsiwa: tsiwa,
        totalMembers: tsiwaMembers.length,
        activeMembers: active,
        inRotation: active,
        roleCounts: roleCounts,
      ));
    }

    stats.sort((a, b) => b.totalMembers.compareTo(a.totalMembers));
    return stats;
  }

  String _tsiwaRoleLabel(String role) {
    switch (role) {
      case 'muse':
        return 'ሙሴ';
      case 'assistant_muse':
        return 'ረዳት ሙሴ';
      case 'observer':
        return 'ታዛቢ';
      default:
        return 'ማህበርተኛ';
    }
  }

  Future<Map<String, int>> getLeaderRoleDistribution(String areaId) async {
    final snap = await _firestore
        .collection(FirestorePaths.leaders(areaId))
        .get();

    final dist = <String, int>{};
    for (final doc in snap.docs) {
      final leader = Leader.fromDoc(doc);
      final key = leader.role.displayName;
      dist[key] = (dist[key] ?? 0) + 1;
    }
    return dist;
  }

  Future<List<EdirStats>> getEdirStats(String areaId) async {
    final edirSnap = await _firestore
        .collection(FirestorePaths.edirs(areaId))
        .get();

    final stats = <EdirStats>[];

    for (final doc in edirSnap.docs) {
      final edir = Edir.fromDoc(doc);

      final memberSnap = await _firestore
          .collection(FirestorePaths.edirMembers(areaId, doc.id))
          .get();
      final members =
          memberSnap.docs.map((d) => EdirMember.fromDoc(d)).toList();

      final paymentSnap = await _firestore
          .collection(FirestorePaths.edirPayments(areaId, doc.id))
          .get();
      final payments =
          paymentSnap.docs.map((d) => Payment.fromDoc(d)).toList();

      double totalCollected = 0;
      double totalOutstanding = 0;
      final paymentsByType = <String, double>{};
      final membersByStatus = <String, int>{};

      for (final m in members) {
        totalOutstanding += m.balance > 0 ? m.balance : 0;
        final statusKey = m.status.displayName;
        membersByStatus[statusKey] = (membersByStatus[statusKey] ?? 0) + 1;
      }

      for (final p in payments) {
        totalCollected += p.amount;
        final typeKey = p.type.displayName;
        paymentsByType[typeKey] = (paymentsByType[typeKey] ?? 0) + p.amount;
      }

      stats.add(EdirStats(
        edir: edir,
        members: members,
        payments: payments,
        totalCollected: totalCollected,
        totalOutstanding: totalOutstanding,
        paymentsByType: paymentsByType,
        membersByStatus: membersByStatus,
      ));
    }

    return stats;
  }
}
