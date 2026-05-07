import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsiwa_mahber/core/services/local_notification_service.dart';

/// Listens to Firestore changes and shows local notifications
/// for new announcements, chat messages, and ring-bell alerts.
class NotificationListenerService {
  static final NotificationListenerService _instance =
      NotificationListenerService._();
  factory NotificationListenerService() => _instance;
  NotificationListenerService._();

  final _firestore = FirebaseFirestore.instance;
  final _notifService = LocalNotificationService();

  final List<StreamSubscription<dynamic>> _subs = [];
  String? _currentUserId;
  String? _areaId;
  bool _started = false;

  Future<void> start({
    required String userId,
    required String areaId,
  }) async {
    if (_started && _currentUserId == userId) return;
    stop();

    _currentUserId = userId;
    _areaId = areaId;
    _started = true;

    await _notifService.init();

    _watchAnnouncements();
    _watchChatMessages();
    _watchRingBell();
  }

  void stop() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    _watchedRooms.clear();
    _started = false;
  }

  // ── Announcements ──

  void _watchAnnouncements() {
    final sub = _firestore
        .collection('areas/$_areaId/announcements')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) return;
      final doc = snapshot.docs.first;
      final data = doc.data();
      final key = 'notif_ann_${doc.id}';

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(key) == true) return;
      await prefs.setBool(key, true);

      final title = data['title'] as String? ?? '';
      final body = data['body'] as String? ?? '';
      final priority = data['priority'] as String? ?? 'normal';

      await _notifService.showAnnouncementNotification(
        title: title,
        body: body.length > 100 ? '${body.substring(0, 100)}...' : body,
        announcementId: doc.id,
        areaId: _areaId!,
        urgent: priority == 'urgent',
      );
    });
    _subs.add(sub);
  }

  // ── Chat messages ──

  void _watchChatMessages() {
    final roomsSub = _firestore
        .collection('areas/$_areaId/chatRooms')
        .where('isEnabled', isEqualTo: true)
        .snapshots()
        .listen((roomSnapshot) {
      for (final roomDoc in roomSnapshot.docs) {
        final roomData = roomDoc.data();
        // Check if chat notifications are enabled for this room
        final notificationsEnabled =
            roomData['notificationsEnabled'] as bool? ?? true;
        if (notificationsEnabled) {
          _watchRoomMessages(roomDoc.id, roomData);
        }
      }
    });
    _subs.add(roomsSub);
  }

  final Set<String> _watchedRooms = {};

  void _watchRoomMessages(String roomId, Map<String, dynamic> roomData) {
    if (_watchedRooms.contains(roomId)) return;
    _watchedRooms.add(roomId);

    final sub = _firestore
        .collection('areas/$_areaId/chatRooms/$roomId/messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) return;
      final doc = snapshot.docs.first;
      final data = doc.data();

      final senderId = data['senderId'] as String? ?? '';
      if (senderId == _currentUserId) return;
      if (data['scheduledAt'] != null) return;

      final key = 'notif_chat_${doc.id}';
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(key) == true) return;
      await prefs.setBool(key, true);

      final senderName = data['senderName'] as String? ?? '';
      final text = data['text'] as String? ?? '';
      final roomName = roomData['name'] as String? ?? 'Chat';

      await _notifService.showChatNotification(
        roomName: roomName,
        senderName: senderName,
        message: text.length > 80 ? '${text.substring(0, 80)}...' : text,
        roomId: roomId,
        areaId: _areaId!,
      );
    });
    _subs.add(sub);
  }

  // ── Ring bell (dev re-notify) ──

  void _watchRingBell() {
    final sub = _firestore
        .collection('areas/$_areaId/ringBell')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) return;
      final doc = snapshot.docs.first;
      final data = doc.data();
      final key = 'notif_ring_${doc.id}';

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(key) == true) return;
      await prefs.setBool(key, true);

      final title = data['title'] as String? ?? '';
      final body = data['body'] as String? ?? '';
      final announcementId = data['announcementId'] as String?;

      await _notifService.showRingBellNotification(
        title: title,
        body: body,
        announcementId: announcementId,
        areaId: _areaId,
      );
    });
    _subs.add(sub);
  }
}
