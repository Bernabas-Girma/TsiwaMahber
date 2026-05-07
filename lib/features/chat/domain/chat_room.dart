import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of chat rooms in the app.
enum ChatRoomType {
  /// Global chat for all members across the area.
  global,

  /// Per-tsiwa chat for members of a specific tsiwa.
  tsiwa,

  /// Amerars-only (admin/leader) chat.
  amerars;

  String get firestoreValue {
    switch (this) {
      case ChatRoomType.global:
        return 'global';
      case ChatRoomType.tsiwa:
        return 'tsiwa';
      case ChatRoomType.amerars:
        return 'amerars';
    }
  }

  static ChatRoomType fromString(String? value) {
    switch (value) {
      case 'global':
        return ChatRoomType.global;
      case 'tsiwa':
        return ChatRoomType.tsiwa;
      case 'amerars':
        return ChatRoomType.amerars;
      default:
        return ChatRoomType.global;
    }
  }
}

class ChatRoom {
  final String id;
  final String areaId;
  final String name;
  final ChatRoomType type;

  /// For tsiwa-specific rooms, the tsiwa ID this room belongs to.
  final String tsiwaId;

  final bool isEnabled;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  const ChatRoom({
    this.id = '',
    this.areaId = '',
    this.name = '',
    this.type = ChatRoomType.global,
    this.tsiwaId = '',
    this.isEnabled = true,
    this.lastMessage = '',
    this.lastMessageAt,
    this.createdAt,
  });

  factory ChatRoom.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatRoom(
      id: doc.id,
      areaId: data['areaId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: ChatRoomType.fromString(data['type'] as String?),
      tsiwaId: data['tsiwaId'] as String? ?? '',
      isEnabled: data['isEnabled'] as bool? ?? true,
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'areaId': areaId,
      'name': name,
      'type': type.firestoreValue,
      'tsiwaId': tsiwaId,
      'isEnabled': isEnabled,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null
          ? Timestamp.fromDate(lastMessageAt!)
          : null,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
