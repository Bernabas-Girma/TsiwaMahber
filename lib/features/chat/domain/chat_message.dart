import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String text;
  final bool isEdited;

  /// If non-null, message is scheduled to appear at this time (dev only).
  final DateTime? scheduledAt;

  final DateTime? createdAt;

  const ChatMessage({
    this.id = '',
    this.roomId = '',
    this.senderId = '',
    this.senderName = '',
    this.text = '',
    this.isEdited = false,
    this.scheduledAt,
    this.createdAt,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatMessage(
      id: doc.id,
      roomId: data['roomId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      isEdited: data['isEdited'] as bool? ?? false,
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'isEdited': isEdited,
      if (scheduledAt != null)
        'scheduledAt': Timestamp.fromDate(scheduledAt!),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
