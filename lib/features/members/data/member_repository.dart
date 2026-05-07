import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/features/members/domain/member.dart';

class MemberRepository {
  final FirebaseFirestore _firestore;

  MemberRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Member>> watchMembers(String areaId, String tsiwaId) {
    return _firestore
        .collection(FirestorePaths.members(areaId, tsiwaId))
        .snapshots()
        .map((snapshot) {
      final members = snapshot.docs
          .where((doc) => doc.data()['deletedAt'] == null)
          .map((doc) => Member.fromDoc(doc))
          .toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return members;
    });
  }

  Stream<Member?> watchMember(
      String areaId, String tsiwaId, String memberId) {
    return _firestore
        .doc(FirestorePaths.member(areaId, tsiwaId, memberId))
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Member.fromDoc(doc);
    });
  }

  Future<String?> checkDuplicate(
    String areaId,
    String tsiwaId,
    Member member, {
    String? excludeMemberId,
  }) async {
    final membersRef =
        _firestore.collection(FirestorePaths.members(areaId, tsiwaId));
    final snapshot =
        await membersRef.where('deletedAt', isNull: true).get();

    final normalizedPhone = member.normalizedPhone;
    final normalizedName = member.normalizedFullName;
    final normalizedChristian = member.normalizedChristianName;

    for (final doc in snapshot.docs) {
      if (excludeMemberId != null && doc.id == excludeMemberId) continue;

      final existing = Member.fromDoc(doc);

      if (normalizedPhone.isNotEmpty &&
          existing.normalizedPhone.isNotEmpty &&
          normalizedPhone == existing.normalizedPhone) {
        return 'ይህ ስልክ ቁጥር ቀድሞ ተመዝግቧል: ${existing.fullName}';
      }

      if (normalizedName.isNotEmpty &&
          normalizedChristian.isNotEmpty &&
          normalizedName == existing.normalizedFullName &&
          normalizedChristian == existing.normalizedChristianName) {
        return 'ይህ ስም ቀድሞ ተመዝግቧል: ${existing.fullName} / ${existing.christianName}';
      }
    }

    return null;
  }

  Future<int> getNextOrderIndex(String areaId, String tsiwaId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.members(areaId, tsiwaId))
        .get();

    int maxIndex = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['deletedAt'] != null) continue;
      final order = data['orderIndex'] as int? ?? 0;
      if (order > maxIndex) maxIndex = order;
    }
    return maxIndex + 1;
  }

  Future<void> createMember(
      String areaId, String tsiwaId, Member member) async {
    await _firestore
        .collection(FirestorePaths.members(areaId, tsiwaId))
        .add(member.toCreateMap());
    await _updateCounts(areaId, tsiwaId);
  }

  Future<void> updateMember(
      String areaId, String tsiwaId, Member member) async {
    await _firestore
        .doc(FirestorePaths.member(areaId, tsiwaId, member.id))
        .update(member.toUpdateMap());
    await _updateCounts(areaId, tsiwaId);
  }

  Future<void> softDeleteMember(
      String areaId, String tsiwaId, String memberId) async {
    await _firestore
        .doc(FirestorePaths.member(areaId, tsiwaId, memberId))
        .update({
      'deletedAt': FieldValue.serverTimestamp(),
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _updateCounts(areaId, tsiwaId);
  }

  Future<void> _updateCounts(String areaId, String tsiwaId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.members(areaId, tsiwaId))
          .get();

      int memberCount = 0;
      int museCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['deletedAt'] != null) continue;
        if (data['isActive'] != true) continue;
        memberCount++;
        final role = data['role'] as String?;
        if (role == 'muse' || role == 'assistant_muse') {
          museCount++;
        }
      }

      await _firestore
          .doc(FirestorePaths.tsiwaMahber(areaId, tsiwaId))
          .update({
        'memberCount': memberCount,
        'museCount': museCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Non-critical — counts will be updated on next member change
    }
  }
}
