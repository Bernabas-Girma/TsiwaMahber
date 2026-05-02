import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir_member.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';
import 'package:tsiwa_mahber/features/members/domain/member.dart';

enum CsvEntityType {
  tsiwaMembers,
  leaders,
  edirMembers;

  String get displayName {
    switch (this) {
      case CsvEntityType.tsiwaMembers:
        return 'የፅዋ አባላት';
      case CsvEntityType.leaders:
        return 'አመራሮች';
      case CsvEntityType.edirMembers:
        return 'የእድር አባላት';
    }
  }

  String get fileName {
    switch (this) {
      case CsvEntityType.tsiwaMembers:
        return 'tsiwa_members';
      case CsvEntityType.leaders:
        return 'leaders';
      case CsvEntityType.edirMembers:
        return 'edir_members';
    }
  }
}

class CsvService {
  final FirebaseFirestore _firestore;

  CsvService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Headers ──

  static const List<String> memberHeaders = [
    'ሙሉ ስም',
    'የክርስትና ስም',
    'ስልክ',
    'ስልክ 2',
    'መለያ ቁጥር',
    'አድራሻ',
    'ሚና',
    'ተራ ቁጥር',
  ];

  static const List<String> leaderHeaders = [
    'ሙሉ ስም',
    'የክርስትና ስም',
    'ስልክ',
    'ስልክ 2',
    'ሚና',
    'የእድር ሚና',
  ];

  static const List<String> edirMemberHeaders = [
    'ሙሉ ስም',
    'የክርስትና ስም',
    'ስልክ',
    'ሁኔታ',
  ];

  // ── Export ──

  Future<String> exportMembers(String areaId, String tsiwaId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.members(areaId, tsiwaId))
        .where('deletedAt', isNull: true)
        .orderBy('orderIndex')
        .get();

    final rows = <List<String>>[memberHeaders];
    for (final doc in snapshot.docs) {
      final m = Member.fromDoc(doc);
      rows.add([
        m.fullName,
        m.christianName,
        m.phone,
        m.phone2,
        m.idNumber,
        m.address,
        m.role.displayName,
        m.orderIndex.toString(),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  Future<String> exportLeaders(String areaId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.leaders(areaId))
        .orderBy('role')
        .get();

    final rows = <List<String>>[leaderHeaders];
    for (final doc in snapshot.docs) {
      final l = Leader.fromDoc(doc);
      rows.add([
        l.fullName,
        l.christianName,
        l.phone,
        l.phone2,
        l.role.displayName,
        l.edirRole?.displayName ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  Future<String> exportEdirMembers(String areaId, String edirId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.edirMembers(areaId, edirId))
        .orderBy('fullName')
        .get();

    final rows = <List<String>>[edirMemberHeaders];
    for (final doc in snapshot.docs) {
      final m = EdirMember.fromDoc(doc);
      rows.add([
        m.fullName,
        m.christianName,
        m.phone,
        m.status.displayName,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  // ── Import ──

  List<Member> parseMembersFromRows(List<List<dynamic>> rows) {
    if (rows.length < 2) return [];

    final members = <Member>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 3) continue;

      final roleName = row.length > 6 ? row[6].toString().trim() : '';
      final orderStr = row.length > 7 ? row[7].toString().trim() : '0';

      members.add(Member(
        fullName: row[0].toString().trim(),
        christianName: row[1].toString().trim(),
        phone: _normalizePhone(row[2].toString().trim()),
        phone2: row.length > 3 ? _normalizePhone(row[3].toString().trim()) : '',
        idNumber: row.length > 4 ? row[4].toString().trim() : '',
        address: row.length > 5 ? row[5].toString().trim() : '',
        role: _parseMemberRole(roleName),
        orderIndex: int.tryParse(orderStr) ?? 0,
      ));
    }

    return members;
  }

  Future<List<Member>> parseMembersCsv(String csvContent) async {
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(_sanitizeCsv(csvContent));
    return parseMembersFromRows(rows);
  }

  List<Leader> parseLeadersFromRows(List<List<dynamic>> rows) {
    if (rows.length < 2) return [];

    final leaders = <Leader>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 3) continue;

      final roleName = row.length > 4 ? row[4].toString().trim() : '';
      final edirRoleName = row.length > 5 ? row[5].toString().trim() : '';

      leaders.add(Leader(
        fullName: row[0].toString().trim(),
        christianName: row[1].toString().trim(),
        phone: _normalizePhone(row[2].toString().trim()),
        phone2: row.length > 3 ? _normalizePhone(row[3].toString().trim()) : '',
        role: _parseLeaderRole(roleName),
        edirRole: _parseEdirLeaderRole(edirRoleName),
      ));
    }

    return leaders;
  }

  Future<List<Leader>> parseLeadersCsv(String csvContent) async {
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(_sanitizeCsv(csvContent));
    return parseLeadersFromRows(rows);
  }

  List<EdirMember> parseEdirMembersFromRows(List<List<dynamic>> rows) {
    if (rows.length < 2) return [];

    final members = <EdirMember>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 3) continue;

      final statusName = row.length > 3 ? row[3].toString().trim() : '';

      members.add(EdirMember(
        fullName: row[0].toString().trim(),
        christianName: row[1].toString().trim(),
        phone: _normalizePhone(row[2].toString().trim()),
        status: _parseEdirMemberStatus(statusName),
      ));
    }

    return members;
  }

  Future<List<EdirMember>> parseEdirMembersCsv(String csvContent) async {
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(_sanitizeCsv(csvContent));
    return parseEdirMembersFromRows(rows);
  }

  // ── Batch write ──

  Future<int> importMembers(
    String areaId,
    String tsiwaId,
    List<Member> members,
  ) async {
    int imported = 0;
    final collection =
        _firestore.collection(FirestorePaths.members(areaId, tsiwaId));

    final existingSnapshot =
        await collection.where('deletedAt', isNull: true).get();
    int nextOrder = 1;
    final existingPhones = <String>{};
    for (final doc in existingSnapshot.docs) {
      final idx = doc.data()['orderIndex'] as int? ?? 0;
      if (idx >= nextOrder) nextOrder = idx + 1;
      final phone = doc.data()['phone'] as String? ?? '';
      if (phone.isNotEmpty) existingPhones.add(phone);
    }

    final batch = _firestore.batch();
    final importedMembers = <Member>[];
    for (final member in members) {
      if (member.fullName.isEmpty) continue;
      if (member.phone.isNotEmpty && existingPhones.contains(member.phone)) {
        continue;
      }
      if (member.phone.isNotEmpty) existingPhones.add(member.phone);
      final m = member.copyWith(orderIndex: nextOrder++);
      batch.set(collection.doc(), m.toCreateMap());
      importedMembers.add(member);
      imported++;
    }
    await batch.commit();

    // Auto-create login accounts
    await _createUserAccounts(importedMembers, areaId);

    await _updateTswaCounts(areaId, tsiwaId);
    return imported;
  }

  Future<int> importLeaders(String areaId, List<Leader> leaders) async {
    int imported = 0;
    final collection =
        _firestore.collection(FirestorePaths.leaders(areaId));

    final existingSnapshot = await collection.get();
    final existingPhones = <String>{};
    for (final doc in existingSnapshot.docs) {
      final phone = doc.data()['phone'] as String? ?? '';
      if (phone.isNotEmpty) existingPhones.add(phone);
    }

    final batch = _firestore.batch();
    final importedLeaders = <_LeaderAsImport>[];
    for (final leader in leaders) {
      if (leader.fullName.isEmpty) continue;
      if (leader.phone.isNotEmpty && existingPhones.contains(leader.phone)) {
        continue;
      }
      if (leader.phone.isNotEmpty) existingPhones.add(leader.phone);
      batch.set(collection.doc(), leader.toCreateMap());
      importedLeaders.add(_LeaderAsImport(leader.fullName, leader.phone));
      imported++;
    }
    await batch.commit();

    // Auto-create login accounts
    await _createUserAccounts(importedLeaders, areaId);

    return imported;
  }

  Future<int> importEdirMembers(
    String areaId,
    String edirId,
    List<EdirMember> members,
  ) async {
    int imported = 0;
    final collection =
        _firestore.collection(FirestorePaths.edirMembers(areaId, edirId));

    final existingSnapshot = await collection.get();
    final existingPhones = <String>{};
    for (final doc in existingSnapshot.docs) {
      final phone = doc.data()['phone'] as String? ?? '';
      if (phone.isNotEmpty) existingPhones.add(phone);
    }

    final batch = _firestore.batch();
    final importedEdirMembers = <_LeaderAsImport>[];
    for (final member in members) {
      if (member.fullName.isEmpty) continue;
      if (member.phone.isNotEmpty && existingPhones.contains(member.phone)) {
        continue;
      }
      if (member.phone.isNotEmpty) existingPhones.add(member.phone);
      batch.set(collection.doc(), member.toCreateMap());
      importedEdirMembers.add(_LeaderAsImport(member.fullName, member.phone));
      imported++;
    }
    await batch.commit();

    // Auto-create login accounts
    await _createUserAccounts(importedEdirMembers, areaId);

    await _updateEdirMemberCount(areaId, edirId);
    return imported;
  }

  /// Creates login accounts in the `users` collection for imported members.
  /// Skips members whose phone already exists.
  Future<void> _createUserAccounts(
    List<dynamic> entries,
    String areaId,
  ) async {
    final usersCol = _firestore.collection('users');

    for (final entry in entries) {
      final String name;
      final String phone;

      if (entry is Member) {
        name = entry.fullName;
        phone = entry.phone;
      } else if (entry is _LeaderAsImport) {
        name = entry.fullName;
        phone = entry.phone;
      } else {
        continue;
      }

      if (name.isEmpty || phone.isEmpty) continue;

      // Skip if phone already registered
      final existing = await usersCol
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) continue;

      // Default access code = last 4 digits of phone
      final code = phone.length >= 4
          ? phone.substring(phone.length - 4)
          : phone;

      final user = AppUser(
        displayName: name,
        phone: phone,
        passwordCode: code,
        areaId: areaId,
        role: UserRole.member,
      );

      await usersCol.add(user.toCreateMap());
    }
  }

  /// Strip BOM and normalise line endings so [CsvToListConverter] splits rows.
  static String _sanitizeCsv(String raw) {
    var s = raw;
    // Remove UTF-8 BOM
    if (s.isNotEmpty && s.codeUnitAt(0) == 0xFEFF) {
      s = s.substring(1);
    }
    // Normalise line endings to \n
    s = s.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    return s.trim();
  }

  // ── File operations ──

  Future<File> writeCsvFile(String csv, String fileName) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/${fileName}_$timestamp.csv');
    return file.writeAsString('\uFEFF$csv'); // BOM for Excel Amharic support
  }

  Future<void> shareCsvFile(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }

  /// Picks a CSV or XLSX file and returns parsed rows as a list of string lists.
  /// Returns null if user cancels.
  Future<List<List<String>>?> pickAndParseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final extension = file.extension?.toLowerCase() ?? '';

    if (extension == 'xlsx') {
      return _parseXlsxFile(file);
    } else {
      return _parseCsvFile(file);
    }
  }

  Future<List<List<String>>> _parseCsvFile(PlatformFile file) async {
    String content;

    final bytes = file.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      content = utf8.decode(bytes, allowMalformed: true);
    } else if (!kIsWeb && file.path != null) {
      content = await File(file.path!).readAsString();
    } else {
      throw Exception('Failed to read file');
    }

    final sanitized = _sanitizeCsv(content);
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(sanitized);

    return rows.map((row) => row.map((e) => e.toString()).toList()).toList();
  }

  Future<List<List<String>>> _parseXlsxFile(PlatformFile file) async {
    Uint8List bytes;

    if (file.bytes != null && file.bytes!.isNotEmpty) {
      bytes = file.bytes!;
    } else if (!kIsWeb && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    } else {
      throw Exception('Failed to read file');
    }

    final excel = Excel.decodeBytes(bytes);
    final rows = <List<String>>[];

    if (excel.tables.isEmpty) return rows;
    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName];
    if (sheet == null) return rows;

    for (final row in sheet.rows) {
      final values = row.map<String>((cell) {
        if (cell == null || cell.value == null) return '';
        final v = cell.value;
        if (v is IntCellValue) return v.value.toString();
        if (v is DoubleCellValue) return v.value.toInt().toString();
        if (v is TextCellValue) return v.value;
        return v.toString();
      }).toList();

      if (values.every((v) => v.trim().isEmpty)) continue;
      rows.add(values);
    }

    return rows;
  }

  @Deprecated('Use pickAndParseFile() instead')
  Future<String?> pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      return utf8.decode(bytes, allowMalformed: true);
    }

    final path = file.path;
    if (path == null) return null;

    return File(path).readAsString();
  }

  // ── Helpers ──

  static String _normalizePhone(String phone) {
    if (phone.isEmpty) return phone;
    if (!phone.startsWith('0') && !phone.startsWith('+')) {
      return '0$phone';
    }
    return phone;
  }

  MemberRole _parseMemberRole(String displayName) {
    for (final role in MemberRole.values) {
      if (role.displayName == displayName) return role;
    }
    return MemberRole.member;
  }

  LeaderRole _parseLeaderRole(String displayName) {
    for (final role in LeaderRole.values) {
      if (role.displayName == displayName) return role;
    }
    return LeaderRole.viewer;
  }

  EdirLeaderRole? _parseEdirLeaderRole(String displayName) {
    if (displayName.isEmpty) return null;
    for (final role in EdirLeaderRole.values) {
      if (role.displayName == displayName) return role;
    }
    return null;
  }

  EdirMemberStatus _parseEdirMemberStatus(String displayName) {
    for (final status in EdirMemberStatus.values) {
      if (status.displayName == displayName) return status;
    }
    return EdirMemberStatus.active;
  }

  Future<void> _updateTswaCounts(String areaId, String tsiwaId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.members(areaId, tsiwaId))
          .where('deletedAt', isNull: true)
          .where('isActive', isEqualTo: true)
          .get();

      int memberCount = 0;
      int museCount = 0;

      for (final doc in snapshot.docs) {
        memberCount++;
        final role = doc.data()['role'] as String?;
        if (role == 'muse' || role == 'assistant_muse') {
          museCount++;
        }
      }

      await _firestore
          .doc(FirestorePaths.tsiwaMahber(areaId, tsiwaId))
          .update({
        'memberCount': memberCount,
        'museCount': museCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _updateEdirMemberCount(String areaId, String edirId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.edirMembers(areaId, edirId))
          .get();
      await _firestore.doc(FirestorePaths.edir(areaId, edirId)).update({
        'memberCount': snapshot.docs.length,
      });
    } catch (_) {}
  }
}

class _LeaderAsImport {
  final String fullName;
  final String phone;
  const _LeaderAsImport(this.fullName, this.phone);
}
