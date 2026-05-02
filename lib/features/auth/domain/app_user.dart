import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

enum UserRole {
  developer,
  admin,
  leader,
  member,
  viewer;

  String get displayName {
    switch (this) {
      case UserRole.developer:
        return S.roleDeveloper;
      case UserRole.admin:
        return S.roleAdmin;
      case UserRole.leader:
        return S.roleLeader;
      case UserRole.member:
        return S.roleMember;
      case UserRole.viewer:
        return S.roleViewer;
    }
  }

  String get firestoreValue {
    switch (this) {
      case UserRole.developer:
        return 'developer';
      case UserRole.admin:
        return 'admin';
      case UserRole.leader:
        return 'leader';
      case UserRole.member:
        return 'member';
      case UserRole.viewer:
        return 'viewer';
    }
  }

  static UserRole fromString(String? value) {
    switch (value) {
      case 'developer':
        return UserRole.developer;
      case 'admin':
        return UserRole.admin;
      case 'leader':
        return UserRole.leader;
      case 'member':
        return UserRole.member;
      default:
        return UserRole.viewer;
    }
  }

  bool get isDeveloper => this == UserRole.developer;

  bool get isAdminOrAbove =>
      this == UserRole.developer || this == UserRole.admin;

  bool get canEdit =>
      this == UserRole.developer ||
      this == UserRole.admin ||
      this == UserRole.leader;

  bool get canDelete =>
      this == UserRole.developer || this == UserRole.admin;

  bool get canManageUsers =>
      this == UserRole.developer || this == UserRole.admin;

  bool get canCreateArea => this == UserRole.developer;

  bool get canManageDevelopers => this == UserRole.developer;

  bool get canAnnounce =>
      this == UserRole.developer ||
      this == UserRole.admin ||
      this == UserRole.leader;

  bool get isViewOnly =>
      this == UserRole.member || this == UserRole.viewer;
}

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String christianName;
  final String phone;
  final String phone2;
  final String passwordCode;
  final UserRole role;
  final String areaId;
  final bool isActive;
  final bool kickedOut;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Tsiwa IDs this member is assigned to (can be multiple).
  final List<String> assignedTsiwaIds;

  /// Edir IDs this member is assigned to (can be multiple).
  final List<String> assignedEdirIds;

  /// Maps tsiwaId → role name (e.g. 'muse', 'assistant_muse', 'member').
  final Map<String, String> tsiwaRoles;

  /// Whether this user is an Edir አመራር (can manage payments).
  final bool isEdirAmerar;

  const AppUser({
    this.uid = '',
    this.email = '',
    this.displayName = '',
    this.christianName = '',
    this.phone = '',
    this.phone2 = '',
    this.passwordCode = '',
    this.role = UserRole.viewer,
    this.areaId = '',
    this.isActive = true,
    this.kickedOut = false,
    this.createdAt,
    this.updatedAt,
    this.assignedTsiwaIds = const [],
    this.assignedEdirIds = const [],
    this.tsiwaRoles = const {},
    this.isEdirAmerar = false,
  });

  bool get hasTsiwaAssignment => assignedTsiwaIds.isNotEmpty;
  bool get hasEdirAssignment => assignedEdirIds.isNotEmpty;

  String tsiwaRoleFor(String tsiwaId) =>
      tsiwaRoles[tsiwaId] ?? 'member';

  bool isMuse(String tsiwaId) =>
      tsiwaRoles[tsiwaId] == 'muse';

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      christianName: data['christianName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      phone2: data['phone2'] as String? ?? '',
      passwordCode: data['passwordCode'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String?),
      areaId: data['areaId'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      kickedOut: data['kickedOut'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      assignedTsiwaIds: List<String>.from(
          data['assignedTsiwaIds'] as List<dynamic>? ?? []),
      assignedEdirIds: List<String>.from(
          data['assignedEdirIds'] as List<dynamic>? ?? []),
      tsiwaRoles: Map<String, String>.from(
          data['tsiwaRoles'] as Map<dynamic, dynamic>? ?? {}),
      isEdirAmerar: data['isEdirAmerar'] as bool? ?? false,
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> data, String docId) {
    return AppUser(
      uid: docId,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      christianName: data['christianName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      phone2: data['phone2'] as String? ?? '',
      passwordCode: data['passwordCode'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String?),
      areaId: data['areaId'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      kickedOut: data['kickedOut'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      assignedTsiwaIds: List<String>.from(
          data['assignedTsiwaIds'] as List<dynamic>? ?? []),
      assignedEdirIds: List<String>.from(
          data['assignedEdirIds'] as List<dynamic>? ?? []),
      tsiwaRoles: Map<String, String>.from(
          data['tsiwaRoles'] as Map<dynamic, dynamic>? ?? {}),
      isEdirAmerar: data['isEdirAmerar'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'email': email,
      'displayName': displayName,
      'christianName': christianName,
      'phone': phone,
      'phone2': phone2,
      'passwordCode': passwordCode,
      'role': role.firestoreValue,
      'areaId': areaId,
      'isActive': true,
      'kickedOut': false,
      'assignedTsiwaIds': assignedTsiwaIds,
      'assignedEdirIds': assignedEdirIds,
      'tsiwaRoles': tsiwaRoles,
      'isEdirAmerar': isEdirAmerar,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'displayName': displayName,
      'christianName': christianName,
      'phone': phone,
      'phone2': phone2,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toFullUpdateMap() {
    return {
      'displayName': displayName,
      'christianName': christianName,
      'phone': phone,
      'phone2': phone2,
      'passwordCode': passwordCode,
      'role': role.firestoreValue,
      'areaId': areaId,
      'assignedTsiwaIds': assignedTsiwaIds,
      'assignedEdirIds': assignedEdirIds,
      'tsiwaRoles': tsiwaRoles,
      'isEdirAmerar': isEdirAmerar,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? christianName,
    String? phone,
    String? phone2,
    String? passwordCode,
    UserRole? role,
    String? areaId,
    bool? isActive,
    bool? kickedOut,
    List<String>? assignedTsiwaIds,
    List<String>? assignedEdirIds,
    Map<String, String>? tsiwaRoles,
    bool? isEdirAmerar,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      christianName: christianName ?? this.christianName,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      passwordCode: passwordCode ?? this.passwordCode,
      role: role ?? this.role,
      areaId: areaId ?? this.areaId,
      isActive: isActive ?? this.isActive,
      kickedOut: kickedOut ?? this.kickedOut,
      assignedTsiwaIds: assignedTsiwaIds ?? this.assignedTsiwaIds,
      assignedEdirIds: assignedEdirIds ?? this.assignedEdirIds,
      tsiwaRoles: tsiwaRoles ?? this.tsiwaRoles,
      isEdirAmerar: isEdirAmerar ?? this.isEdirAmerar,
    );
  }
}
