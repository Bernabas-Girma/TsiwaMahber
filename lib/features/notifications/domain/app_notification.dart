import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

enum NotificationType {
  announcement,
  event,
  payment,
  turnReminder,
  turnAlert,
  system;

  String get displayName {
    switch (this) {
      case NotificationType.announcement:
        return S.notifAnnouncement;
      case NotificationType.event:
        return S.notifEvent;
      case NotificationType.payment:
        return S.notifPayment;
      case NotificationType.turnReminder:
        return S.notifTurnReminder;
      case NotificationType.turnAlert:
        return S.notifTurnAlert;
      case NotificationType.system:
        return S.notifSystem;
    }
  }

  String get firestoreValue {
    switch (this) {
      case NotificationType.announcement:
        return 'announcement';
      case NotificationType.event:
        return 'event';
      case NotificationType.payment:
        return 'payment';
      case NotificationType.turnReminder:
        return 'turnReminder';
      case NotificationType.turnAlert:
        return 'turnAlert';
      case NotificationType.system:
        return 'system';
    }
  }

  static NotificationType fromString(String? value) {
    switch (value) {
      case 'announcement':
        return NotificationType.announcement;
      case 'event':
        return NotificationType.event;
      case 'payment':
        return NotificationType.payment;
      case 'turnReminder':
        return NotificationType.turnReminder;
      case 'turnAlert':
        return NotificationType.turnAlert;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? referenceId;
  final String? senderId;
  final String? senderName;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    this.id = '',
    this.title = '',
    this.body = '',
    this.type = NotificationType.system,
    this.referenceId,
    this.senderId,
    this.senderName,
    this.isRead = false,
    this.createdAt,
  });

  factory AppNotification.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppNotification(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: NotificationType.fromString(data['type'] as String?),
      referenceId: data['referenceId'] as String?,
      senderId: data['senderId'] as String?,
      senderName: data['senderName'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'title': title,
      'body': body,
      'type': type.firestoreValue,
      if (referenceId != null) 'referenceId': referenceId,
      if (senderId != null) 'senderId': senderId,
      if (senderName != null) 'senderName': senderName,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? referenceId,
    String? senderId,
    String? senderName,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      isRead: isRead ?? this.isRead,
    );
  }
}
