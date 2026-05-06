import 'package:cloud_firestore/cloud_firestore.dart';

class Edir {
  final String id;
  final String name;
  final String description;
  final double monthlyContribution;
  final double penaltyAmount;
  final double treasury;
  final int memberCount;
  final int paymentDay;
  final bool isActive;
  final bool isHidden;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Edir({
    this.id = '',
    this.name = '',
    this.description = '',
    this.monthlyContribution = 0,
    this.penaltyAmount = 0,
    this.treasury = 0,
    this.memberCount = 0,
    this.paymentDay = 1,
    this.isActive = true,
    this.isHidden = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Edir.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Edir(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      monthlyContribution:
          (data['monthlyContribution'] as num?)?.toDouble() ?? 0,
      penaltyAmount: (data['penaltyAmount'] as num?)?.toDouble() ?? 0,
      treasury: (data['treasury'] as num?)?.toDouble() ?? 0,
      memberCount: data['memberCount'] as int? ?? 0,
      paymentDay: data['paymentDay'] as int? ?? 1,
      isActive: data['isActive'] as bool? ?? true,
      isHidden: data['isHidden'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'description': description,
      'monthlyContribution': monthlyContribution,
      'penaltyAmount': penaltyAmount,
      'treasury': treasury,
      'memberCount': 0,
      'paymentDay': paymentDay,
      'isActive': isActive,
      'isHidden': isHidden,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'description': description,
      'monthlyContribution': monthlyContribution,
      'penaltyAmount': penaltyAmount,
      'treasury': treasury,
      'paymentDay': paymentDay,
      'isActive': isActive,
      'isHidden': isHidden,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Edir copyWith({
    String? id,
    String? name,
    String? description,
    double? monthlyContribution,
    double? penaltyAmount,
    double? treasury,
    int? memberCount,
    int? paymentDay,
    bool? isActive,
    bool? isHidden,
  }) {
    return Edir(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      monthlyContribution:
          monthlyContribution ?? this.monthlyContribution,
      penaltyAmount: penaltyAmount ?? this.penaltyAmount,
      treasury: treasury ?? this.treasury,
      memberCount: memberCount ?? this.memberCount,
      paymentDay: paymentDay ?? this.paymentDay,
      isActive: isActive ?? this.isActive,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
