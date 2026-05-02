import 'package:cloud_firestore/cloud_firestore.dart';

enum MemberRole {
  muse,
  assistantMuse,
  member,
  observer;

  String get displayName {
    switch (this) {
      case MemberRole.muse:
        return 'ሙሴ';
      case MemberRole.assistantMuse:
        return 'ረዳት ሙሴ';
      case MemberRole.member:
        return 'ማህበርተኛ';
      case MemberRole.observer:
        return 'ታዛቢ';
    }
  }

  String get firestoreValue {
    switch (this) {
      case MemberRole.muse:
        return 'muse';
      case MemberRole.assistantMuse:
        return 'assistant_muse';
      case MemberRole.member:
        return 'member';
      case MemberRole.observer:
        return 'observer';
    }
  }

  static MemberRole fromString(String? value) {
    switch (value) {
      case 'muse':
        return MemberRole.muse;
      case 'assistant_muse':
        return MemberRole.assistantMuse;
      case 'observer':
        return MemberRole.observer;
      default:
        return MemberRole.member;
    }
  }
}

class Member {
  final String id;
  final String fullName;
  final String christianName;
  final String phone;
  final String phone2;
  final String idNumber;
  final String address;

  final MemberRole role;
  final int orderIndex;
  final bool isInRotation;
  final bool isHiddenPhone;
  final bool isHiddenName;
  final bool isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Member({
    this.id = '',
    this.fullName = '',
    this.christianName = '',
    this.phone = '',
    this.phone2 = '',
    this.idNumber = '',
    this.address = '',
    this.role = MemberRole.member,
    this.orderIndex = 0,
    this.isInRotation = true,
    this.isHiddenPhone = false,
    this.isHiddenName = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Member.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Member(
      id: doc.id,
      fullName: data['fullName'] as String? ?? '',
      christianName: data['christianName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      phone2: data['phone2'] as String? ?? '',
      idNumber: data['idNumber'] as String? ?? '',
      address: data['address'] as String? ?? '',
      role: MemberRole.fromString(data['role'] as String?),
      orderIndex: data['orderIndex'] as int? ?? 0,
      isInRotation: data['isInRotation'] as bool? ?? true,
      isHiddenPhone: data['isHiddenPhone'] as bool? ?? false,
      isHiddenName: data['isHiddenName'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'fullName': fullName,
      'christianName': christianName,
      'phone': phone,
      'phone2': phone2,
      'idNumber': idNumber,
      'address': address,
      'role': role.firestoreValue,
      'orderIndex': orderIndex,
      'isInRotation': isInRotation,
      'isHiddenPhone': isHiddenPhone,
      'isHiddenName': isHiddenName,
      'isActive': isActive,
      'deletedAt': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'fullName': fullName,
      'christianName': christianName,
      'phone': phone,
      'phone2': phone2,
      'idNumber': idNumber,
      'address': address,
      'role': role.firestoreValue,
      'orderIndex': orderIndex,
      'isInRotation': isInRotation,
      'isHiddenPhone': isHiddenPhone,
      'isHiddenName': isHiddenName,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Member copyWith({
    String? id,
    String? fullName,
    String? christianName,
    String? phone,
    String? phone2,
    String? idNumber,
    String? address,
    MemberRole? role,
    int? orderIndex,
    bool? isInRotation,
    bool? isHiddenPhone,
    bool? isHiddenName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Member(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      christianName: christianName ?? this.christianName,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      idNumber: idNumber ?? this.idNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      orderIndex: orderIndex ?? this.orderIndex,
      isInRotation: isInRotation ?? this.isInRotation,
      isHiddenPhone: isHiddenPhone ?? this.isHiddenPhone,
      isHiddenName: isHiddenName ?? this.isHiddenName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  String get normalizedPhone {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 9) {
      return digits.substring(digits.length - 9);
    }
    return digits;
  }

  String get normalizedFullName => fullName.trim().toLowerCase();

  String get normalizedChristianName => christianName.trim().toLowerCase();
}
