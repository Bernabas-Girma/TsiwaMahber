import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of chat rooms in the app.
enum ChatRoomType {
  /// Global chat for all members across the area.
  global,

  /// Per-tsiwa chat for members of a specific tsiwa.
  tsiwa,

  /// Amerars-only (admin/leader) chat.
  amerars,

  /// Custom group created by dev/admin.
  custom;

  String get firestoreValue {
    switch (this) {
      case ChatRoomType.global:
        return 'global';
      case ChatRoomType.tsiwa:
        return 'tsiwa';
      case ChatRoomType.amerars:
        return 'amerars';
      case ChatRoomType.custom:
        return 'custom';
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
      case 'custom':
        return ChatRoomType.custom;
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

  /// Member UIDs allowed in custom groups. Empty = open to all (for non-custom).
  final List<String> memberIds;

  /// UIDs restricted from sending messages in this room.
  final List<String> restrictedMemberIds;

  /// If non-null, all non-admin members are muted until this time.
  final DateTime? mutedUntil;

  /// Whether push notifications are enabled for this room.
  final bool notificationsEnabled;

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
    this.memberIds = const [],
    this.restrictedMemberIds = const [],
    this.mutedUntil,
    this.notificationsEnabled = true,
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
      memberIds:
          List<String>.from(data['memberIds'] as List<dynamic>? ?? []),
      restrictedMemberIds: List<String>.from(
          data['restrictedMemberIds'] as List<dynamic>? ?? []),
      mutedUntil: (data['mutedUntil'] as Timestamp?)?.toDate(),
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
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
      'memberIds': memberIds,
      'restrictedMemberIds': restrictedMemberIds,
      if (mutedUntil != null)
        'mutedUntil': Timestamp.fromDate(mutedUntil!),
      'notificationsEnabled': notificationsEnabled,
    };
  }

  bool get isMuted {
    if (mutedUntil == null) return false;
    return DateTime.now().isBefore(mutedUntil!);
  }
}
