import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';

class GlobalMemberCsvImportScreen extends StatefulWidget {
  const GlobalMemberCsvImportScreen({super.key});

  @override
  State<GlobalMemberCsvImportScreen> createState() =>
      _GlobalMemberCsvImportScreenState();
}

class _GlobalMemberCsvImportScreenState
    extends State<GlobalMemberCsvImportScreen> {
  final _authRepository = AuthRepository();

  List<List<dynamic>>? _parsedData;
  List<AppUser> _previewMembers = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final extension = file.extension?.toLowerCase() ?? '';

      List<List<dynamic>> rows;

      if (extension == 'xlsx') {
        rows = await _parseXlsx(file);
      } else {
        rows = await _parseCsv(file);
      }

      if (rows.length < 2) {
        setState(() => _error = S.fileNeedsHeaderAndData);
        return;
      }

      setState(() {
        _parsedData = rows;
        _error = null;
        _previewMembers = _parseMembers(rows);
      });
    } catch (e) {
      setState(() => _error = '${S.fileReadFailed}: $e');
    }
  }

  Future<List<List<dynamic>>> _parseCsv(PlatformFile file) async {
    String content;

    // Try bytes first, fall back to path-based reading
    final bytes = file.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      content = utf8.decode(bytes, allowMalformed: true);
    } else if (!kIsWeb && file.path != null) {
      content = await File(file.path!).readAsString();
    } else {
      throw Exception(S.fileReadFailed);
    }

    // Remove BOM if present
    if (content.startsWith('\uFEFF')) {
      content = content.substring(1);
    }
    // Normalise line endings
    content = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();

    return const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(content);
  }

  Future<List<List<dynamic>>> _parseXlsx(PlatformFile file) async {
    Uint8List bytes;

    if (file.bytes != null && file.bytes!.isNotEmpty) {
      bytes = file.bytes!;
    } else if (!kIsWeb && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    } else {
      throw Exception(S.fileReadFailed);
    }

    final excel = Excel.decodeBytes(bytes);
    final rows = <List<dynamic>>[];

    // Use the first sheet
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

      // Skip fully empty rows
      if (values.every((v) => v.toString().trim().isEmpty)) continue;
      rows.add(values);
    }

    return rows;
  }

  List<AppUser> _parseMembers(List<List<dynamic>> rows) {
    final headers = rows.first.map((h) => h.toString().trim()).toList();
    final members = <AppUser>[];

    // Find column indices — support both Amharic and English headers
    int nameIdx = _findCol(headers, ['ሙሉ ስም', 'full name', 'name', 'ስም']);
    int phoneIdx = _findCol(headers, ['ስልክ', 'phone', 'ስልክ ቁጥር']);
    int codeIdx = _findCol(headers, [
      'ኮድ',
      'code',
      'access code',
      'የመግቢያ ኮድ',
      'password',
    ]);

    if (nameIdx == -1) nameIdx = 0;
    if (phoneIdx == -1) phoneIdx = 1;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= nameIdx) continue;

      final name = row[nameIdx].toString().trim();
      if (name.isEmpty) continue;

      var phone =
          phoneIdx < row.length ? row[phoneIdx].toString().trim() : '';
      // Ensure phone starts with 0 (handles XLSX storing as number)
      if (phone.isNotEmpty &&
          !phone.startsWith('0') &&
          !phone.startsWith('+')) {
        phone = '0$phone';
      }

      final code =
          codeIdx >= 0 && codeIdx < row.length
              ? row[codeIdx].toString().trim()
              : '1234';

      members.add(AppUser(
        displayName: name,
        phone: phone,
        passwordCode: code,
        areaId: AppConstants.defaultAreaId,
        role: UserRole.member,
      ));
    }

    return members;
  }

  int _findCol(List<String> headers, List<String> candidates) {
    for (int i = 0; i < headers.length; i++) {
      final h = headers[i].toLowerCase();
      for (final c in candidates) {
        if (h.contains(c.toLowerCase())) return i;
      }
    }
    return -1;
  }

  Future<void> _import() async {
    if (_previewMembers.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final count =
          await _authRepository.batchCreateMembers(_previewMembers);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.membersImported(count))));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = S.saveFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.importMembers)),
      body: _isLoading
          ? LoadingState(
              message: S.importingMembers(_previewMembers.length),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.importMembersDesc,
                            style: const TextStyle(color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'CSV: ሙሉ ስም, ስልክ, ኮድ\n'
                            'XLSX: ሙሉ ስም, ስልክ (የመጀመሪያው ሺት)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(Icons.file_open),
                              label: Text(
                                _parsedData == null
                                    ? S.selectFile
                                    : S.selectAnotherFile,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                  if (_previewMembers.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      '${S.importPreview} (${_previewMembers.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _previewMembers.length,
                        itemBuilder: (context, index) {
                          final m = _previewMembers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppTheme.primary.withValues(alpha: 0.15),
                              child: Text('${index + 1}'),
                            ),
                            title: Text(m.displayName),
                            subtitle: Text(m.phone),
                            dense: true,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _import,
                        icon: const Icon(Icons.upload),
                        label: Text(S.importCount(_previewMembers.length)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
