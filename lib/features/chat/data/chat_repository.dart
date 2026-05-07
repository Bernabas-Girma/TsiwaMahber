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
    await _roomsRef(areaId).doc(roomId).update({
      'lastMessage': message.text.length > 60
          ? '${message.text.substring(0, 60)}...'
          : message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
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
