import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/features/notifications/domain/app_notification.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String _userNotificationsPath(String userId) =>
      'users/$userId/notifications';

  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _firestore
        .collection(_userNotificationsPath(userId))
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromDoc(doc))
            .toList());
  }

  Stream<int> watchUnreadCount(String userId) {
    return _firestore
        .collection(_userNotificationsPath(userId))
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> sendNotification({
    required String userId,
    required AppNotification notification,
  }) async {
    await _firestore
        .collection(_userNotificationsPath(userId))
        .add(notification.toCreateMap());
  }

  Future<void> sendNotificationToAll({
    required String areaId,
    required AppNotification notification,
  }) async {
    final usersSnapshot = await _firestore
        .collection('users')
        .where('areaId', isEqualTo: areaId)
        .where('isActive', isEqualTo: true)
        .get();

    final batch = _firestore.batch();

    for (final userDoc in usersSnapshot.docs) {
      final ref = _firestore
          .collection(_userNotificationsPath(userDoc.id))
          .doc();
      batch.set(ref, notification.toCreateMap());
    }

    await batch.commit();
  }

  Future<void> sendNotificationToTsiwaMembers({
    required String tsiwaId,
    required AppNotification notification,
  }) async {
    final usersSnapshot = await _firestore
        .collection('users')
        .where('assignedTsiwaIds', arrayContains: tsiwaId)
        .where('isActive', isEqualTo: true)
        .get();

    for (int i = 0; i < usersSnapshot.docs.length; i += 500) {
      final chunk = usersSnapshot.docs.sublist(
        i,
        i + 500 > usersSnapshot.docs.length
            ? usersSnapshot.docs.length
            : i + 500,
      );
      final batch = _firestore.batch();
      for (final userDoc in chunk) {
        final ref = _firestore
            .collection(_userNotificationsPath(userDoc.id))
            .doc();
        batch.set(ref, notification.toCreateMap());
      }
      await batch.commit();
    }
  }

  Future<void> sendNotificationToUser({
    required String userId,
    required AppNotification notification,
  }) async {
    await _firestore
        .collection(_userNotificationsPath(userId))
        .add(notification.toCreateMap());
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .doc('${_userNotificationsPath(userId)}/$notificationId')
        .update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection(_userNotificationsPath(userId))
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(
      String userId, String notificationId) async {
    await _firestore
        .doc('${_userNotificationsPath(userId)}/$notificationId')
        .delete();
  }

  Future<void> clearAll(String userId) async {
    final snapshot = await _firestore
        .collection(_userNotificationsPath(userId))
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
