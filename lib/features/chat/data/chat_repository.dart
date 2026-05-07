import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/features/chat/domain/chat_message.dart';
import 'package:tsiwa_mahber/features/chat/domain/chat_room.dart';

class ChatRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _roomsRef(String areaId) =>
      _firestore
          .collection('areas')
          .doc(areaId)
          .collection('chatRooms');

  CollectionReference<Map<String, dynamic>> _messagesRef(
          String areaId, String roomId) =>
      _roomsRef(areaId).doc(roomId).collection('messages');

  // ── Room operations ──

  Stream<List<ChatRoom>> watchRooms(String areaId) {
    return _roomsRef(areaId)
        .orderBy('type')
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatRoom.fromDoc(d)).toList());
  }

  Stream<ChatRoom?> watchRoom(String areaId, String roomId) {
    return _roomsRef(areaId)
        .doc(roomId)
        .snapshots()
        .map((doc) => doc.exists ? ChatRoom.fromDoc(doc) : null);
  }

  Future<ChatRoom?> getRoom(String areaId, String roomId) async {
    final doc = await _roomsRef(areaId).doc(roomId).get();
    if (!doc.exists) return null;
    return ChatRoom.fromDoc(doc);
  }

  Future<String> ensureRoom(String areaId, ChatRoom room) async {
    final query = _roomsRef(areaId).where('type',
        isEqualTo: room.type.firestoreValue);
    QuerySnapshot<Map<String, dynamic>> snap;

    if (room.type == ChatRoomType.tsiwa) {
      snap = await query
          .where('tsiwaId', isEqualTo: room.tsiwaId)
          .limit(1)
          .get();
    } else if (room.type == ChatRoomType.custom) {
      final docRef = await _roomsRef(areaId).add(room.toMap());
      return docRef.id;
    } else {
      snap = await query.limit(1).get();
    }

    if (snap.docs.isNotEmpty) {
      return snap.docs.first.id;
    }

    final docRef = await _roomsRef(areaId).add(room.toMap());
    return docRef.id;
  }

  Future<void> toggleRoom(String areaId, String roomId, bool enabled) {
    return _roomsRef(areaId).doc(roomId).update({'isEnabled': enabled});
  }

  Future<void> renameRoom(String areaId, String roomId, String name) {
    return _roomsRef(areaId).doc(roomId).update({'name': name});
  }

  Future<void> deleteRoom(String areaId, String roomId) {
    return _roomsRef(areaId).doc(roomId).delete();
  }

  // ── Member management ──

  Future<void> addMembers(
      String areaId, String roomId, List<String> uids) {
    return _roomsRef(areaId).doc(roomId).update({
      'memberIds': FieldValue.arrayUnion(uids),
    });
  }

  Future<void> removeMembers(
      String areaId, String roomId, List<String> uids) {
    return _roomsRef(areaId).doc(roomId).update({
      'memberIds': FieldValue.arrayRemove(uids),
    });
  }

  Future<void> restrictMember(
      String areaId, String roomId, String uid) {
    return _roomsRef(areaId).doc(roomId).update({
      'restrictedMemberIds': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> unrestrictMember(
      String areaId, String roomId, String uid) {
    return _roomsRef(areaId).doc(roomId).update({
      'restrictedMemberIds': FieldValue.arrayRemove([uid]),
    });
  }

  // ── Mute all members ──

  Future<void> muteRoom(
      String areaId, String roomId, DateTime until) {
    return _roomsRef(areaId).doc(roomId).update({
      'mutedUntil': Timestamp.fromDate(until),
    });
  }

  Future<void> unmuteRoom(String areaId, String roomId) {
    return _roomsRef(areaId).doc(roomId).update({
      'mutedUntil': FieldValue.delete(),
    });
  }

  // ── Message operations ──

  Stream<List<ChatMessage>> watchMessages(
      String areaId, String roomId, {int limit = 100}) {
    return _messagesRef(areaId, roomId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromDoc(d)).toList());
  }

  Future<void> sendMessage(
      String areaId, String roomId, ChatMessage message) async {
    await _messagesRef(areaId, roomId).add(message.toMap());
    if (message.scheduledAt == null) {
      await _roomsRef(areaId).doc(roomId).update({
        'lastMessage': message.text.length > 60
            ? '${message.text.substring(0, 60)}...'
            : message.text,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> editMessage(
      String areaId, String roomId, String messageId, String newText) {
    return _messagesRef(areaId, roomId).doc(messageId).update({
      'text': newText,
      'isEdited': true,
    });
  }

  Future<void> deleteMessage(
      String areaId, String roomId, String messageId) {
    return _messagesRef(areaId, roomId).doc(messageId).delete();
  }

  // ── Initialize default rooms for an area ──

  Future<void> initDefaultRooms(
      String areaId, List<({String tsiwaId, String tsiwaName})> tsiwas) async {
    await ensureRoom(
      areaId,
      ChatRoom(
        areaId: areaId,
        name: 'ዓለም አቀፍ ቡድን',
        type: ChatRoomType.global,
      ),
    );

    await ensureRoom(
      areaId,
      ChatRoom(
        areaId: areaId,
        name: 'የአመራሮች ቡድን',
        type: ChatRoomType.amerars,
      ),
    );

    for (final t in tsiwas) {
      await ensureRoom(
        areaId,
        ChatRoom(
          areaId: areaId,
          name: t.tsiwaName,
          type: ChatRoomType.tsiwa,
          tsiwaId: t.tsiwaId,
        ),
      );
    }
  }
}
