import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

enum AnnouncementPriority {
  normal,
  important,
  urgent;

  String get displayName {
    switch (this) {
      case AnnouncementPriority.normal:
        return S.levelNormal;
      case AnnouncementPriority.important:
        return S.levelImportant;
      case AnnouncementPriority.urgent:
        return S.levelUrgent;
    }
  }

  String get firestoreValue {
    switch (this) {
      case AnnouncementPriority.normal:
        return 'normal';
      case AnnouncementPriority.important:
        return 'important';
      case AnnouncementPriority.urgent:
        return 'urgent';
    }
  }

  static AnnouncementPriority fromString(String? value) {
    switch (value) {
      case 'important':
        return AnnouncementPriority.important;
      case 'urgent':
        return AnnouncementPriority.urgent;
      default:
        return AnnouncementPriority.normal;
    }
  }
}

enum AnnouncementTarget {
  all,
  tsiwa;

  String get firestoreValue => name;

  static AnnouncementTarget fromString(String? value) {
    if (value == 'tsiwa') return AnnouncementTarget.tsiwa;
    return AnnouncementTarget.all;
  }
}

class Announcement {
  final String id;
  final String title;
  final String body;
  final AnnouncementPriority priority;
  final String authorId;
  final String authorName;
  final AnnouncementTarget targetType;
  final String targetId;
  final String targetName;
  final int readCount;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Announcement({
    this.id = '',
    this.title = '',
    this.body = '',
    this.priority = AnnouncementPriority.normal,
    this.authorId = '',
    this.authorName = '',
    this.targetType = AnnouncementTarget.all,
    this.targetId = '',
    this.targetName = '',
    this.readCount = 0,
    this.isActive = true,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Announcement.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Announcement(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      priority: AnnouncementPriority.fromString(
          data['priority'] as String?),
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      targetType: AnnouncementTarget.fromString(
          data['targetType'] as String?),
      targetId: data['targetId'] as String? ?? '',
      targetName: data['targetName'] as String? ?? '',
      readCount: data['readCount'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'title': title,
      'body': body,
      'priority': priority.firestoreValue,
      'authorId': authorId,
      'authorName': authorName,
      'targetType': targetType.firestoreValue,
      if (targetId.isNotEmpty) 'targetId': targetId,
      if (targetName.isNotEmpty) 'targetName': targetName,
      'readCount': 0,
      'isActive': true,
      if (expiresAt != null)
        'expiresAt': Timestamp.fromDate(expiresAt!),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'body': body,
      'priority': priority.firestoreValue,
      'isActive': isActive,
      if (expiresAt != null)
        'expiresAt': Timestamp.fromDate(expiresAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? body,
    AnnouncementPriority? priority,
    String? authorId,
    String? authorName,
    AnnouncementTarget? targetType,
    String? targetId,
    String? targetName,
    int? readCount,
    bool? isActive,
    DateTime? expiresAt,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      priority: priority ?? this.priority,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      readCount: readCount ?? this.readCount,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
