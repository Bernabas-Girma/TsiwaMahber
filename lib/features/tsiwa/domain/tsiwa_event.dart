import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

enum TsiwaEventType {
  monthlyTsiwa,
  yearlyZikir,
  other;

  String get displayName {
    switch (this) {
      case TsiwaEventType.monthlyTsiwa:
        return S.monthlyTsiwa;
      case TsiwaEventType.yearlyZikir:
        return S.yearlyZikirTitle;
      case TsiwaEventType.other:
        return S.other;
    }
  }

  String get firestoreValue {
    switch (this) {
      case TsiwaEventType.monthlyTsiwa:
        return 'monthly_tsiwa';
      case TsiwaEventType.yearlyZikir:
        return 'yearly_zikir';
      case TsiwaEventType.other:
        return 'other';
    }
  }

  static TsiwaEventType fromString(String? value) {
    switch (value) {
      case 'monthly_tsiwa':
        return TsiwaEventType.monthlyTsiwa;
      case 'yearly_zikir':
      case 'zikir':
      case 'feeding_day':
        return TsiwaEventType.yearlyZikir;
      default:
        return TsiwaEventType.other;
    }
  }
}

enum TsiwaEventStatus {
  planned,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case TsiwaEventStatus.planned:
        return S.planned;
      case TsiwaEventStatus.completed:
        return S.eventCompleted;
      case TsiwaEventStatus.cancelled:
        return S.eventCancelled;
    }
  }

  String get firestoreValue {
    switch (this) {
      case TsiwaEventStatus.planned:
        return 'planned';
      case TsiwaEventStatus.completed:
        return 'completed';
      case TsiwaEventStatus.cancelled:
        return 'cancelled';
    }
  }

  static TsiwaEventStatus fromString(String? value) {
    switch (value) {
      case 'completed':
        return TsiwaEventStatus.completed;
      case 'cancelled':
        return TsiwaEventStatus.cancelled;
      default:
        return TsiwaEventStatus.planned;
    }
  }
}

class TsiwaEvent {
  final String id;
  final TsiwaEventType type;
  final int ethiopianYear;
  final int ethiopianMonth;
  final int ethiopianDay;
  final String responsibleMemberId;
  final String responsibleMemberNameSnapshot;
  final TsiwaEventStatus status;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TsiwaEvent({
    this.id = '',
    this.type = TsiwaEventType.monthlyTsiwa,
    this.ethiopianYear = 0,
    this.ethiopianMonth = 0,
    this.ethiopianDay = 0,
    this.responsibleMemberId = '',
    this.responsibleMemberNameSnapshot = '',
    this.status = TsiwaEventStatus.planned,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  factory TsiwaEvent.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TsiwaEvent(
      id: doc.id,
      type: TsiwaEventType.fromString(data['type'] as String?),
      ethiopianYear: data['ethiopianYear'] as int? ?? 0,
      ethiopianMonth: data['ethiopianMonth'] as int? ?? 0,
      ethiopianDay: data['ethiopianDay'] as int? ?? 0,
      responsibleMemberId: data['responsibleMemberId'] as String? ?? '',
      responsibleMemberNameSnapshot:
          data['responsibleMemberNameSnapshot'] as String? ?? '',
      status: TsiwaEventStatus.fromString(data['status'] as String?),
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'type': type.firestoreValue,
      'ethiopianYear': ethiopianYear,
      'ethiopianMonth': ethiopianMonth,
      'ethiopianDay': ethiopianDay,
      'responsibleMemberId': responsibleMemberId,
      'responsibleMemberNameSnapshot': responsibleMemberNameSnapshot,
      'status': status.firestoreValue,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'type': type.firestoreValue,
      'ethiopianYear': ethiopianYear,
      'ethiopianMonth': ethiopianMonth,
      'ethiopianDay': ethiopianDay,
      'responsibleMemberId': responsibleMemberId,
      'responsibleMemberNameSnapshot': responsibleMemberNameSnapshot,
      'status': status.firestoreValue,
      'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  TsiwaEvent copyWith({
    String? id,
    TsiwaEventType? type,
    int? ethiopianYear,
    int? ethiopianMonth,
    int? ethiopianDay,
    String? responsibleMemberId,
    String? responsibleMemberNameSnapshot,
    TsiwaEventStatus? status,
    String? notes,
  }) {
    return TsiwaEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      ethiopianYear: ethiopianYear ?? this.ethiopianYear,
      ethiopianMonth: ethiopianMonth ?? this.ethiopianMonth,
      ethiopianDay: ethiopianDay ?? this.ethiopianDay,
      responsibleMemberId: responsibleMemberId ?? this.responsibleMemberId,
      responsibleMemberNameSnapshot:
          responsibleMemberNameSnapshot ?? this.responsibleMemberNameSnapshot,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
