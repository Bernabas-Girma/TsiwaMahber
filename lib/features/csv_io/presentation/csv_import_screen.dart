import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/csv_io/data/csv_service.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir_member.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';
import 'package:tsiwa_mahber/features/members/domain/member.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class CsvImportScreen extends StatefulWidget {
  final String areaId;

  const CsvImportScreen({super.key, required this.areaId});

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  final _csvService = CsvService();
  final _tsiwaRepository = TsiwaRepository();
  final _edirRepository = EdirRepository();

  CsvEntityType _selectedType = CsvEntityType.tsiwaMembers;
  String? _selectedTsiwaId;
  String? _selectedEdirId;

  bool _isPicking = false;
  bool _isImporting = false;
  String? _csvContent;

  List<Member> _parsedMembers = [];
  List<Leader> _parsedLeaders = [];
  List<EdirMember> _parsedEdirMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.csvImportMenu)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            if (_selectedType == CsvEntityType.tsiwaMembers)
              _buildTsiwaSelector(),
            if (_selectedType == CsvEntityType.edirMembers)
              _buildEdirSelector(),
            const SizedBox(height: 16),
            _buildPickFileButton(),
            if (_csvContent != null) ...[
              const SizedBox(height: 24),
              _buildPreview(),
              const SizedBox(height: 24),
              _buildImportButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.file_download_outlined,
                color: Colors.green,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.csvImportMenu,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'CSV ወይም XLSX ፋይል መርጠው መረጃ ያስገቡ',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            S.selectDataType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        RadioGroup<CsvEntityType>(
          groupValue: _selectedType,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedType = value;
              _selectedTsiwaId = null;
              _selectedEdirId = null;
              _csvContent = null;
              _parsedMembers = [];
              _parsedLeaders = [];
              _parsedEdirMembers = [];
            });
          },
          child: Column(
            children: CsvEntityType.values.map((type) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: RadioListTile<CsvEntityType>(
                    title: Text(type.displayName),
                    value: type,
                    activeColor: AppTheme.primary,
                  ),
                )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTsiwaSelector() {
    return StreamBuilder<List<TsiwaMahber>>(
      stream: _tsiwaRepository.watchTsiwas(widget.areaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingState(message: S.loadingTsiwas);
        }

        final tsiwas = snapshot.data ?? [];
        if (tsiwas.isEmpty) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                S.noTsiwaRegistered,
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                S.selectTsiwa,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            RadioGroup<String>(
              groupValue: _selectedTsiwaId,
              onChanged: (value) {
                setState(() => _selectedTsiwaId = value);
              },
              child: Column(
                children: tsiwas.map((tsiwa) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: RadioListTile<String>(
                        title: Text(tsiwa.name),
                        subtitle: tsiwa.churchName.isNotEmpty
                            ? Text(tsiwa.churchName,
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.textMuted))
                            : null,
                        value: tsiwa.id,
                        activeColor: AppTheme.primary,
                      ),
                    )).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEdirSelector() {
    return StreamBuilder<List<Edir>>(
      stream: _edirRepository.watchEdirs(widget.areaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingState(message: S.loadingEdirs);
        }

        final edirs = snapshot.data ?? [];
        if (edirs.isEmpty) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                S.noEdirRegistered,
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                S.selectEdir,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            RadioGroup<String>(
              groupValue: _selectedEdirId,
              onChanged: (value) {
                setState(() => _selectedEdirId = value);
              },
              child: Column(
                children: edirs.map((edir) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: RadioListTile<String>(
                        title: Text(edir.name),
                        value: edir.id,
                        activeColor: AppTheme.primary,
                      ),
                    )).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPickFileButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isPicking ? null : _pickFile,
        icon: _isPicking
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.attach_file),
        label: Text(_csvContent != null ? S.selectAnotherFile : S.selectFile),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final int count;
    final List<String> headers;
    final List<List<String>> previewRows;

    switch (_selectedType) {
      case CsvEntityType.tsiwaMembers:
        count = _parsedMembers.length;
        headers = CsvService.memberHeaders;
        previewRows = _parsedMembers.take(5).map((m) => [
              m.fullName,
              m.christianName,
              m.phone,
              m.role.displayName,
            ]).toList();
        break;
      case CsvEntityType.leaders:
        count = _parsedLeaders.length;
        headers = CsvService.leaderHeaders;
        previewRows = _parsedLeaders.take(5).map((l) => [
              l.fullName,
              l.christianName,
              l.phone,
              l.role.displayName,
            ]).toList();
        break;
      case CsvEntityType.edirMembers:
        count = _parsedEdirMembers.length;
        headers = CsvService.edirMemberHeaders;
        previewRows = _parsedEdirMembers.take(5).map((m) => [
              m.fullName,
              m.christianName,
              m.phone,
              m.status.displayName,
            ]).toList();
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '$count መረጃዎች ተገኝተዋል',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  AppTheme.primary.withValues(alpha: 0.1),
                ),
                columns: headers
                    .take(4)
                    .map((h) => DataColumn(
                          label: Text(h,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ))
                    .toList(),
                rows: previewRows
                    .map((row) => DataRow(
                          cells: row
                              .map((cell) => DataCell(
                                    Text(cell,
                                        style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
        if (count > 5)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              '... እና ${count - 5} ተጨማሪ',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImportButton() {
    final int count;
    switch (_selectedType) {
      case CsvEntityType.tsiwaMembers:
        count = _parsedMembers.length;
        break;
      case CsvEntityType.leaders:
        count = _parsedLeaders.length;
        break;
      case CsvEntityType.edirMembers:
        count = _parsedEdirMembers.length;
        break;
    }

    final canImport = count > 0 &&
        (_selectedType == CsvEntityType.leaders ||
            (_selectedType == CsvEntityType.tsiwaMembers &&
                _selectedTsiwaId != null) ||
            (_selectedType == CsvEntityType.edirMembers &&
                _selectedEdirId != null));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canImport && !_isImporting ? _doImport : null,
        icon: _isImporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Icon(Icons.upload),
        label: Text(_isImporting ? S.importing : '$count መረጃ አስገባ'),
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);

    try {
      final rows = await _csvService.pickAndParseFile();
      if (rows == null) {
        setState(() => _isPicking = false);
        return;
      }

      setState(() => _csvContent = 'loaded');

      switch (_selectedType) {
        case CsvEntityType.tsiwaMembers:
          final members = _csvService.parseMembersFromRows(rows);
          setState(() => _parsedMembers = members);
          break;
        case CsvEntityType.leaders:
          final leaders = _csvService.parseLeadersFromRows(rows);
          setState(() => _parsedLeaders = leaders);
          break;
        case CsvEntityType.edirMembers:
          final edirMembers = _csvService.parseEdirMembersFromRows(rows);
          setState(() => _parsedEdirMembers = edirMembers);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.fileReadFailed}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _doImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.importConfirm),
        content: Text(
          'መረጃዎቹን ወደ ውስጥ ማስገባት ይፈልጋሉ?\n'
          'ነባር መረጃዎች አይቀየሩም — አዲስ ብቻ ይጨመራሉ።',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ተው'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.importBtn),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isImporting = true);

    try {
      int imported = 0;

      switch (_selectedType) {
        case CsvEntityType.tsiwaMembers:
          imported = await _csvService.importMembers(
            widget.areaId,
            _selectedTsiwaId!,
            _parsedMembers,
          );
          break;
        case CsvEntityType.leaders:
          imported = await _csvService.importLeaders(
            widget.areaId,
            _parsedLeaders,
          );
          break;
        case CsvEntityType.edirMembers:
          imported = await _csvService.importEdirMembers(
            widget.areaId,
            _selectedEdirId!,
            _parsedEdirMembers,
          );
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$imported መረጃዎች ተጨምረዋል')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ስህተት: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }
}
