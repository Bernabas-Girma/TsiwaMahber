import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Member (phone+code) auth ──

  Future<AppUser> signInWithPhone(String phone, String code) async {
    // Search primary phone
    var query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    // If not found, search secondary phone (phone2)
    if (query.docs.isEmpty) {
      query = await _firestore
          .collection('users')
          .where('phone2', isEqualTo: phone)
          .limit(1)
          .get();
    }

    if (query.docs.isEmpty) {
      throw S.phoneNotRegistered;
    }

    final doc = query.docs.first;
    final user = AppUser.fromDoc(doc);

    if (user.passwordCode != code) {
      throw S.wrongCode;
    }

    if (user.kickedOut) {
      throw S.accountKicked;
    }

    if (!user.isActive) {
      throw S.accountBlocked;
    }

    // Sign in anonymously so the member gets a Firebase Auth token.
    // This satisfies Firestore security rules (request.auth != null)
    // for writes like payment recording by Edir አመራር.
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
    } catch (_) {
      // Anonymous auth may be disabled in Firebase console.
      // Member can still view data; Firestore writes will be denied.
    }

    return user;
  }

  Stream<AppUser?> watchAppUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromDoc(doc);
    });
  }

  Future<AppUser?> getAppUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  // ── Global Member CRUD (used by devs/admins) ──

  Future<String?> createMemberAccount({
    required String displayName,
    String christianName = '',
    required String phone,
    String phone2 = '',
    required String passwordCode,
    required String areaId,
    UserRole role = UserRole.member,
    List<String> assignedTsiwaIds = const [],
    List<String> assignedEdirIds = const [],
    Map<String, String> tsiwaRoles = const {},
    bool isEdirAmerar = false,
  }) async {
    final existing = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return S.phoneAlreadyRegistered;
    }

    final user = AppUser(
      displayName: displayName,
      christianName: christianName,
      phone: phone,
      phone2: phone2,
      passwordCode: passwordCode,
      role: role,
      areaId: areaId,
      assignedTsiwaIds: assignedTsiwaIds,
      assignedEdirIds: assignedEdirIds,
      tsiwaRoles: tsiwaRoles,
      isEdirAmerar: isEdirAmerar,
    );

    await _firestore.collection('users').add(user.toCreateMap());
    return null;
  }

  Future<String?> updateMemberFull({
    required String uid,
    required AppUser updatedUser,
  }) async {
    // Check phone uniqueness (excluding self)
    final existing = await _firestore
        .collection('users')
        .where('phone', isEqualTo: updatedUser.phone)
        .limit(2)
        .get();

    for (final doc in existing.docs) {
      if (doc.id != uid) {
        return S.phoneAlreadyRegistered;
      }
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .update(updatedUser.toFullUpdateMap());
    return null;
  }

  Future<void> updateMemberCredentials({
    required String uid,
    String? phone,
    String? passwordCode,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (phone != null) updates['phone'] = phone;
    if (passwordCode != null) updates['passwordCode'] = passwordCode;
    await _firestore.collection('users').doc(uid).update(updates);
  }

  Future<void> updateMemberAssignments({
    required String uid,
    required List<String> assignedTsiwaIds,
    required List<String> assignedEdirIds,
    required Map<String, String> tsiwaRoles,
    required bool isEdirAmerar,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'assignedTsiwaIds': assignedTsiwaIds,
      'assignedEdirIds': assignedEdirIds,
      'tsiwaRoles': tsiwaRoles,
      'isEdirAmerar': isEdirAmerar,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> kickOutUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'kickedOut': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reinstateUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'kickedOut': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Profile / role management ──

  Future<void> updateProfile({
    required String uid,
    required String displayName,
    String christianName = '',
    required String phone,
    String phone2 = '',
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'displayName': displayName,
      'christianName': christianName,
      'phone': phone,
      'phone2': phone2,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserRole(String uid, UserRole role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserArea(String uid, String areaId) async {
    await _firestore.collection('users').doc(uid).update({
      'areaId': areaId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppUser>> watchAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList());
  }

  Stream<List<AppUser>> watchUsersByArea(String areaId) {
    return _firestore
        .collection('users')
        .where('areaId', isEqualTo: areaId)
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList());
  }

  Stream<List<AppUser>> watchMembersByTsiwa(String tsiwaId) {
    return _firestore
        .collection('users')
        .where('assignedTsiwaIds', arrayContains: tsiwaId)
        .snapshots()
        .map((snapshot) {
      final users =
          snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList();
      users.sort(
          (a, b) => a.displayName.compareTo(b.displayName));
      return users;
    });
  }

  Stream<List<AppUser>> watchMembersByEdir(String edirId) {
    return _firestore
        .collection('users')
        .where('assignedEdirIds', arrayContains: edirId)
        .snapshots()
        .map((snapshot) {
      final users =
          snapshot.docs.map((doc) => AppUser.fromDoc(doc)).toList();
      users.sort(
          (a, b) => a.displayName.compareTo(b.displayName));
      return users;
    });
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  /// Batch-add multiple users to a tsiwa by appending the tsiwaId
  /// to each user's assignedTsiwaIds and setting default tsiwaRole.
  Future<int> batchAddUsersToTsiwa({
    required List<String> userIds,
    required String tsiwaId,
  }) async {
    if (userIds.isEmpty) return 0;

    int added = 0;
    for (int i = 0; i < userIds.length; i += 500) {
      final chunk = userIds.sublist(
          i, i + 500 > userIds.length ? userIds.length : i + 500);
      final batch = _firestore.batch();
      for (final uid in chunk) {
        final ref = _firestore.collection('users').doc(uid);
        batch.update(ref, {
          'assignedTsiwaIds': FieldValue.arrayUnion([tsiwaId]),
          'tsiwaRoles.$tsiwaId': 'member',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      added += chunk.length;
    }
    return added;
  }

  /// Batch-create multiple member accounts from CSV import.
  /// Deduplicates by phone within the import list and against existing users.
  /// Respects the Firestore 500-operation batch limit by chunking.
  Future<int> batchCreateMembers(List<AppUser> members) async {
    if (members.isEmpty) return 0;

    // Deduplicate within the import list by phone
    final seen = <String>{};
    final unique = <AppUser>[];
    for (final m in members) {
      if (m.phone.isNotEmpty && seen.add(m.phone)) {
        unique.add(m);
      }
    }

    // Check existing phones in DB (query in batches of 10 — Firestore
    // whereIn limit)
    final existingPhones = <String>{};
    final phones = unique.map((m) => m.phone).toList();
    for (int i = 0; i < phones.length; i += 10) {
      final chunk = phones.sublist(
          i, i + 10 > phones.length ? phones.length : i + 10);
      final snap = await _firestore
          .collection('users')
          .where('phone', whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        final phone = doc.data()['phone'] as String?;
        if (phone != null) existingPhones.add(phone);
      }
    }

    // Filter out members whose phone already exists
    final toCreate =
        unique.where((m) => !existingPhones.contains(m.phone)).toList();

    if (toCreate.isEmpty) return 0;

    // Commit in chunks of 500 (Firestore batch limit)
    int created = 0;
    for (int i = 0; i < toCreate.length; i += 500) {
      final chunk = toCreate.sublist(
          i, i + 500 > toCreate.length ? toCreate.length : i + 500);
      final batch = _firestore.batch();
      for (final member in chunk) {
        final ref = _firestore.collection('users').doc();
        batch.set(ref, member.toCreateMap());
      }
      await batch.commit();
      created += chunk.length;
    }

    return created;
  }

  /// Ensure each edir in [edirIds] has an EdirMember doc for this user.
  /// Skips creation if a doc with matching phone already exists.
  Future<void> syncEdirMemberDocs({
    required String areaId,
    required List<String> edirIds,
    required String displayName,
    String christianName = '',
    required String phone,
  }) async {
    for (final edirId in edirIds) {
      final col = _firestore.collection(
        'areas/$areaId/edirs/$edirId/members',
      );
      // Check if a doc with this phone already exists
      final existing =
          await col.where('phone', isEqualTo: phone).limit(1).get();
      if (existing.docs.isNotEmpty) continue;

      await col.add({
        'fullName': displayName,
        'christianName': christianName,
        'phone': phone,
        'status': 'active',
        'totalPaid': 0,
        'balance': 0,
        'paidMonths': 0,
        'lastPaymentDate': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update member count
      try {
        final countSnap = await col.get();
        await _firestore.doc('areas/$areaId/edirs/$edirId').update({
          'memberCount': countSnap.docs.length,
        });
      } catch (_) {}
    }
  }

  // ── Firebase Auth (devs only) ──

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
