import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir_member.dart';
import 'package:tsiwa_mahber/features/edir/domain/payment.dart';

class EdirRepository {
  final FirebaseFirestore _firestore;

  EdirRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // --- Edir CRUD ---

  Stream<List<Edir>> watchEdirs(String areaId) {
    return _firestore
        .collection(FirestorePaths.edirs(areaId))
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Edir.fromDoc(doc)).toList());
  }

  Stream<Edir?> watchEdir(String areaId, String edirId) {
    return _firestore
        .doc(FirestorePaths.edir(areaId, edirId))
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Edir.fromDoc(doc);
    });
  }

  Future<void> createEdir(String areaId, Edir edir) async {
    await _firestore
        .collection(FirestorePaths.edirs(areaId))
        .add(edir.toCreateMap());
  }

  Future<void> updateEdir(String areaId, Edir edir) async {
    await _firestore
        .doc(FirestorePaths.edir(areaId, edir.id))
        .update(edir.toUpdateMap());
  }

  Future<void> deleteEdir(String areaId, String edirId) async {
    await _firestore.doc(FirestorePaths.edir(areaId, edirId)).delete();
  }

  Future<void> toggleEdirHidden(
      String areaId, String edirId, bool hidden) async {
    await _firestore.doc(FirestorePaths.edir(areaId, edirId)).update({
      'isHidden': hidden,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Edir Members ---

  Stream<List<EdirMember>> watchEdirMembers(String areaId, String edirId) {
    return _firestore
        .collection(FirestorePaths.edirMembers(areaId, edirId))
        .orderBy('fullName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EdirMember.fromDoc(doc)).toList());
  }

  Future<void> addEdirMember(
      String areaId, String edirId, EdirMember member) async {
    await _firestore
        .collection(FirestorePaths.edirMembers(areaId, edirId))
        .add(member.toCreateMap());
    await _updateMemberCount(areaId, edirId);
  }

  Future<void> updateEdirMember(
      String areaId, String edirId, EdirMember member) async {
    await _firestore
        .doc(FirestorePaths.edirMember(areaId, edirId, member.id))
        .update(member.toUpdateMap());
  }

  Future<void> deleteEdirMember(
      String areaId, String edirId, String memberId) async {
    await _firestore
        .doc(FirestorePaths.edirMember(areaId, edirId, memberId))
        .delete();
    await _updateMemberCount(areaId, edirId);
  }

  Future<void> _updateMemberCount(String areaId, String edirId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.edirMembers(areaId, edirId))
          .get();
      await _firestore.doc(FirestorePaths.edir(areaId, edirId)).update({
        'memberCount': snapshot.docs.length,
      });
    } catch (_) {}
  }

  // --- Payments ---

  Stream<List<Payment>> watchPayments(String areaId, String edirId) {
    return _firestore
        .collection(FirestorePaths.edirPayments(areaId, edirId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Payment.fromDoc(doc)).toList());
  }

  Stream<List<Payment>> watchMemberPayments(
      String areaId, String edirId, String memberId) {
    return _firestore
        .collection(FirestorePaths.edirPayments(areaId, edirId))
        .where('memberId', isEqualTo: memberId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Payment.fromDoc(doc)).toList());
  }

  Future<void> recordPayment(
      String areaId, String edirId, Payment payment) async {
    final batch = _firestore.batch();

    final paymentRef = _firestore
        .collection(FirestorePaths.edirPayments(areaId, edirId))
        .doc();
    batch.set(paymentRef, payment.toMap());

    final memberRef = _firestore
        .doc(FirestorePaths.edirMember(areaId, edirId, payment.memberId));
    batch.update(memberRef, {
      'totalPaid': FieldValue.increment(payment.amount),
      'balance': FieldValue.increment(-payment.amount),
      'lastPaymentDate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (payment.type == PaymentType.monthly)
        'paidMonths': FieldValue.increment(1),
    });

    if (payment.amount > 0) {
      final edirRef =
          _firestore.doc(FirestorePaths.edir(areaId, edirId));
      batch.update(edirRef, {
        'treasury': FieldValue.increment(payment.amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}
