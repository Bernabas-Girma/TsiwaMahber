import 'package:cloud_firestore/cloud_firestore.dart';

class YearlyZikirEntry {
  final int month;
  final int day;
  final String note;

  const YearlyZikirEntry({
    required this.month,
    required this.day,
    this.note = '',
  });

  factory YearlyZikirEntry.fromMap(Map<String, dynamic> map) {
    return YearlyZikirEntry(
      month: map['month'] as int? ?? 1,
      day: map['day'] as int? ?? 1,
      note: map['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'month': month, 'day': day, 'note': note};
  }
}

class TsiwaMahber {
  final String id;
  final String areaId;

  final String name;
  final String churchName;
  final String saintName;
  final String location;
  final String description;

  final int monthlyTsiwaDay;
  final String monthlyTsiwaDayNote;

  final List<YearlyZikirEntry> yearlyZikir;

  final int currentRotationIndex;
  final int memberCount;
  final int museCount;

  final bool isActive;
  final bool isArchived;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TsiwaMahber({
    this.id = '',
    this.areaId = '',
    this.name = '',
    this.churchName = '',
    this.saintName = '',
    this.location = '',
    this.description = '',
    this.monthlyTsiwaDay = 1,
    this.monthlyTsiwaDayNote = '',
    this.yearlyZikir = const [],
    this.currentRotationIndex = 0,
    this.memberCount = 0,
    this.museCount = 0,
    this.isActive = true,
    this.isArchived = false,
    this.createdAt,
    this.updatedAt,
  });

  factory TsiwaMahber.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String areaId,
  ) {
    final data = doc.data()!;

    // Parse yearlyZikir list
    final yearlyZikirRaw = data['yearlyZikir'] as List<dynamic>?;
    final yearlyZikirList =
        yearlyZikirRaw
            ?.map(
              (e) =>
                  YearlyZikirEntry.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        [];

    // Migration: if old zikirMonth/zikirDay or feedingMonth/feedingDay exist,
    // include them in the yearlyZikir list for backward compatibility
    if (yearlyZikirRaw == null) {
      final zikirMonth = data['zikirMonth'] as int?;
      final zikirDay = data['zikirDay'] as int?;
      if (zikirMonth != null && zikirDay != null) {
        yearlyZikirList.add(
          YearlyZikirEntry(
            month: zikirMonth,
            day: zikirDay,
            note: data['zikirNote'] as String? ?? '',
          ),
        );
      }
      final feedingMonth = data['feedingMonth'] as int?;
      final feedingDay = data['feedingDay'] as int?;
      if (feedingMonth != null && feedingDay != null) {
        yearlyZikirList.add(
          YearlyZikirEntry(
            month: feedingMonth,
            day: feedingDay,
            note: data['feedingNote'] as String? ?? '',
          ),
        );
      }
    }

    return TsiwaMahber(
      id: doc.id,
      areaId: areaId,
      name: data['name'] as String? ?? '',
      churchName: data['churchName'] as String? ?? '',
      saintName: data['saintName'] as String? ?? '',
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      monthlyTsiwaDay: data['monthlyTsiwaDay'] as int? ?? 1,
      monthlyTsiwaDayNote: data['monthlyTsiwaDayNote'] as String? ?? '',
      yearlyZikir: yearlyZikirList,
      currentRotationIndex: data['currentRotationIndex'] as int? ?? 0,
      memberCount: data['memberCount'] as int? ?? 0,
      museCount: data['museCount'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      isArchived: data['isArchived'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'churchName': churchName,
      'saintName': saintName,
      'location': location,
      'description': description,
      'monthlyTsiwaDay': monthlyTsiwaDay,
      'monthlyTsiwaDayNote': monthlyTsiwaDayNote,
      'yearlyZikir': yearlyZikir.map((e) => e.toMap()).toList(),
      'currentRotationIndex': currentRotationIndex,
      'memberCount': memberCount,
      'museCount': museCount,
      'isActive': isActive,
      'isArchived': isArchived,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'churchName': churchName,
      'saintName': saintName,
      'location': location,
      'description': description,
      'monthlyTsiwaDay': monthlyTsiwaDay,
      'monthlyTsiwaDayNote': monthlyTsiwaDayNote,
      'yearlyZikir': yearlyZikir.map((e) => e.toMap()).toList(),
      'isActive': isActive,
      'isArchived': isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  TsiwaMahber copyWith({
    String? id,
    String? areaId,
    String? name,
    String? churchName,
    String? saintName,
    String? location,
    String? description,
    int? monthlyTsiwaDay,
    String? monthlyTsiwaDayNote,
    List<YearlyZikirEntry>? yearlyZikir,
    int? currentRotationIndex,
    int? memberCount,
    int? museCount,
    bool? isActive,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TsiwaMahber(
      id: id ?? this.id,
      areaId: areaId ?? this.areaId,
      name: name ?? this.name,
      churchName: churchName ?? this.churchName,
      saintName: saintName ?? this.saintName,
      location: location ?? this.location,
      description: description ?? this.description,
      monthlyTsiwaDay: monthlyTsiwaDay ?? this.monthlyTsiwaDay,
      monthlyTsiwaDayNote: monthlyTsiwaDayNote ?? this.monthlyTsiwaDayNote,
      yearlyZikir: yearlyZikir ?? this.yearlyZikir,
      currentRotationIndex: currentRotationIndex ?? this.currentRotationIndex,
      memberCount: memberCount ?? this.memberCount,
      museCount: museCount ?? this.museCount,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
